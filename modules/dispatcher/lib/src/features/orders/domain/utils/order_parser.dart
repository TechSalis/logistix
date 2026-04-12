import 'dart:isolate' show Isolate;
import 'dart:math';

import 'package:dispatcher/src/features/orders/data/dtos/order_create_input.dart';
import 'package:flutter/foundation.dart';

// ─── Public Result Types ──────────────────────────────────────────────────────

/// A parsed order with a 0–1 confidence score and any warnings from the engine.
class ParsedOrder {
  const ParsedOrder({
    required this.order,
    required this.confidence,
    this.warnings = const [],
  });

  final OrderCreateInput order;
  final double confidence;
  final List<String> warnings;
}

/// A chunk of text that failed to produce a valid order.
class ParseFailure {
  const ParseFailure({
    required this.rawInput,
    required this.reason,
    required this.confidence,
  });

  final String rawInput;
  final String reason;
  final double confidence;
}

/// The aggregated result of parsing a block of text.
class LocalParseResult {
  const LocalParseResult({required this.orders, required this.failures});

  final List<ParsedOrder> orders;
  final List<ParseFailure> failures;

  bool get isEmpty => orders.isEmpty;

  double get overallConfidence {
    if (orders.isEmpty) return 0;
    return orders.fold<double>(0, (s, o) => s + o.confidence) / orders.length;
  }

  /// True when local confidence is insufficient — triggers the remote fallback.
  bool get needsRemoteFallback => isEmpty || overallConfidence < 0.45;
}

// ─── Parser Entry Point ───────────────────────────────────────────────────────

/// Intent-aware, fuzzy-matching order parser.
///
/// Moves beyond pure regex by combining:
/// - **Edit-distance (Levenshtein) fuzzy keyword matching** — handles typos,
///   spacing variants, and abbreviations like "pikup", "drp off", "P.U.".
/// - **Per-line intent classification** — each line is scored across intents
///   (phoneNumber, address, amount, pickupLabel, dropoffLabel, description)
///   using multi-feature probabilistic scoring rather than greedy pattern hits.
/// - **Context state machine** — active role (pickup / dropoff) persists across
///   consecutive lines and is only cleared by an *opposing* label, never by
///   entity detection (fixing the bug in the old approach).
/// - **Phrase-level signal detection** — sentences like "she will give your rider"
///   or "drop off pays 2k" are understood as contextual cues that influence
///   entity role assignment.
///
/// Runs in a background [Isolate] to ensure 60fps UI performance.
class OrderParser {
  static Future<LocalParseResult> parse(String text) async {
    if (text.trim().isEmpty) {
      return const LocalParseResult(orders: [], failures: []);
    }
    final raw = await compute(_isolateEntry, text);
    return _deserialise(raw);
  }

  static Map<String, dynamic> _isolateEntry(String text) {
    try {
      return _Engine(text).run();
    } catch (_) {
      return {'orders': <dynamic>[], 'failures': <dynamic>[]};
    }
  }

  static LocalParseResult _deserialise(Map<String, dynamic> raw) {
    final orders = (raw['orders'] as List).map((o) {
      final m = o as Map<String, dynamic>;
      return ParsedOrder(
        order: OrderCreateInput.fromJson(m['order'] as Map<String, dynamic>),
        confidence: (m['confidence'] as num).toDouble(),
        warnings: List<String>.from(m['warnings'] as List),
      );
    }).toList();

    final failures = (raw['failures'] as List).map((f) {
      final m = f as Map<String, dynamic>;
      return ParseFailure(
        rawInput: m['rawInput'] as String,
        reason: m['reason'] as String,
        confidence: (m['confidence'] as num).toDouble(),
      );
    }).toList();

    return LocalParseResult(orders: orders, failures: failures);
  }
}

// ─── Fuzzy Matching Utilities ─────────────────────────────────────────────────

