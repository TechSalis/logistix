import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

part 'customer_sync_dto.freezed.dart';
part 'customer_sync_dto.g.dart';

@freezed
abstract class CustomerSyncDto with _$CustomerSyncDto {
  const factory CustomerSyncDto({
    required List<OrderDto> orders,
    required int lastUpdated,
    @Default([]) List<String> deletedOrderIds,
  }) = _CustomerSyncDto;

  factory CustomerSyncDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerSyncDtoFromJson(json);
}
