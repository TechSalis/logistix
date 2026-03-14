# Quick Reference - Error Handling & Toast Service

## Setup (Do Once)

### 1. Wrap App with ToastServiceProvider

```dart
// In main.dart or app.dart
void main() {
  runApp(
    ToastServiceProvider(
      child: MaterialApp(
        home: HomePage(),
      ),
    ),
  );
}
```

### 2. Initialize Global Error Observer

```dart
void main() async {
  WidgetsBinding.ensureInitialized();

  Bloc.observer = GlobalErrorObserver(
    enableLogging: kDebugMode,
  );

  runApp(const MyApp());
}
```

## Common Usage Patterns

### Show Toasts

```dart
// Success (green)
context.toast.showSuccess('Order created!');

// Error (red)
context.toast.showError('Failed to load');

// Warning (orange)
context.toast.showWarning('Check your input');

// Info (blue)
context.toast.showInfo('Processing...');

// Loading (with manual dismiss)
context.toast.showLoading('Uploading...');
await upload();
context.toast.dismiss();
```

### BLoC Error Handling

```dart
class MyBloc extends Bloc<MyEvent, MyState>
    with BlocErrorHandlerMixin<MyState> {

  Future<void> _onFetch(FetchEvent event, Emitter emit) async {
    await handleResultWithRetry(
      emit,
      operation: () => _useCase(),
      onSuccess: (data) => MyState.loaded(data),
      onError: (error) => MyState.error(error),
      maxRetries: 2,
    );
  }
}
```

### UI Error Display

```dart
BlocListener<MyBloc, MyState>(
  listener: (context, state) {
    state.whenOrNull(
      error: (error) => context.showError(error),
      // Or with retry
      error: (error) => context.showErrorWithRetry(error, () {
        context.read<MyBloc>().add(const MyEvent.retry());
      }),
    );
  },
)
```

### State Definition

```dart
@freezed
class MyState with _$MyState {
  const factory MyState.initial() = _Initial;
  const factory MyState.loading() = _Loading;
  const factory MyState.loaded(Data data) = _Loaded;
  const factory MyState.error(AppError error) = _Error; // ← AppError, not String
}
```

### Creating Errors

```dart
// Network error
throw InfrastructureError.network(
  message: 'No internet connection',
);

// Auth error
throw DomainError.authentication(
  message: 'Invalid credentials',
);

// Not found
throw DomainError.notFound(
  resource: 'Order',
  message: 'Order #123 not found',
);

// Validation error
throw ValidationError(
  message: 'Form validation failed',
  fields: {
    'email': 'Invalid email format',
    'password': 'Too short',
  },
);

// Business rule error
throw DomainError.businessRule(
  code: 'RIDER_OFFLINE',
  message: 'Cannot assign order to offline rider',
);
```

### DataSource Error Handling

```dart
try {
  final result = await _graphql.query(...);

  if (result.hasException) {
    throw ErrorHandler.fromException(result.exception);
  }

  return result.data;
} catch (e, stackTrace) {
  if (e is AppError) rethrow;
  throw ErrorHandler.fromException(e, stackTrace);
}
```

## Cheat Sheet

### Toast Methods

| Method | Color | Use For |
|--------|-------|---------|
| `showSuccess()` | Green | Operations succeeded |
| `showError()` | Red | Operations failed |
| `showWarning()` | Orange | Warnings & cautions |
| `showInfo()` | Blue | Info messages |
| `showLoading()` | Blue | Long operations |
| `showAppError()` | Based on severity | AppError objects |

### Error Categories

| Category | Use For |
|----------|---------|
| `network` | Connectivity issues |
| `authentication` | Login/auth failures |
| `authorization` | Permission denied |
| `validation` | Input validation |
| `server` | Server errors (5xx) |
| `data` | Data format errors |
| `permission` | Device permissions |
| `notFound` | Resource not found |
| `business` | Business logic violations |

