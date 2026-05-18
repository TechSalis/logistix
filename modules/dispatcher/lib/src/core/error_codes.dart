/// Dispatcher/Delivery-specific error codes
abstract class DispatcherErrorCodes {
  /// Delivery not found
  static const String deliveryNotFound = 'DELIVERY_NOT_FOUND';

  /// Delivery cannot be modified in current state
  static const String deliveryNotModifiable = 'DELIVERY_NOT_MODIFIABLE';

  /// Invalid delivery status transition
  static const String invalidStatusTransition =
      'DELIVERY_INVALID_STATUS_TRANSITION';

  /// No riders available for assignment
  static const String noRidersAvailable = 'DELIVERY_NO_RIDERS_AVAILABLE';

  /// Rider not found
  static const String riderNotFound = 'RIDER_NOT_FOUND';

  /// Rider already assigned to another delivery
  static const String riderAlreadyAssigned = 'RIDER_ALREADY_ASSIGNED';

  /// Invalid delivery address
  static const String invalidAddress = 'DELIVERY_INVALID_ADDRESS';

  /// Delivery creation failed
  static const String creationFailed = 'DELIVERY_CREATION_FAILED';

  /// Delivery assignment failed
  static const String assignmentFailed = 'DELIVERY_ASSIGNMENT_FAILED';
}
