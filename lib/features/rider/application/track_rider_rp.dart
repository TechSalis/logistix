import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/features/rider/domain/entities/rider.dart';
import 'package:logistix/features/rider/domain/repository/rider_repo.dart';
import 'package:logistix/features/rider/infrastructure/repository/mock_rider_repo_impl.dart';

final _riderRepoProvider = Provider<RiderRepo>((ref) => RandomRiderRepoImpl());

final trackRiderProvider = StreamProvider.family.autoDispose((ref, Rider arg) {
  return ref.read(_riderRepoProvider).listenToRiderCoordinates(arg);
});
