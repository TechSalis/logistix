import 'dart:math';
import 'package:dispatcher/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class SearchRidersUseCase {
  SearchRidersUseCase(this._repository);
  final RiderRepository _repository;

  Future<List<Rider>> call(String query, {double? lat, double? lng}) async {
    final result = await _repository.getRiders(searchQuery: query);

    return result.map((err) => [], (list) {
      final sorted = List<Rider>.from(list);

      // 1. If we have a location AND NO search query, prioritize proximity
      if (lat != null && lng != null && query.isEmpty) {
        // Filter only online riders for auto-proximity sorting
        return sorted.where((r) => r.status == RiderStatus.ONLINE).toList()
          ..sort((a, b) {
            final distA = _calculateDistance(lat, lng, a.lastLat, a.lastLng);
            final distB = _calculateDistance(lat, lng, b.lastLat, b.lastLng);

            if (distA == null && distB == null) return _defaultSort(a, b);
            if (distA == null) return 1;
            if (distB == null) return -1;

            return distA.compareTo(distB);
          });
      }

      // 2. Otherwise use the standard Operational Ranking (Status -> Battery -> Name)
      sorted.sort(_defaultSort);
      return sorted;
    });
  }

  int _defaultSort(Rider a, Rider b) {
    // Status Weighting
    int statusScore(Rider r) {
      return switch (r.status) {
        RiderStatus.ONLINE => 0,
        RiderStatus.BUSY => 1,
        RiderStatus.OFFLINE => 2,
      };
    }

    final statusComp = statusScore(a).compareTo(statusScore(b));
    if (statusComp != 0) return statusComp;

    // Battery Weighting (Favor higher battery)
    final batteryComp = (b.batteryLevel ?? 0).compareTo(a.batteryLevel ?? 0);
    if (batteryComp != 0) return batteryComp;

    // Lexical Tie-break
    return a.fullName.compareTo(b.fullName);
  }

  /// Haversine formula to calculate distance in KM
  double? _calculateDistance(
    double lat1,
    double lon1,
    double? lat2,
    double? lon2,
  ) {
    if (lat2 == null || lon2 == null) return null;
    const r = 6371.0;
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLon = (lon2 - lon1) * (pi / 180);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180)) *
            cos(lat2 * (pi / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}
