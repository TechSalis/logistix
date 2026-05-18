import 'package:dispatcher/src/features/deliveries/data/dtos/assign_delivery_request.dart';
import 'package:dispatcher/src/features/deliveries/data/dtos/delivery_create_input.dart';
import 'package:dispatcher/src/features/deliveries/data/dtos/update_delivery_status_request.dart';
import 'package:shared/shared.dart';

abstract class DeliveryRemoteDataSource {
  Future<List<DeliveryDto>> createBulkDeliveries(List<DeliveryCreateInput> deliveries);
  Future<DeliveryDto> updateDeliveryStatus(UpdateDeliveryStatusRequest request);
  Future<DeliveryDto> rejectDelivery(String deliveryId);
  Future<DeliveryDto> assignDelivery(AssignDeliveryRequest request);
  Future<List<DeliveryCreateInput>> parseTextToDeliveries(String text);
}

class DeliveryRemoteDataSourceImpl extends BaseRemoteDataSource
    implements DeliveryRemoteDataSource {
  DeliveryRemoteDataSourceImpl(super.gqlService);

  @override
  Future<DeliveryDto> updateDeliveryStatus(UpdateDeliveryStatusRequest request) async {
    const mutation =
        '''
      mutation UpdateDeliveryStatus(\$deliveryId: ID!, \$status: String!, \$sessionId: String) {
        updateDeliveryStatus(deliveryId: \$deliveryId, status: \$status, sessionId: \$sessionId) {
          ${GqlFragments.deliveryFields}
        }
      }
    ''';

    final data = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'updateDeliveryStatus',
      variables: {
        ...request.toJson(),
        if (request.sessionId == null)
          'sessionId': await gqlService.sessionId,
      },
    );

    return DeliveryDto.fromJson(data);
  }

  @override
  Future<DeliveryDto> rejectDelivery(String deliveryId) async {
    const mutation =
        '''
      mutation RejectDelivery(\$deliveryId: ID!, \$sessionId: String) {
        rejectDelivery(deliveryId: \$deliveryId, sessionId: \$sessionId) {
          ${GqlFragments.deliveryFields}
        }
      }
    ''';

    final data = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'rejectDelivery',
      variables: {
        'deliveryId': deliveryId,
        'sessionId': await gqlService.sessionId,
      },
    );

    return DeliveryDto.fromJson(data);
  }

  @override
  Future<DeliveryDto> assignDelivery(AssignDeliveryRequest request) async {
    const mutation =
        '''
      mutation AssignDelivery(\$deliveryId: ID!, \$riderId: ID!, \$sessionId: String) {
        assignDelivery(deliveryId: \$deliveryId, riderId: \$riderId, sessionId: \$sessionId) {
          ${GqlFragments.deliveryFields}
        }
      }
    ''';

    final data = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'assignDelivery',
      variables: {
        ...request.toJson(),
        if (request.sessionId == null)
          'sessionId': await gqlService.sessionId,
      },
    );

    return DeliveryDto.fromJson(data);
  }

  @override
  Future<List<DeliveryDto>> createBulkDeliveries(List<DeliveryCreateInput> deliveries) async {
    const mutation =
        '''
      mutation CreateBulkDeliveries(\$deliveries: [DeliveryCreateInput!]!, \$sessionId: String) {
        createBulkDeliveries(deliveries: \$deliveries, sessionId: \$sessionId) {
          ${GqlFragments.deliveryFields}
        }
      }
    ''';

    final data = await mutate<List<dynamic>>(
      mutation,
      key: 'createBulkDeliveries',
      variables: {
        'deliveries': deliveries.map((o) => o.toJson()).toList(),
        'sessionId': await gqlService.sessionId,
      },
    );

    return data
        .map((json) => DeliveryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<DeliveryCreateInput>> parseTextToDeliveries(String text) async {
    const mutation = r'''
      mutation ParseDeliveries($text: String!) {
        parseDeliveries(text: $text) {
          deliveries {
            pickupAddress
            dropOffAddress
            pickupPhone
            dropOffPhone
            price
            description
          }
        }
      }
    ''';

    final result = await mutate<Map<String, dynamic>>(
      mutation,
      key: 'parseDeliveries',
      variables: {'text': text},
    );

    final deliveries = result['deliveries'] as List<dynamic>;
    return deliveries
        .map((o) => DeliveryCreateInput.fromJson(o as Map<String, dynamic>))
        .toList();
  }
}
