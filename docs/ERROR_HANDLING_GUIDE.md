# Error Handling Strategy for Logistix

## Overview

This document describes the comprehensive error handling strategy for the Logistix application. The strategy provides:

1. **Structured error types** with categories, severity levels, and metadata
2. **Centralized error conversion** from exceptions to typed errors
3. **Consistent BLoC error handling** with utility mixins
4. **Global error observability** for logging and monitoring
5. **User-friendly error presentation** with UI utilities

## Architecture

### Error Flow

```
Exception/Error
    ↓
ErrorHandler.fromException()
    ↓
Typed AppError (Infrastructure/Domain/Presentation)
    ↓
Repository Result<AppError, T>
    ↓
BLoC with BlocErrorHandlerMixin
    ↓
State with error information
    ↓
UI (SnackBar/Dialog/Widget)
```

## 1. Error Types

### Base: AppError

All errors extend `AppError`, which includes:

- `code`: Error code (e.g., "AUTH_001", "NETWORK_TIMEOUT")
- `message`: Human-readable message
- `severity`: info | warning | error | critical
- `category`: network | authentication | validation | server | data | permission | notFound | business | unknown
- `isRetryable`: Whether the operation can be retried
- `metadata`: Additional context information
- `error`: Original error object (for debugging)
- `stackTrace`: Stack trace (for debugging)

### Error Subclasses

#### InfrastructureError
For network, storage, and external service errors.

**Factory constructors:**
```dart
// Network connectivity error
InfrastructureError.network(message: "No internet connection")

// Timeout error
InfrastructureError.timeout()

// Server error (5xx)
InfrastructureError.server(statusCode: 500)
```

#### DomainError
For business logic and domain-specific errors.

**Factory constructors:**
```dart
// Authentication failure
DomainError.authentication(message: "Invalid credentials")

// Authorization failure
DomainError.authorization(message: "Access denied")

// Resource not found
DomainError.notFound(resource: "Order")

// Business rule violation
DomainError.businessRule(message: "Cannot assign order to offline rider")
```

#### PresentationError
For UI-specific errors.

#### UserVisibleError
For errors that should be displayed to users with custom messages.

```dart
UserVisibleError(message: "Unable to process your request")
```

#### ValidationError
For input validation errors with field-level details.

```dart
ValidationError(
  message: "Form validation failed",
  fields: {
    "email": "Invalid email format",
    "password": "Password too short",
  },
)
```

#### DevicePermissionError
For device permission errors.

```dart
DevicePermissionError("location")
```

## 2. ErrorHandler - Central Error Conversion

The `ErrorHandler` class converts raw exceptions to typed `AppError` instances.

### Usage in DataSources

```dart
class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  @override
  Future<List<OrderDto>> getOrders() async {
    try {
      final result = await _graphql.query(...);

      if (result.hasException) {
        throw ErrorHandler.fromException(result.exception);
      }

      return parseData(result.data);
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.fromException(e, stackTrace);
    }
  }
}
```

### Error Categorization

The `ErrorHandler` automatically categorizes errors:

- **GraphQL errors**: Categorized by error code (AUTH, FORBIDDEN, NOT_FOUND, etc.)
- **Network errors**: SocketException → `InfrastructureError.network()`
- **Timeout errors**: TimeoutException → `InfrastructureError.timeout()`
- **Format errors**: FormatException → `InfrastructureError` with data category
- **Type errors**: TypeError → `InfrastructureError` with data category

## 3. BLoC Error Handling

### Using BlocErrorHandlerMixin

Add the mixin to your BLoC:

```dart
class OrderBloc extends Bloc<OrderEvent, OrderState>
    with BlocErrorHandlerMixin<OrderState> {
  // ...
}
```

### Method 1: handleResult()

For simple success/error handling:

```dart
Future<void> _onFetchOrders(
  FetchOrders event,
  Emitter<OrderState> emit,
) async {
  emit(const OrderState.loading());

  final result = await _getOrdersUseCase();

  handleResult(
    result,
    emit,
    onSuccess: (orders) => OrderState.loaded(orders),
    onError: (error) => OrderState.error(error),
  );
}
```

