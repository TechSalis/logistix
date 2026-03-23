import 'package:dispatcher/src/domain/repositories/rider_repository.dart';
import 'package:shared/shared.dart';

class SearchRidersUseCase {
  SearchRidersUseCase(this._repository);
  final RiderRepository _repository;

  Future<List<Rider>> call(String query) async {
    final result = await _repository.getRiders(searchQuery: query);
    return result.map((err) => [], (list) {
      // Logic Upgrade: Implement ranking algorithm for selection priority
      // We sort by: 1. Status (ONLINE -> BUSY -> OFFLINE), 2. Battery (Higher first), 3. Name (A-Z)
      final sorted = List<Rider>.from(list)
        ..sort((a, b) {
        // Status Weighting
        int statusScore(Rider r) {
          return switch (r.status) {
            RiderStatus.online => 0,
            RiderStatus.busy => 1,
            RiderStatus.offline => 2,
          };
        }

        final statusComp = statusScore(a).compareTo(statusScore(b));
        if (statusComp != 0) return statusComp;

        // Battery Weighting (Favor higher battery)
        final batteryComp = (b.batteryLevel ?? 0).compareTo(a.batteryLevel ?? 0);
        if (batteryComp != 0) return batteryComp;

        // Lexical Tie-break
        return a.fullName.compareTo(b.fullName);
      });
      return sorted;
    });
  }
}
