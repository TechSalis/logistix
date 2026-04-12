# Mobile Implementation Guide

This guide describes how to implement new features and maintain existing ones following the **Zero-Generation** and **Modular** patterns.

---

## 1. Creating a New Feature
A feature typically resides within a **Module** (e.g., `modules/dispatcher`).

### Directory Structure
```
lib/src/features/my_feature/
├── data/
│   ├── datasources/
│   ├── dtos/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── cubit/
    └── widgets/
```

---

## 2. Implementing Data Models (DTOs)
In the Zero-Generation pattern, DTOs must be implemented manually.

### Example DTO
```dart
class MyFeatureDto {
  const MyFeatureDto({required this.id, required this.name});

  final String id;
  final String name;

  factory MyFeatureDto.fromJson(Map<String, dynamic> json) {
    return MyFeatureDto(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  MyFeatureEntity toEntity() => MyFeatureEntity(id: id, name: name);
  
  MyFeatureDto copyWith({String? id, String? name}) {
    return MyFeatureDto(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}
```

---

## 3. State Management (Manual Cubit States)
Avoid `freezed` for states. Use abstract classes and sub-types.

### Example State
```dart
abstract class MyFeatureState {
  const MyFeatureState();
}

class MyFeatureInitial extends MyFeatureState {}
class MyFeatureLoading extends MyFeatureState {}
class MyFeatureLoaded extends MyFeatureState {
  final List<MyEntity> items;
  const MyFeatureLoaded(this.items);
}
class MyFeatureFailure extends MyFeatureState {
  final String error;
  const MyFeatureFailure(this.error);
}
```

---

## 4. Single Source of Truth (SSOT)
The UI should reflect the state of the **Local database**.

1. **Watch**: The Repository should expose a `Stream<List<Entity>>` that watches a Drift query.
2. **Sync**: A UseCase or Component should fetch remote data and update the Local DB.
3. **React**: The BLoC/Cubit listens to the repository stream and emits states. The UI rebuilds automatically when the DB changes.

---

## 5. Dependency Injection & Routing
- Register services, repositories, and usecases in your `Module.registerServices` method.
- Register routes in `Module.routes`.
- Ensure your module is included in `AppInitialization`.

```dart
@override
void registerServices(DI injector) {
  injector.registerLazySingleton<MyRepository>(
    () => MyRepositoryImpl(remoteDataSource: ...),
  );
}
```
