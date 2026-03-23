import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared/shared.dart';

part 'rider_event.freezed.dart';

@freezed
class RiderEvent with _$RiderEvent {
  const factory RiderEvent.fetchProfile() = FetchProfile;
  const factory RiderEvent.watchProfile(String riderId) = WatchProfile;
  const factory RiderEvent.locationUpdated(Position position) = LocationUpdated;
  const factory RiderEvent.statusChanged(RiderStatus status) = StatusChanged;
  const factory RiderEvent.updateRider(Rider? rider) = UpdateRiderEvent;
}