### Method 2: handleResultWithLoading()

Automatically handles loading state:

```dart
Future<void> _onFetchOrders(
  FetchOrders event,
  Emitter<OrderState> emit,
) async {
  await handleResultWithLoading(
    emit,
    loadingState: const OrderState.loading(),
    operation: () => _getOrdersUseCase(),
    onSuccess: (orders) => OrderState.loaded(orders),
    onError: (error) => OrderState.error(error),
  );
}
```

### Method 3: handleResultWithRetry()

Automatically retries on retryable errors:

```dart
Future<void> _onFetchOrders(
  FetchOrders event,
  Emitter<OrderState> emit,
) async {
  await handleResultWithRetry(
    emit,
    operation: () => _getOrdersUseCase(),
    onSuccess: (orders) => OrderState.loaded(orders),
    onError: (error) => OrderState.error(error),
    maxRetries: 3,
    retryDelay: Duration(seconds: 2),
  );
}
```

## 4. State Design

### Update States to Include AppError

Instead of just storing error messages, store the full `AppError`:

```dart
@freezed
class OrderState with _$OrderState {
  const factory OrderState.initial() = _Initial;
  const factory OrderState.loading() = _Loading;
  const factory OrderState.loaded(List<Order> orders) = _Loaded;
  const factory OrderState.error(AppError error) = _Error;
  const factory OrderState.success() = _Success;
}
```

This preserves error metadata, severity, and retry capability.

## 5. UI Error Handling

### Using UiErrorHandler

#### Show SnackBar

```dart
// In your BlocListener
BlocListener<OrderBloc, OrderState>(
  listener: (context, state) {
    state.whenOrNull(
      error: (error) {
        UiErrorHandler.showErrorSnackBar(context, error);
      },
    );
  },
  // ...
)
```

#### Show SnackBar with Retry

```dart
BlocListener<OrderBloc, OrderState>(
  listener: (context, state) {
    state.whenOrNull(
      error: (error) {
        UiErrorHandler.showErrorSnackBarWithRetry(
          context,
          error,
          onRetry: () {
            context.read<OrderBloc>().add(const OrderEvent.fetchOrders());
          },
        );
      },
    );
  },
  // ...
)
```

#### Show Error Dialog

```dart
state.whenOrNull(
  error: (error) {
    UiErrorHandler.showErrorDialog(context, error);
  },
)
```

#### Build Error Widget

```dart
BlocBuilder<OrderBloc, OrderState>(
  builder: (context, state) {
    return state.when(
      loading: () => CircularProgressIndicator(),
      loaded: (orders) => OrderList(orders),
      error: (error) => UiErrorHandler.buildErrorWidget(
        error,
        onRetry: () {
          context.read<OrderBloc>().add(const OrderEvent.fetchOrders());
        },
      ),
      initial: () => SizedBox(),
    );
  },
)
```

#### Using BuildContext Extension

```dart
// Show error SnackBar
context.showError(error);

// Show error SnackBar with retry
context.showErrorWithRetry(error, () {
  // Retry logic
});

// Show error dialog
await context.showErrorDialog(error);
```

## 6. Global Error Observation

