/// Dispatcher/Order-specific error codes
abstract class DispatcherErrorCodes {
  /// Order not found
  static const String orderNotFound = 'ORDER_NOT_FOUND';

  /// Order cannot be modified in current state
  static const String orderNotModifiable = 'ORDER_NOT_MODIFIABLE';

  /// Invalid order status transition
  static const String invalidStatusTransition =
      'ORDER_INVALID_STATUS_TRANSITION';

  /// No riders available for assignment
  static const String noRidersAvailable = 'ORDER_NO_RIDERS_AVAILABLE';

  /// Rider not found
  static const String riderNotFound = 'RIDER_NOT_FOUND';

  /// Rider already assigned to another order
  static const String riderAlreadyAssigned = 'RIDER_ALREADY_ASSIGNED';

  /// Invalid delivery address
  static const String invalidAddress = 'ORDER_INVALID_ADDRESS';

  /// Order creation failed
  static const String creationFailed = 'ORDER_CREATION_FAILED';

  /// Order assignment failed
  static const String assignmentFailed = 'ORDER_ASSIGNMENT_FAILED';
}
