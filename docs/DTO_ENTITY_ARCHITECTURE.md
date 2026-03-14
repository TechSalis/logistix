# DTO and Entity Architecture

## Overview
The codebase now follows a clean separation between data transfer objects (DTOs) and domain entities:

- **DTOs** (`shared/lib/src/data/models/`): Handle JSON serialization/deserialization in the data layer
- **Entities** (`shared/lib/src/domain/entities/`): Pure domain objects used throughout the application

## Architecture Pattern

```
GraphQL Response (JSON)
    ↓
DTO.fromJson() → DTO
    ↓
DTO.toEntity() → Entity
    ↓
Domain Layer (Use Cases, Repositories)
    ↓
Presentation Layer (BLoCs, UI)
```

## Implementation

### Data Layer (Datasources)
Datasources receive JSON from GraphQL and convert to DTOs, then immediately convert to entities:

```dart
// ❌ OLD: Direct entity parsing
final List<dynamic> ordersData = result.data?['orders'] ?? [];
return ordersData.map((json) => Order.fromJson(json)).toList();

// ✅ NEW: DTO → Entity conversion
final List<dynamic> ordersData = result.data?['orders'] ?? [];
return ordersData
    .map((json) => OrderDto.fromJson(json).toEntity())
    .toList();
```

### Domain Layer (Entities)
Entities no longer have `fromJson` methods - they are pure domain objects:

```dart
// ❌ OLD: Entity with JSON parsing
@freezed
abstract class Order with _$Order {
  const factory Order({...}) = _Order;
  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

// ✅ NEW: Pure entity
@freezed
abstract class Order with _$Order {
  const factory Order({...}) = _Order;
}
```

### DTOs
DTOs handle JSON parsing and conversion to entities:

```dart
@freezed
class OrderDto with _$OrderDto {
  const OrderDto._();

  const factory OrderDto({
    required String id,
    String? createdAt,  // String from JSON
  }) = _OrderDto;

  factory OrderDto.fromJson(Map<String, dynamic> json) => _$OrderDtoFromJson(json);

  Order toEntity() => Order(
    id: id,
    createdAt: createdAt != null ? DateTime.tryParse(createdAt!) : null,
  );
}
```

## Benefits

1. **Separation of Concerns**: Data layer handles serialization, domain layer stays pure
2. **Type Safety**: DTOs can have different types than entities (e.g., String dates → DateTime)
3. **Flexibility**: Easy to change JSON structure without affecting domain logic
4. **Testability**: Domain entities don't depend on JSON serialization
5. **Clean Architecture**: Clear boundary between data and domain layers

## Files Modified

### Shared Package
- Created: `user_dto.dart`, `order_dto.dart`, `rider_dto.dart`, `metrics_dto.dart`
- Modified: `user.dart`, `order.dart`, `rider.dart`, `metrics.dart` (removed fromJson)
- Updated: `shared.dart` (exported DTOs)

### Auth Module
- Modified: `auth_remote_datasource.dart` (uses UserDto)

### Dispatcher Module
- Modified: `order_remote_datasource.dart` (uses OrderDto)
- Modified: `rider_remote_datasource.dart` (uses RiderDto)
- Modified: `metrics_remote_datasource.dart` (uses MetricsDto)

## Code Generation

Run after modifying DTOs or entities:
```bash
cd shared && dart run build_runner build --delete-conflicting-outputs
```