### Setup in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize global error observer
  Bloc.observer = GlobalErrorObserver(
    onErrorCallback: (error, stackTrace) {
      // Send to error tracking service
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);
      // Sentry.captureException(error, stackTrace: stackTrace);
    },
    enableLogging: kDebugMode, // Only log in debug mode
  );

  runApp(const MyApp());
}
```

## 7. Migration Guide

### Step 1: Update State Definitions

**Before:**
```dart
const factory OrderState.error(String message) = _Error;
```

**After:**
```dart
const factory OrderState.error(AppError error) = _Error;
```

### Step 2: Update BLoC to Use Mixin

**Before:**
```dart
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  Future<void> _onFetchOrders(...) async {
    emit(const OrderState.loading());
    final result = await _getOrdersUseCase();
    result.map(
      (error) => emit(OrderState.error( error.message)),
      (orders) => emit(OrderState.loaded(orders)),
    );
  }
}
```

**After:**
```dart
class OrderBloc extends Bloc<OrderEvent, OrderState>
    with BlocErrorHandlerMixin<OrderState> {
  Future<void> _onFetchOrders(...) async {
    await handleResultWithLoading(
      emit,
      loadingState: const OrderState.loading(),
      operation: () => _getOrdersUseCase(),
      onSuccess: (orders) => OrderState.loaded(orders),
      onError: (error) => OrderState.error(error),
    );
  }
}
```

### Step 3: Update UI Error Display

**Before:**
```dart
BlocListener<OrderBloc, OrderState>(
  listener: (context, state) {
    state.whenOrNull(
      error: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  },
)
```

**After:**
```dart
BlocListener<OrderBloc, OrderState>(
  listener: (context, state) {
    state.whenOrNull(
      error: (error) {
        UiErrorHandler.showErrorSnackBarWithRetry(
          context,
          error,
          onRetry: () {
            context.read<OrderBloc>().add(const OrderEvent.fetchOrders());
          },
        );
      },
    );
  },
)
```

## 8. Best Practices

### DO:
- ✅ Use specific error subclasses (InfrastructureError, DomainError)
- ✅ Include error codes for tracking and debugging
- ✅ Set `isRetryable` correctly based on error type
- ✅ Use `BlocErrorHandlerMixin` for consistency
- ✅ Store full `AppError` in states, not just strings
- ✅ Show retry option for retryable errors
- ✅ Use appropriate error severity levels
- ✅ Provide user-friendly error messages

### DON'T:
- ❌ Convert errors to strings too early (use `error.userMessage` in UI)
- ❌ Catch errors without proper categorization
- ❌ Ignore silent failures (always emit error state)
- ❌ Display technical error details to users
- ❌ Mark non-retryable errors as retryable
- ❌ Use generic "An error occurred" messages when you can be more specific

## 9. Testing

### Testing Error Handling in BLoCs

```dart
blocTest<OrderBloc, OrderState>(
  'emits error state when fetch fails',
  build: () {
    when(() => mockGetOrdersUseCase())
      .thenAnswer((_) async => Result.error(
        InfrastructureError.network(
          message: 'Network error',
        ),
      ));
    return OrderBloc(mockGetOrdersUseCase);
  },
  act: (bloc) => bloc.add(const OrderEvent.fetchOrders()),
  expect: () => [
    const OrderState.loading(),
    isA<OrderState>().having(
      (state) => state.maybeMap(
        error: (state) => state.error.category,
        orElse: () => null,
      ),
      'error category',
      ErrorCategory.network,
    ),
  ],
);
```

## 10. Error Tracking Integration

### Sentry Example

```dart
// In GlobalErrorObserver initialization
Bloc.observer = GlobalErrorObserver(
  onErrorCallback: (error, stackTrace) {
    if (error is AppError) {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          'error_code': error.code,
          'category': error.category.toString(),
          'severity': error.severity.toString(),
          'is_retryable': error.isRetryable,
          'metadata': error.metadata,
        }),
      );
    } else {
      Sentry.captureException(error, stackTrace: stackTrace);
    }
  },
  enableLogging: kDebugMode,
);
```

### Firebase Crashlytics Example

```dart
Bloc.observer = GlobalErrorObserver(
  onErrorCallback: (error, stackTrace) {
    if (error is AppError) {
      FirebaseCrashlytics.instance
        ..setCustomKey('error_code', error.code ?? 'UNKNOWN')
        ..setCustomKey('error_category', error.category.toString())
        ..setCustomKey('error_severity', error.severity.toString())
        ..recordError(error, stackTrace);
    } else {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  },
  enableLogging: kDebugMode,
);
```

## Summary

This error handling strategy provides:

1. **Type safety**: Compile-time guarantees about error handling
2. **Consistency**: Same error handling pattern across all BLoCs
3. **Observability**: Centralized logging and monitoring
4. **User experience**: Context-aware error messages with retry options
5. **Maintainability**: Easy to extend with new error types
6. **Debugging**: Preserved error context and stack traces