### Error Severity

| Severity | Color | Display |
|----------|-------|---------|
| `info` | Blue | Info icon |
| `warning` | Orange | Warning icon |
| `error` | Red | Error icon |
| `critical` | Dark Red | Danger icon |

### Context Extensions

```dart
// Toast service
context.toast                           // Get IToastService
context.toast.showSuccess(msg)          // Show success
context.toast.showError(msg)            // Show error

// Error handling
context.showError(error)                // Show AppError
context.showErrorWithRetry(error, fn)   // Show with retry
context.showErrorDialog(error)          // Show dialog
```

### BLoC Mixin Methods

```dart
// Simple handling
handleResult(result, emit,
  onSuccess: (data) => State.loaded(data),
  onError: (error) => State.error(error),
);

// With loading state
handleResultWithLoading(emit,
  loadingState: const State.loading(),
  operation: () => useCase(),
  onSuccess: (data) => State.loaded(data),
  onError: (error) => State.error(error),
);

// With auto-retry
handleResultWithRetry(emit,
  operation: () => useCase(),
  onSuccess: (data) => State.loaded(data),
  onError: (error) => State.error(error),
  maxRetries: 3,
  retryDelay: Duration(seconds: 2),
);
```

## Migration Patterns

### Replace ScaffoldMessenger

**Before**:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(message),
    backgroundColor: Colors.red,
  ),
);
```

**After**:
```dart
context.toast.showError(message);
```

### Update BLoC

**Before**:
```dart
result.map(
  (error) => emit(State.error( error.message)),
  (data) => emit(State.loaded(data)),
);
```

**After**:
```dart
handleResult(result, emit,
  onSuccess: (data) => State.loaded(data),
  onError: (error) => State.error(error),
);
```

### Update State

**Before**:
```dart
const factory MyState.error(String message) = _Error;
```

**After**:
```dart
const factory MyState.error(AppError error) = _Error;
```

### Update Listener

**Before**:
```dart
state.whenOrNull(
  error: (msg) => ScaffoldMessenger.of(context)
    .showSnackBar(SnackBar(content: Text(msg))),
);
```

**After**:
```dart
state.whenOrNull(
  error: (error) => context.showError(error),
);
```

## Import Statements

```dart
// For toast and error handling
import 'package:shared/shared.dart';

// For AppError definitions
import 'package:bootstrap/definitions/app_error.dart';
```

## Testing

### Mock ToastService

```dart
class MockToastService implements IToastService {
  List<String> messages = [];

  @override
  void showSuccess(String message, {Duration? duration}) {
    messages.add('success: $message');
  }

  @override
  void showError(String message, {Duration? duration}) {
    messages.add('error: $message');
  }

  // ... other methods
}

// In test
final mock = MockToastService();
// ... trigger action
expect(mock.messages, contains('success: Saved!'));
```

## Tips

1. **Always use AppError in states**, not String
2. **Always import shared package** for extensions
3. **Use handleResultWithRetry** for network operations
4. **Set isRetryable correctly** in custom errors
5. **Provide user-friendly messages** in error.message
6. **Use error codes** for tracking and analytics
7. **Test error scenarios** with mock services

## Troubleshooting

### "toast is not defined"
→ Import `package:shared/shared.dart`

### "ToastService not found in context"
→ Wrap app with `ToastServiceProvider`

### "AppError is String, expected AppError"
→ Update state definition to use `AppError` instead of `String`

### "No retry button shows"
→ Set `error.isRetryable = true` when creating error

## Documentation

- Full guides: See `ERROR_HANDLING_GUIDE.md`, `TOAST_SERVICE_IMPLEMENTATION.md`
- Implementation details: See `IMPLEMENTATION_SUMMARY.md`
- This quick reference: For daily use

---

**Need help?** Check the comprehensive guides or search for examples in `OrderBloc` and `CreateOrderPage`.
