import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logistix/app/domain/entities/rider_data.dart';
import 'package:logistix/features/rider/domain/repository/rider_repo.dart';
import 'package:logistix/features/rider/infrastructure/repository/mock_rider_repo_impl.dart';

final _riderRepoProvider = Provider<RiderRepo>((ref) => RandomRiderRepoImpl());

final trackRiderProvider = StreamProvider.autoDispose.family((
  ref,
  RiderData arg,
) {
  return ref.read(_riderRepoProvider).listenToRiderCoordinates(arg);
});
