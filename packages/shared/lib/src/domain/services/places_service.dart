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

    // Cancel / complete previous request if still pending
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
  /// Fetches address predictions for a given query with specific place types.
  Future<List<Prediction>> getPredictionsWithType(String query, List<String> types) async {
    if (query.trim().isEmpty) return [];

    final completer = Completer<List<Prediction>>();
    final typedPlaces = GooglePlacesAutocomplete(
      countries: ['ng'],
      placeTypes: types,
      predictionsListener: (predictions) {
        if (!completer.isCompleted) completer.complete(predictions);
      },
      onError: (error) {
        if (!completer.isCompleted) completer.completeError(error);
      },
      debounceTime: 0,
    );

    try {
      await typedPlaces.initialize();
      typedPlaces.getPredictions(query);
      final result = await completer.future.timeout(const Duration(seconds: 5));
      typedPlaces.dispose();
      return result;
    } catch (_) {
      typedPlaces.dispose();
      return [];
    }
  }
  /// Attempts to find the best Google Place match for an address query.
  /// Uses a fuzzy matching algorithm that handles minor word variations or 1-2 word inaccuracies.
  Future<PlaceMatch?> findBestMatch(
    String address, {
    double minConfidence = 0.85, // Lowered slightly to allow for 1-2 word drift
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

      // Score against both the primary name (title) and the full description/address
      final titleScore = _calculateSimilarity(query, title);
      final descScore = _calculateSimilarity(query, description);
      
      final bestScore = max(titleScore, descScore);
      
      if (bestScore > highestScore && bestScore >= minConfidence) {
        highestScore = bestScore;
        bestMatch = (formattedAddress: description, placeId: placeId);
      }
      
      // Short-circuit on exact match
      if (bestScore == 1.0) break;
    }

    return bestMatch;
  }

  /// Refined similarity score (0.0 to 1.0) using word correlation and substring weights
  double _calculateSimilarity(String query, String match) {
    final s1 = query.toLowerCase().trim();
    final s2 = match.toLowerCase().trim();
    
    // Perfect match
    if (s1 == s2) return 1;

    // Name-Aware Prefix Match: Very high weight if the query is the START of the address/name
    // (e.g. "Pizza Hut" matches "Pizza Hut, Port Harcourt")
    if (s2.startsWith(s1)) {
       return 0.98 + (s1.length / s2.length * 0.02);
    }

    // Substring match anywhere else
    if (s2.contains(s1)) {
       return 0.90 + (s1.length / s2.length * 0.05);
    }

    final words1 = s1.split(RegExp(r'[\s,\-]+')).where((w) => w.length > 2).toSet();
    final words2 = s2.split(RegExp(r'[\s,\-]+')).where((w) => w.length > 2).toSet();

    if (words1.isEmpty) return 0;

    final intersection = words1.intersection(words2);
    
    // Word correlation score (allows for 1-2 word inaccuracy if the list is long enough)
    // Example: "Ada George Junction Port Harcourt" (4 words) 
    // vs "Ada George Junction, Rivers" (3 words intersect). Score: 0.75
    final correlation = intersection.length / words1.length;
    
    return correlation;
  }

  /// Attempts to find a Google Place ID for an address.
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

/// A high-confidence match from Google Places
typedef PlaceMatch = ({String formattedAddress, String placeId});
