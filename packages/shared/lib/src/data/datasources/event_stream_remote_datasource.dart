import 'package:shared/shared.dart';

abstract class EventStreamRemoteDataSource {
  /// Subscribe to dispatcher events for a company
  Stream<Map<String, dynamic>> subscribeToDispatcherEvents(String companyId);

  /// Subscribe to rider events for a rider
  Stream<Map<String, dynamic>> subscribeToRiderEvents(String riderId);
}

class EventStreamRemoteDataSourceImpl implements EventStreamRemoteDataSource {
  const EventStreamRemoteDataSourceImpl(this._graphQLService);
  final GraphQLService _graphQLService;

  @override
  Stream<Map<String, dynamic>> subscribeToDispatcherEvents(String companyId) {
    const subscription = r'''
      subscription DispatcherEvents($companyId: ID!) {
        dispatcherEvents(companyId: $companyId) {
          __typename
          timestamp
          ... on OrderCreatedEvent {
            order {
              id
              companyId
              riderId
              pickupAddress
              dropOffAddress
              items
              codAmount
              sequenceNumber
              trackingNumber
              status
              deliveredAt
              createdAt
              updatedAt
            }
          }
          ... on OrderUpdatedEvent {
            order {
              id
              companyId
              riderId
              pickupAddress
              dropOffAddress
              items
              codAmount
              sequenceNumber
              trackingNumber
              status
              deliveredAt
              createdAt
              updatedAt
            }
          }
          ... on RiderLocationUpdatedEvent {
            riderId
            lat
            lng
            batteryLevel
          }
          ... on RiderStatusChangedEvent {
            riderId
            status
          }
          ... on MetricsUpdatedEvent {
            metrics {
              totalOrders
              pendingOrders
              inProgressOrders
              deliveredOrders
              onlineRiders
              codExpectedToday
            }
          }
        }
      }
    ''';

    return _graphQLService
        .subscribe(subscription, variables: {'companyId': companyId})
        .handleError((Object error) {
          // Log error but don't terminate stream
          // ignore: avoid_print
          print('Dispatcher subscription error: $error');
        })
        .map((result) {
          if (result.hasException) {
            // Return empty map instead of throwing to prevent stream termination
            return <String, dynamic>{};
          }

          return result.data?['dispatcherEvents'] as Map<String, dynamic>? ??
              {};
        })
        .where((event) => event.isNotEmpty);  // Filter out empty events
  }

  @override
  Stream<Map<String, dynamic>> subscribeToRiderEvents(String riderId) {
    const subscription = r'''
      subscription RiderEvents($riderId: ID!) {
        riderEvents(riderId: $riderId) {
          __typename
          timestamp
          ... on OrderAssignedEvent {
            order {
              id
              companyId
              riderId
              pickupAddress
              dropOffAddress
              items
              codAmount
              sequenceNumber
              trackingNumber
              status
              deliveredAt
              createdAt
              updatedAt
            }
          }
          ... on OrderUpdatedEvent {
            order {
              id
              companyId
              riderId
              pickupAddress
              dropOffAddress
              items
              codAmount
              sequenceNumber
              trackingNumber
              status
              deliveredAt
              createdAt
              updatedAt
            }
          }
          ... on OrderUnassignedEvent {
            orderId
            reason
          }
          ... on StatusChangeRequestEvent {
            newStatus
            reason
          }
          ... on RiderMetricsUpdatedEvent {
            metrics {
              totalOrders
              assignedOrders
              enRouteOrders
              deliveredOrders
              cancelledOrders
            }
          }
        }
      }
    ''';

    return _graphQLService
        .subscribe(subscription, variables: {'riderId': riderId})
        .handleError((Object error) {
          // Log error but don't terminate stream
          // ignore: avoid_print
          print('Rider subscription error: $error');
        })
        .map((result) {
          if (result.hasException) {
            // Return empty map instead of throwing to prevent stream termination
            return <String, dynamic>{};
          }
          return result.data?['riderEvents'] as Map<String, dynamic>? ?? {};
        })
        .where((event) => event.isNotEmpty);  // Filter out empty events
  }
}
