class GqlFragments {
  static const String orderFields = '''
    id
    companyId
    assignedCompanyId
    riderId
    pickupAddress
    pickupPlaceId
    pickupLat
    pickupLng
    dropOffAddress
    dropOffPlaceId
    dropOffLat
    dropOffLng
    codAmount
    pickupPhone
    dropOffPhone
    description
    trackingNumber
    trackingCode
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
    activeOrders
    unassignedOrders
    assignedOrders
    enRouteOrders
    onlineRidersCount
    busyRidersCount
  ''';

  static const String riderMetricsFields = '''
    totalOrders
    pendingOrders
    deliveredOrders
  ''';

  static const String companyFields = '''
    id
    name
    businessHandle
    logoUrl
    cac
    address
    placeId
    createdAt
    updatedAt
  ''';
}