/// Levenshtein edit distance between two strings.
int _editDistance(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  final prev = List<int>.generate(b.length + 1, (i) => i);
  final curr = List<int>.filled(b.length + 1, 0);
  for (var i = 1; i <= a.length; i++) {
    curr[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      curr[j] = min(min(curr[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
    }
    prev.setAll(0, curr);
  }
  return prev[b.length];
}

/// Best fuzzy match score (0–1) of any token in [text] against [vocabulary].
/// [maxDistance] controls tolerance: 1 = small typo, 2 = moderate misspelling.
double _fuzzyScore(String text, List<String> vocabulary, {int maxDistance = 2}) {
  final tokens = text.toLowerCase().split(RegExp(r'[\s\-_/]+'));
  var best = 0.0;
  for (final token in tokens) {
    if (token.length < 2) continue;
    for (final kw in vocabulary) {
      if (kw.length < 2) continue;
      final dist = _editDistance(token, kw);
      if (dist > maxDistance) continue;
      // Distance-normalised similarity, biased toward shorter keywords
      final score = 1.0 - (dist / max(token.length, kw.length));
      if (score > best) best = score;
    }
  }
  return best;
}

/// True if [text] contains a token that fuzzy-matches any keyword in [vocab].
bool _fuzzyContains(String text, List<String> vocab, {int maxDistance = 2}) =>
    _fuzzyScore(text, vocab, maxDistance: maxDistance) > 0.6;

// ─── Vocabulary Banks ─────────────────────────────────────────────────────────

// Role labels
const _kPickup  = ['pickup', 'pick', 'from', 'origin', 'source', 'sender', 'collect', 'collection'];
const _kDropoff = ['dropoff', 'delivery', 'deliver', 'destination', 'dest', 'recipient', 'receiver'];

// Field labels
const _kPhone   = ['phone', 'mobile', 'tel', 'call', 'contact', 'number', 'reach', 'whatsapp', 'dial', 'ring'];
const _kAmount  = ['amount', 'cod', 'price', 'cost', 'fee', 'charge', 'value', 'pay', 'payment', 'total', 'naira'];
const _kDesc    = ['description', 'item', 'package', 'parcel', 'content', 'goods', 'note', 'remark', 'order'];
const _kAddress = ['address', 'location', 'loc', 'place', 'area', 'street', 'road', 'way'];

// Phrase-level intent signals
// "she will give your rider" → dropoff context
// "you will collect from"    → pickup context
// "drop off pays"            → amount with dropoff context
// "give driver"              → amount with pickup context
const _kDropoffOwnerPhrases  = ['give your rider', 'will give rider', 'recipient pays', 'drop off pays', 'dropoff pays', 'deliver pays'];
const _kPickupOwnerPhrases   = ['give driver', 'you collect', 'collect from', 'pick up pays', 'pickup pays'];
const _kStaffPhrases         = ['send airtime', 'send credit', 'recharge', 'airtime to', 'send me'];

// Nigerian cities & area names for address recognition
const _kNigerianPlaces = [
  // Rivers State (expanded)
  'port harcourt', 'ph', 'rumuokoro', 'rumuola', 'rumuigbo', 'rumuepirikom',
  'rumuobiokani', 'rumuji', 'rumuekini', 'aluu', 'iwofe', 'oyigbo', 'ada george',
  'gra', 'mgbuodohia', 'elelenwo', 'eliozu', 'woji', 'nkpolu', 'diobu',
  'mile one', 'mile 3', 'mile 4', 'choba', 'ozuoba', 'igbo etche', 'bonny',
  'omoukiri', 'transamadi', 'aggrey', 'aba road', 'east west road',
  // Lagos
  'lagos', 'ikeja', 'lekki', 'ajah', 'surulere', 'yaba', 'apapa', 'mushin',
  'oshodi', 'ikorodu', 'badagry', 'victoria island', 'ilupeju', 'ojota', 'ogba',
  'agege', 'festac', 'satellite', 'isolo', 'ejigbo',
  // Abuja
  'abuja', 'wuse', 'garki', 'asokoro', 'maitama', 'gwarinpa', 'kubwa', 'lokogoma',
  // Other major cities
  'kano', 'ibadan', 'onitsha', 'enugu', 'kaduna', 'warri', 'benin city', 'aba',
  'owerri', 'uyo', 'calabar', 'akure', 'ilorin', 'maiduguri',
];

// Generic street/area type keywords
const _kStreetTypes = [
  'street', 'avenue', 'road', 'way', 'drive', 'close', 'crescent', 'lane',
  'boulevard', 'estate', 'layout', 'phase', 'zone', 'court', 'square', 'gate',
  'junction', 'bypass', 'expressway', 'hostel', 'hotel', 'hospital', 'market',
  'park', 'bus stop', 'filling station', 'church', 'mosque', 'school',
  'shopping mall', 'plaza', 'complex',
];

// ─── Line Intent Enum & Classification ───────────────────────────────────────

enum _LineIntent {
  pickupLabel,   // Standalone "Pickup:", "From:"
  dropoffLabel,  // Standalone "Dropoff:", "To:"
  phone,         // Line whose primary content is a phone number
  amount,        // Line containing a monetary value
  address,       // Line describing a location
  description,   // Line describing what is being delivered
  phraseHint,    // Context clue phrase (not a direct entity)
  noise,         // Unrecognisable
}

class _IntentResult {
  const _IntentResult(this.intent, this.score, {this.roleHint = _Role.none});
  final _LineIntent intent;
  final double score;
  final _Role roleHint; // Optional role override extracted from the line
}

/// Classifies the primary intent of a single line of text.
class _LineClassifier {
  static final _phoneRx = RegExp(
    r'(?:\+?234|0)[\s\-]*\d{2,3}[\s\-]*\d{3,4}[\s\-]*\d{4}',
  );
  static final _standaloneLabelRx = RegExp(r'^(.{2,35})[:\-]\s*$');
  static final _kvLabelRx = RegExp(r'^(.{2,40})[:\-]\s*(.+)$');
  static final _amountRx = RegExp(
    r'(?:₦|NGN|naira)?\s*(\d[\d,]*[.,]?\d*)\s*(k\b)?',
    caseSensitive: false,
  );

  _IntentResult classify(String line) {
    final lower = line.toLowerCase().trim();

    // ── 1. Phone ───────────────────────────────────────────────────────────
    if (_phoneRx.hasMatch(line)) {
      // Demote if line is clearly about airtime/recharge
      final isAirtime = _fuzzyContains(lower, _kStaffPhrases, maxDistance: 1);
      final isLabeled = _fuzzyContains(lower, _kPhone, maxDistance: 1);
      final score = isAirtime ? 0.35 : (isLabeled ? 0.98 : 0.92);
      final role = _roleFromContext(lower);
      return _IntentResult(_LineIntent.phone, score, roleHint: role);
    }

    // ── 2. Standalone role label ("Pickup:", "Delivery:") ─────────────────
    final standaloneMatch = _standaloneLabelRx.firstMatch(lower);
    if (standaloneMatch != null) {
      final key = standaloneMatch.group(1)!;
      final pickupScore = _fuzzyScore(key, _kPickup);
      final dropoffScore = _fuzzyScore(key, _kDropoff);
      if (pickupScore > 0.55) {
        return _IntentResult(_LineIntent.pickupLabel, pickupScore);
      }
      if (dropoffScore > 0.55) {
        return _IntentResult(_LineIntent.dropoffLabel, dropoffScore);
      }
    }

    // ── 3. Key-Value line ("Pickup Phone: 08012345678") ───────────────────
    // (handled in the engine for direct entity extraction — return phraseHint)
    if (_kvLabelRx.hasMatch(line)) {
      return const _IntentResult(_LineIntent.phraseHint, 0.7);
    }

    // ── 4. Amount  ─────────────────────────────────────────────────────────
    if (!_fuzzyContains(lower, _kStaffPhrases, maxDistance: 1)) {
      final amtMatch = _amountRx.firstMatch(lower);
      if (amtMatch != null) {
        final val = double.tryParse(amtMatch.group(1)!.replaceAll(',', ''));
        if (val != null && val >= 50) {
          var score = 0.40;
          if (amtMatch.group(2)?.toLowerCase() == 'k') score += 0.25;
          if (_fuzzyContains(lower, _kAmount)) score += 0.25;
          final role = _roleFromContext(lower);
          return _IntentResult(_LineIntent.amount, score.clamp(0, 1.0), roleHint: role);
        }
      }
    }

    // ── 5. Phrase-level context hints ─────────────────────────────────────
    for (final phrase in _kDropoffOwnerPhrases) {
      if (lower.contains(phrase)) {
        return const _IntentResult(
          _LineIntent.phraseHint,
          0.8,
          roleHint: _Role.dropoff,
        );
      }
    }
    for (final phrase in _kPickupOwnerPhrases) {
      if (lower.contains(phrase)) {
        return const _IntentResult(
          _LineIntent.phraseHint,
          0.8,
          roleHint: _Role.pickup,
        );
      }
    }

    // ── 6. Address  ─────────────────────────────────────────────────────────
    final addrScore = _scoreAsAddress(line, lower);
    if (addrScore >= 0.28) {
      final role = _roleFromContext(lower);
      return _IntentResult(_LineIntent.address, addrScore, roleHint: role);
    }

    // ── 7. Description (multi-word non-numeric lines) ──────────────────────
    final wordCount = lower.split(RegExp(r'\s+')).length;
    if (wordCount >= 2 && line.length > 5) {
      return const _IntentResult(_LineIntent.description, 0.4);
    }

    return const _IntentResult(_LineIntent.noise, 0.1);
  }

  // Infer a role from contextual words within the same line
  _Role _roleFromContext(String lower) {
    if (_fuzzyContains(lower, _kPickup)) return _Role.pickup;
    if (_fuzzyContains(lower, _kDropoff)) return _Role.dropoff;
    return _Role.none;
  }

  double _scoreAsAddress(String line, String lower) {
    var score = 0.0;

    // Fuzzy match against place name vocabulary
    for (final place in _kNigerianPlaces) {
      if (lower.contains(place)) {
        score += 0.55;
        break;
      }
    }
    if (score == 0) {
      final placeScore = _fuzzyScore(lower, _kNigerianPlaces, maxDistance: 1);
      if (placeScore > 0.7) score += placeScore * 0.55;
    }

    // Fuzzy match against street-type keywords
    final streetScore = _fuzzyScore(lower, _kStreetTypes, maxDistance: 1);
    if (streetScore > 0.7) score += streetScore * 0.35;

    // Structural signals
    if (line.length > 20) score += 0.15;
    if (line.length > 40) score += 0.10;
    if (line.contains(',')) score += 0.12;
    if (RegExp(r'^\d+\s+[A-Za-z]').hasMatch(line)) score += 0.18; // "12 Main St"

    // Context words at start of line
    if (_fuzzyContains(lower, _kAddress, maxDistance: 1)) score += 0.10;

    // Penalise noise signals
    if (line.length < 7) score -= 0.30;
    if (_fuzzyContains(lower, _kDesc, maxDistance: 1)) score -= 0.10;

    return score.clamp(0.0, 1.0);
  }
}

// ─── Context State Machine ────────────────────────────────────────────────────

enum _Role { none, pickup, dropoff }

/// Tracks the active parsing context across lines within a chunk.
///
/// The role persists until an *opposing* label is encountered —
/// entity detection does NOT reset it (this was the core bug in old approach).
class _ContextState {
  _Role activeRole = _Role.none;

  /// Apply an explicit label intent.
  void applyLabel(_LineIntent intent) {
    if (intent == _LineIntent.pickupLabel) {
      activeRole = _Role.pickup;
    } else if (intent == _LineIntent.dropoffLabel) {
      activeRole = _Role.dropoff;
    }
  }

  /// Apply a phrase hint (e.g. "drop off pays") as a context hint.
  void applyHint(_Role role) {
    if (role != _Role.none) activeRole = role;
  }

  /// Resolve the effective role for an entity — prefer the inline role hint
  /// (from key-value parsing), fall back to active context state.
  _Role resolveRole(_Role inlineHint) {
    if (inlineHint != _Role.none) return inlineHint;
    return activeRole;
  }
}

// ─── Scored Entity ────────────────────────────────────────────────────────────

class _E<T> {
  _E(this.value, this.score, {this.role = _Role.none});
  final T value;
  final double score;
  final _Role role;
}

// ─── Internal Parsing Engine ──────────────────────────────────────────────────

class _Engine {
  _Engine(this.rawText);
  final String rawText;

  final _classifier = _LineClassifier();
  static final _phoneRx  = RegExp(r'(?:\+?234|0)[\s\-]*\d{2,3}[\s\-]*\d{3,4}[\s\-]*\d{4}');
  static final _kvRx     = RegExp(r'^(.{2,45}?)[:\-]\s*(.+)$');
  static final _amountRx = RegExp(
    r'(?:₦|NGN|naira)?\s*(\d[\d,]*[.,]?\d*)\s*(k\b)?',
    caseSensitive: false,
  );

  Map<String, dynamic> run() {
    final text = _normalise(rawText);
    final chunks = _split(text);

    final orders   = <Map<String, dynamic>>[];
    final failures = <Map<String, dynamic>>[];

    for (final chunk in chunks) {
      if (chunk.trim().isEmpty) continue;
      final result = _parseChunk(chunk);
      if (result == null) {
        failures.add({'rawInput': chunk, 'reason': 'No recognisable order data', 'confidence': 0.0});
      } else if ((result['confidence'] as double) < 0.35) {
        failures.add({
          'rawInput': chunk,
          'reason': 'Confidence too low (${((result['confidence'] as double) * 100).round()}%)',
          'confidence': result['confidence'],
        });
      } else {
        orders.add(result);
      }
    }

    // Fallback: splitting was overly aggressive — try the whole text as one.
    if (orders.isEmpty && chunks.length > 1) {
      final fallback = _parseChunk(text);
      if (fallback != null && (fallback['confidence'] as double) >= 0.35) {
        return {'orders': [fallback], 'failures': <dynamic>[]};
      }
    }

    return {'orders': orders, 'failures': failures};
  }

  // ─── Normalisation ────────────────────────────────────────────────────────

  String _normalise(String text) {
    var s = text.trim();

    // Strip forwarding/metadata headers
    s = s.replaceAll(
      RegExp(r'^(?:Forwarded|Sent from WhatsApp|Message forwarded|Fwd:)[^\n]*\n?', caseSensitive: false),
      '',
    );
    s = s.replaceAll(
      RegExp(r'\[\d{1,2}:\d{2}(?:\s?[APMapm]{2})?,?\s*\d{1,2}/\d{1,2}/\d{2,4}\]\s*'),
      '',
    );

    // Fix OCR O→0 in phone / currency
    s = s.replaceAllMapped(
      RegExp(r'(?:^|\s)((\+234|0)[0-9O]{9,13})(?=\s|$)'),
      (m) => ' ${m.group(1)!.replaceAll('O', '0').replaceAll('o', '0')}',
    );
    s = s.replaceAllMapped(RegExp(r'[₦N]\s*[0-9O,]+'), (m) {
      return m.group(0)!.replaceAll('O', '0');
    });

    // Expand shorthands before classification
    s = s.replaceAll(RegExp(r'\bpick\s*up\b', caseSensitive: false), 'pickup');
    s = s.replaceAll(RegExp(r'\bdrop[\s\-]+off\b', caseSensitive: false), 'dropoff');
    s = s.replaceAll(RegExp(r'\bP\.?\s*U\.?\b', caseSensitive: false), 'pickup');
    s = s.replaceAll(RegExp(r'\bD\.?\s*O\.?\b', caseSensitive: false), 'dropoff');
    s = s.replaceAll(RegExp(r'\bP/U\b', caseSensitive: false), 'pickup');
    s = s.replaceAll(RegExp(r'\bD/O\b', caseSensitive: false), 'dropoff');

    return s;
  }

  // ─── Chunk Splitting ──────────────────────────────────────────────────────

  List<String> _split(String text) {
    String trim(String s) => s.trim();
    bool notEmpty(String s) => s.isNotEmpty;

    // Explicit dividers (===, ---, ***)
    if (RegExp(r'={3,}|-{3,}|\*{3,}').hasMatch(text)) {
      return text
          .split(RegExp(r'\n?\s*(?:={3,}|-{3,}|\*{3,})\s*\n?'))
          .map(trim).where(notEmpty).toList();
    }

    // Numbered entry markers ("1.", "1:", "Order 2 -", "Delivery 3:")
    final numbered = RegExp(
      r'(?:^|\n)(?:\*\*)?(?:\d+[.)]\s*|Order\s*\d+[:\-\s]|Delivery\s*\d+[:\-\s]|Customer\s*\d+[:\-\s])(?:\*\*)?',
      caseSensitive: false,
    );
    if (numbered.hasMatch(text)) {
      return text.split(numbered).map(trim).where(notEmpty).toList();
    }

    // Multiple pickup/dropoff label pairs (≥4 signals multi-order block)
    final labelHits = RegExp(r'\b(?:pickup|dropoff)\b', caseSensitive: false)
        .allMatches(text).length;
    if (labelHits >= 4 && text.contains('\n\n')) {
      return text.split(RegExp(r'\n\s*\n')).map(trim).where(notEmpty).toList();
    }

    // Multiple phone numbers + paragraph breaks
    if (_phoneRx.allMatches(text).length > 2 && text.contains('\n\n')) {
      return text.split(RegExp(r'\n\s*\n')).map(trim).where(notEmpty).toList();
    }

    return [text];
  }

  // ─── Per-chunk Parsing ────────────────────────────────────────────────────

  Map<String, dynamic>? _parseChunk(String chunk) {
    final lines = chunk
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    if (lines.isEmpty) return null;

    final phones    = <_E<String>>[];
    final addresses = <_E<String>>[];
    final amounts   = <_E<double>>[];
    final descLines = <String>[];

    final context  = _ContextState();
    final consumed = <int>{};

    // ── PASS 1: Structured key-value lines ────────────────────────────────
    // Handles lines like "Pickup Phone: 08012345678", "Amount: 5k", etc.
    for (var i = 0; i < lines.length; i++) {
      final kv = _kvRx.firstMatch(lines[i]);
      if (kv == null) continue;

      final key   = kv.group(1)!.toLowerCase().trim();
      final value = kv.group(2)!.trim();

      // Determine role from key using fuzzy matching
      var role = _Role.none;
      if (_fuzzyContains(key, _kPickup)) role = _Role.pickup;
      if (_fuzzyContains(key, _kDropoff)) role = _Role.dropoff;

      // Is value a phone?
      if (_phoneRx.hasMatch(value) || _isLikelyPhone(value)) {
        final cleaned = _cleanPhone(value);
        if (cleaned != null) {
          final effectiveRole = role != _Role.none ? role : _Role.dropoff;
          phones.add(_E(cleaned, 0.93, role: effectiveRole));
          consumed.add(i);
          continue;
        }
      }

      // Is this a pure amount key?
      if (_fuzzyContains(key, _kAmount, maxDistance: 1)) {
        final amt = _parseAmount(value);
        if (amt != null) {
          amounts.add(_E(amt, 0.95));
          consumed.add(i);
          continue;
        }
      }

      // Is this a description key?
      if (_fuzzyContains(key, _kDesc, maxDistance: 1)) {
        descLines.add(value);
        consumed.add(i);
        continue;
      }

      // Otherwise — address field
      if (_fuzzyContains(key, [..._kAddress, ..._kPickup, ..._kDropoff], maxDistance: 1) &&
          value.length > 4) {
        final aScore = 0.80 + (_classifier._scoreAsAddress(value, value.toLowerCase()) * 0.15);
        addresses.add(_E(value, aScore.clamp(0, 1.0), role: role));
        consumed.add(i);
        continue;
      }
    }

    // ── PASS 2: Intent-based NLP extraction (unstructured lines) ─────────
    for (var i = 0; i < lines.length; i++) {
      if (consumed.contains(i)) continue;

      final line  = lines[i];
      final lower = line.toLowerCase();
      final ir    = _classifier.classify(line);

      switch (ir.intent) {
        case _LineIntent.pickupLabel:
        case _LineIntent.dropoffLabel:
          context.applyLabel(ir.intent);

        case _LineIntent.phraseHint:
          context.applyHint(ir.roleHint);
          // If the line also contains an amount (e.g. "drop off pays 2k"), extract it.
          final amt = _extractAmountFromLine(lower);
          if (amt != null) {
            final role = ir.roleHint != _Role.none ? ir.roleHint : context.activeRole;
            amounts.add(_E(amt, 0.65, role: role));
          }

        case _LineIntent.phone:
          for (final pm in _phoneRx.allMatches(line)) {
            final cleaned = _cleanPhone(pm.group(0)!);
            if (cleaned == null) continue;
            final role = context.resolveRole(ir.roleHint);
            phones.add(_E(cleaned, ir.score, role: role));
          }

        case _LineIntent.amount:
          final amt = _extractAmountFromLine(lower);
          if (amt != null) {
            amounts.add(_E(amt, ir.score, role: ir.roleHint));
          }

        case _LineIntent.address:
          final role = context.resolveRole(ir.roleHint);
          addresses.add(_E(line, ir.score, role: role));

        case _LineIntent.description:
          descLines.add(line);

        case _LineIntent.noise:
          break; // Discard
      }
    }

    // ── PASS 3: Role resolution (constraint satisfaction) ─────────────────
    String? pickupAddr;
    String? dropOffAddr;
    String? pickupPh;
    String? dropOffPh;
    double? amount;
    final warnings = <String>[];

    void assignAddress(_E<String> a) {
      if (a.role == _Role.pickup && pickupAddr == null) {
        pickupAddr = a.value;
      } else if (a.role == _Role.dropoff && dropOffAddr == null) {
        dropOffAddr = a.value;
      } else if (dropOffAddr == null) {
        dropOffAddr = a.value;
      } else if (pickupAddr == null && a.value != dropOffAddr) {
        pickupAddr = a.value;
      }
    }

    void assignPhone(_E<String> p) {
      if (p.score < 0.2) return;
      if (p.role == _Role.pickup && pickupPh == null) {
        pickupPh = p.value;
      } else if (p.role == _Role.dropoff && dropOffPh == null) {
        dropOffPh = p.value;
      } else if (dropOffPh == null) {
        dropOffPh = p.value;
      } else if (pickupPh == null && p.value != dropOffPh) {
        pickupPh = p.value;
      }
    }

    addresses.sort((a, b) => b.score.compareTo(a.score));
    for (final a in addresses) {
      assignAddress(a);
    }
    // Single untagged address → treat as drop-off (delivery destination)
    if (dropOffAddr == null && pickupAddr != null && addresses.length == 1) {
      dropOffAddr = pickupAddr;
      pickupAddr  = null;
      warnings.add('Single address assumed as drop-off destination');
    }

    phones.sort((a, b) => b.score.compareTo(a.score));
    for (final p in phones) {
      assignPhone(p);
    }

    amounts.sort((a, b) => b.score.compareTo(a.score));
    if (amounts.isNotEmpty && amounts.first.score >= 0.35) {
      amount = amounts.first.value;
    }

    final description = descLines
        .where((l) => l.split(' ').length > 1 || l.length > 5)
        .take(3)
        .join(', ')
        .trim();

    // ── PASS 4: Confidence scoring ─────────────────────────────────────────
    var confidence = 0.0;

    final currDropoff = dropOffAddr;
    if (currDropoff != null && currDropoff.isNotEmpty) {
      confidence += 0.40;
      // Bonus: address matched a well-known place keyword
      if (_classifier._scoreAsAddress(currDropoff, currDropoff.toLowerCase()) > 0.5) {
        confidence += 0.08;
      }
    }
    if (dropOffPh != null)  confidence += 0.25;
    if (pickupAddr != null) confidence += 0.10;
    if (pickupPh  != null)  confidence += 0.09;
    if (amount    != null)  confidence += 0.09;
    if (description.isNotEmpty) confidence += 0.04;

    // Phone with no address — partial confidence floor
    if (dropOffAddr == null && (dropOffPh != null || pickupPh != null)) {
      confidence = min(confidence, 0.42);
      warnings.add('Phone found but no delivery address');
    }

    // Unrecoverable: nothing useful extracted
    if (dropOffAddr == null && dropOffPh == null && pickupPh == null) {
      return null;
    }

    confidence = confidence.clamp(0.0, 1.0);

    final order = OrderCreateInput(
      dropOffAddress: dropOffAddr ?? '',
      pickupAddress:  pickupAddr,
      pickupPhone:    pickupPh,
      dropOffPhone:   dropOffPh,
      codAmount:      amount,
      description:    description.isEmpty ? null : description,
    );

    return {
      'order':      order.toJson(),
      'confidence': confidence,
      'warnings':   warnings,
    };
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  bool _isLikelyPhone(String s) {
    final c = s.replaceAll(RegExp(r'[\s\-()]'), '');
    return RegExp(r'^(?:\+?234|0)\d{9,11}$').hasMatch(c);
  }

  String? _cleanPhone(String raw) {
    var c = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    if (c.startsWith('+234')) c = '0${c.substring(4)}';
    if (c.startsWith('234'))  c = '0${c.substring(3)}';
    if (c.length < 10 || c.length > 11) return null;
    return c;
  }

  double? _extractAmountFromLine(String lower) {
    if (_fuzzyContains(lower, ['airtime', 'recharge', 'credit'])) return null;
    final m = _amountRx.firstMatch(lower);
    if (m == null) return null;
    var val = double.tryParse(m.group(1)!.replaceAll(',', ''));
    if (val == null || val < 50) return null;
    if (m.group(2)?.toLowerCase() == 'k') val *= 1000;
    return val;
  }

  double? _parseAmount(String raw) {
    final c = raw.replaceAll(RegExp(r'[₦,NGN\s]'), '');
    final val = double.tryParse(c);
    if (val == null || val < 50) return null;
    return val;
  }
}
