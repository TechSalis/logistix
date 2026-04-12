import 'dart:async';
import 'dart:math';
import 'package:google_places_autocomplete/google_places_autocomplete.dart';

class PlacesService {
  late final GooglePlacesAutocomplete _places;

  bool _isInitialized = false;
  Future<void>? _initTask;
  Completer<List<Prediction>>? _completer;

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;
    return _initTask ??= _initialize();
  }

  Future<void> _initialize() async {
    _places = GooglePlacesAutocomplete(
      predictionsListener: _onPredictions,
      countries: ['ng'],
      onError: _onError,
    );
    await _places.initialize();
    _isInitialized = true;
  }

  void _onPredictions(List<Prediction> predictions) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete(predictions);
    }
  }

  void _onError(Object error) {
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(error);
    }
  }

  /// Fetches address predictions for a given query.
  Future<List<Prediction>> getPredictions(String query) async {
    if (query.trim().isEmpty) return [];

    await _ensureInitialized();

    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete([]);
    }

    _completer = Completer<List<Prediction>>();
    _places.getPredictions(query);

    try {
      return await _completer!.future.timeout(const Duration(seconds: 5));
    } catch (_) {
      return [];
    }
  }

  /// Attempts to find the best Google Place match for an address query.
  /// Handles typos and word variations using a weighted fuzzy algorithm.
  Future<PlaceMatch?> findBestMatch(
    String address, {
    double minConfidence = 0.75, // Allow for more drift with fuzzy matching
  }) async {
    final query = address.trim();
    if (query.isEmpty) return null;

    final predictions = await getPredictions(query);
    if (predictions.isEmpty) return null;

    PlaceMatch? bestMatch;
    double highestScore = 0;

    for (final p in predictions) {
      final title = p.title ?? '';
      final description = p.description;
      final placeId = p.placeId;

      if (description == null || placeId == null) continue;

      final titleScore = _calculateSimilarity(query, title);
      final descScore = _calculateSimilarity(query, description);
      
      final bestScore = max(titleScore, descScore);
      
      if (bestScore > highestScore && bestScore >= minConfidence) {
        highestScore = bestScore;
        bestMatch = (formattedAddress: description, placeId: placeId);
      }
      
      if (bestScore >= 0.99) break;
    }

    return bestMatch;
  }

  /// Enhanced fuzzy similarity score (0.0 to 1.0)
  /// Features:
  /// - Exact prefix/substring boosts
  /// - Word-level fuzzy matching (handles typos like Ada/Anda)
  /// - Length-normalized scoring
  double _calculateSimilarity(String query, String match) {
    final s1 = query.toLowerCase().trim();
    final s2 = match.toLowerCase().trim();
    
    if (s1 == s2) return 1;

    // Direct substring boosts
    if (s2.startsWith(s1)) return 0.98;
    if (s2.contains(s1)) return 0.90;

    // Tokenize and compare words
    final wordsQuery = s1.split(RegExp(r'[\s,\-]+')).where((w) => w.length > 1).toList();
    final wordsMatch = s2.split(RegExp(r'[\s,\-]+')).where((w) => w.length > 1).toList();

    if (wordsQuery.isEmpty) return 0;

    double totalWordScore = 0;
    
    for (final qWord in wordsQuery) {
      double bestWordMatchScore = 0;
      
      for (final mWord in wordsMatch) {
        // Exact word match
        if (qWord == mWord) {
          bestWordMatchScore = 1.0;
          break;
        }
        
        // Fuzzy word match (handles "Ada" vs "Anda")
        final distance = _levenshtein(qWord, mWord);
        final maxLen = max(qWord.length, mWord.length);
        
        // Only allow 1-2 character typos for short words, or ~25% for long words
        final threshold = qWord.length <= 4 ? 1 : 2;
        
        if (distance <= threshold) {
          final wordSimilarity = 1.0 - (distance / maxLen);
          // Apply a penalty for fuzzy matches so they score lower than exact ones
          bestWordMatchScore = max(bestWordMatchScore, wordSimilarity * 0.95);
        }
      }
      
      totalWordScore += bestWordMatchScore;
    }

    // Normalized score based on how many query words were found (exactly or fuzzily)
    final finalScore = totalWordScore / wordsQuery.length;
    
    return finalScore.clamp(0.0, 1.0);
  }

  /// Standard Levenshtein Distance for typo detection
  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final v0 = List<int>.generate(t.length + 1, (i) => i);
    final v1 = List<int>.filled(t.length + 1, 0);

    for (var i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < t.length; j++) {
        final cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      for (var j = 0; j < t.length + 1; j++) {
        v0[j] = v1[j];
      }
    }
    return v0[t.length];
  }

  Future<String?> findPlaceId(String address) async {
    final match = await findBestMatch(address);
    return match?.placeId;
  }

  void dispose() {
    if (_isInitialized) {
      _places.dispose();
    }
  }
}

typedef PlaceMatch = ({String formattedAddress, String placeId});
