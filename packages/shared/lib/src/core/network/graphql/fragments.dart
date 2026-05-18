class GqlFragments {
  static const String deliveryFields = '''
    id
    companyId
    riderId
    pickupAddress
    pickupPlaceId
    pickupLat
    pickupLng
    dropOffAddress
    dropOffPlaceId
    dropOffLat
    dropOffLng
    price
    paymentMethod
    pickupPhone
    dropOffPhone
    description
    trackingNumber
    pin
    status
    deliveredAt
    scheduledAt
    createdAt
    updatedAt
  ''';

  static const String riderFields = '''
    id
    email
    fullName
    phoneNumber
    companyId
    status
    lastLat
    lastLng
    batteryLevel
    isAccepted
    permitStatus
    createdAt
    updatedAt
  ''';

  static const String dispatcherMetricsFields = '''
    activeDeliveries
    unassignedDeliveries
    assignedDeliveries
    enRouteDeliveries
    onlineRidersCount
    busyRidersCount
  ''';

  static const String riderMetricsFields = '''
    totalDeliveries
    pendingDeliveries
    deliveredDeliveries
  ''';

  static const String companyFields = '''
    id
    name
    businessHandle
    logoUrl
    cac
    address
    placeId
    config {
      tier
    }
    createdAt
    updatedAt
  ''';

  static const String userFields = '''
    id
    email
    fullName
    role
    phoneNumber
    isOnboarded
    companyId
    riderProfile {
      $riderFields
    }
    companyProfile {
      $companyFields
    }
    createdAt
    updatedAt
  ''';
}
