# BlocProvider and RepositoryProvider Architecture

## Overview
Refactored modules to use BlocProvider and RepositoryProvider instead of global DI registration for local services.

## Key Changes

### 1. Global vs Local Services
- **Global Services** (registered in DI): Services used across multiple modules
  - `AuthBloc` - used by rider and dispatcher modules
  - `GraphQLService` - used by all modules
  - `TokenStore` - used by auth and network layer
  
- **Local Services** (provided via BlocProvider/RepositoryProvider): Module-specific services
  - `OrderBloc`, `RiderBloc`, `MetricsBloc` - dispatcher module only
  - Repositories, DataSources, UseCases - module-specific

### 2. ShellRoute Pattern
Modules now use ShellRoute to provide dependencies to all child routes:

```dart
ShellRoute(
  builder: (context, state, child) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<OrderRepository>(...),
      // ... other repositories
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider<OrderBloc>(...),
        // ... other blocs
      ],
      child: child,
    ),
  ),
  routes: [
    GoRoute(path: rootPath, builder: ...),
    // ... nested routes
  ],
)
```

### 3. Context-Based Access
Pages now use `context.read<T>()` and `context.watch<T>()` instead of constructor injection:

```dart
// ❌ OLD: Constructor injection
class MyPage extends StatelessWidget {
  final MyBloc myBloc;
  const MyPage({required this.myBloc});
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBloc, MyState>(
      bloc: myBloc,
      builder: (context, state) { ... }
    );
  }
}

// ✅ NEW: Context-based access
class MyPage extends StatelessWidget {
  const MyPage();
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyBloc, MyState>(
      builder: (context, state) { ... }
    );
  }
  
  void _someAction() {
    context.read<MyBloc>().add(SomeEvent());
  }
}
```

### 4. Private Path Constants
Module paths now use private constants for nested routes:

```dart
class DispatcherModule extends Module<RouteBase> {
  static const String rootPath = '/dispatcher';
  static const String _orders = 'orders';
  static const String _createOrder = 'create-order';
  static const String ordersPath = '$rootPath/$_orders';
  static const String createOrderPath = '$rootPath/$_createOrder';
}
```

## Files Modified

### Dispatcher Module
- `dispatcher_module.dart` - Uses ShellRoute with providers, removed DI registration
- `dispatcher_dashboard_page.dart` - Uses `context.read<T>()`
- `order_list_page.dart` - Uses `context.read<T>()`
- `create_order_page.dart` - Uses `context.read<T>()`

### Rider Module
- `rider_module.dart` - Removed DI registration (uses global AuthBloc and OrderBloc from dispatcher)
- `rider_dashboard_page.dart` - Uses `context.read<T>()`

### Auth Module
- `auth_module.dart` - Keeps AuthBloc in DI (used globally)

## Benefits

1. **Clear Separation**: Global vs local dependencies are explicit
2. **Better Scoping**: Blocs are scoped to their module's routes
3. **Automatic Disposal**: BlocProvider handles bloc disposal
4. **Testability**: Easier to provide mock dependencies in tests
5. **Type Safety**: Compile-time errors if dependencies not provided
6. **Less Boilerplate**: No need to pass blocs through constructors

## Testing Strategy

```dart
testWidgets('test page', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<OrderRepository>(create: (_) => mockRepo),
        ],
        child: BlocProvider<OrderBloc>(
          create: (_) => mockBloc,
          child: OrderListPage(),
        ),
      ),
    ),
  );
});
```
