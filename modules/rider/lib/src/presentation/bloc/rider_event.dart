import 'package:geolocator/geolocator.dart';
import 'package:shared/shared.dart';

abstract class RiderEvent {
  const RiderEvent();

  static RiderEvent fetchProfile() => const FetchProfile();
  static RiderEvent observeProfile(String riderId) => ObserveProfile(riderId);
  static RiderEvent locationUpdated(Position position) => LocationUpdated(position);
  static RiderEvent statusChanged(RiderStatus status) => StatusChanged(status);
  static RiderEvent updateRider(Rider? rider) => UpdateRiderEvent(rider);
  static RiderEvent deactivateAccount() => const DeactivateAccountEvent();

  T map<T>({
    required T Function(FetchProfile) fetchProfile,
    required T Function(ObserveProfile) observeProfile,
    required T Function(LocationUpdated) locationUpdated,
    required T Function(StatusChanged) statusChanged,
    required T Function(UpdateRiderEvent) updateRider,
    required T Function(DeactivateAccountEvent) deactivateAccount,
  });
}

class FetchProfile extends RiderEvent {
  const FetchProfile();
  @override
  T map<T>({
    required T Function(FetchProfile) fetchProfile,
    required T Function(ObserveProfile) observeProfile,
    required T Function(LocationUpdated) locationUpdated,
    required T Function(StatusChanged) statusChanged,
    required T Function(UpdateRiderEvent) updateRider,
    required T Function(DeactivateAccountEvent) deactivateAccount,
  }) => fetchProfile(this);
}

class ObserveProfile extends RiderEvent {
  const ObserveProfile(this.riderId);
  final String riderId;
  @override
  T map<T>({
    required T Function(FetchProfile) fetchProfile,
    required T Function(ObserveProfile) observeProfile,
    required T Function(LocationUpdated) locationUpdated,
    required T Function(StatusChanged) statusChanged,
    required T Function(UpdateRiderEvent) updateRider,
    required T Function(DeactivateAccountEvent) deactivateAccount,
  }) => observeProfile(this);
}

class LocationUpdated extends RiderEvent {
  const LocationUpdated(this.position);
  final Position position;
  @override
  T map<T>({
    required T Function(FetchProfile) fetchProfile,
    required T Function(ObserveProfile) observeProfile,
    required T Function(LocationUpdated) locationUpdated,
    required T Function(StatusChanged) statusChanged,
    required T Function(UpdateRiderEvent) updateRider,
    required T Function(DeactivateAccountEvent) deactivateAccount,
  }) => locationUpdated(this);
}

class StatusChanged extends RiderEvent {
  const StatusChanged(this.status);
  final RiderStatus status;
  @override
  T map<T>({
    required T Function(FetchProfile) fetchProfile,
    required T Function(ObserveProfile) observeProfile,
    required T Function(LocationUpdated) locationUpdated,
    required T Function(StatusChanged) statusChanged,
    required T Function(UpdateRiderEvent) updateRider,
    required T Function(DeactivateAccountEvent) deactivateAccount,
  }) => statusChanged(this);
}

class UpdateRiderEvent extends RiderEvent {
  const UpdateRiderEvent(this.rider);
  final Rider? rider;
  @override
  T map<T>({
    required T Function(FetchProfile) fetchProfile,
    required T Function(ObserveProfile) observeProfile,
    required T Function(LocationUpdated) locationUpdated,
    required T Function(StatusChanged) statusChanged,
    required T Function(UpdateRiderEvent) updateRider,
    required T Function(DeactivateAccountEvent) deactivateAccount,
  }) => updateRider(this);
}

class DeactivateAccountEvent extends RiderEvent {
  const DeactivateAccountEvent();
  @override
  T map<T>({
    required T Function(FetchProfile) fetchProfile,
    required T Function(ObserveProfile) observeProfile,
    required T Function(LocationUpdated) locationUpdated,
    required T Function(StatusChanged) statusChanged,
    required T Function(UpdateRiderEvent) updateRider,
    required T Function(DeactivateAccountEvent) deactivateAccount,
  }) => deactivateAccount(this);
}
