# Toast Service Implementation Guide

## Overview

I've implemented a comprehensive toast notification system that replaces `ScaffoldMessenger` with a more flexible, customizable, and testable `IToastService` architecture.

## What Was Implemented

### 1. **IToastService Interface** ✅
**Location**: `shared/lib/src/core/services/toast/i_toast_service.dart`

Abstract interface defining toast operations:
- `showSuccess(message)` - Green success toasts
- `showError(message)` - Red error toasts
- `showWarning(message)` - Orange warning toasts
- `showInfo(message)` - Blue info toasts
- `showToast(message, type, ...)` - Generic toast with custom type
- `showAppError(AppError, onRetry)` - Show AppError with retry action
- `showLoading(message)` - Loading toast (remains until dismissed)
- `dismiss()` - Dismiss current toast

### 2. **ToastService Implementation** ✅
**Location**: `shared/lib/src/core/services/toast/toast_service.dart`

Concrete implementation using Flutter Overlay:
- Overlay-based toasts (not tied to Scaffold)
- Automatic error severity mapping
- Retry action support for retryable errors
- Auto-dismiss with configurable duration
- Single toast at a time (new toast dismisses previous)

### 3. **AppToast Widget** ✅
**Location**: `shared/lib/src/core/services/toast/widgets/app_toast.dart`

Generic, reusable toast widget with:
- **Smooth animations**: Fade + slide from top
- **Severity-based styling**: Different colors for success/error/warning/info
- **Action buttons**: Optional action buttons with callbacks
- **Loading indicator**: Shows spinner instead of icon
- **Dismiss button**: Manual dismissal
- **Tap handling**: Optional tap callbacks
- **Material Design**: Rounded corners, elevation, borders

**Toast Styles**:
| Type    | Icon              | Color   | Background    | Border       |
|---------|-------------------|---------|---------------|--------------|
| Success | check_circle      | Green   | Green.shade50 | Green.shade200 |
| Error   | error             | Red     | Red.shade50   | Red.shade200   |
| Warning | warning_amber     | Orange  | Orange.shade50| Orange.shade200|
| Info    | info              | Blue    | Blue.shade50  | Blue.shade200  |

### 4. **ToastServiceProvider** ✅
**Location**: `shared/lib/src/core/services/toast/toast_service_provider.dart`

Provider widget that makes `IToastService` available throughout the widget tree:
- Uses InheritedWidget pattern
- Manages Overlay lifecycle
- Provides context extensions

**Context Extensions**:
```dart
context.toast                  // Get IToastService
context.toastOrNull            // Get IToastService or null
```

### 5. **Updated UiErrorHandler** ✅
**Location**: `shared/lib/src/core/errors/ui_error_handler.dart`

Enhanced error handler with:
- Primary methods use `IToastService`
- Fallback to SnackBar if ToastService not available
- Legacy methods preserved for compatibility
- Updated context extensions

**New Methods**:
```dart
UiErrorHandler.showError(context, error)
UiErrorHandler.showErrorWithRetry(context, error, onRetry: ...)

// Context extensions (updated)
context.showError(error)               // Uses ToastService
context.showErrorWithRetry(error, onRetry)
```

### 6. **Updated Pages** ✅

**LoginPage**:
- Changed from `ScaffoldMessenger` to `context.toast.showError()`
- TODO: Will be fully functional after AuthState migration to AppError

**CreateOrderPage**:
- Changed success notification to `context.toast.showSuccess()`
- Changed error notification to `context.showError(error)`
- Now properly displays AppError with retry button

## Usage Examples

### Basic Toast Usage

```dart
// Success toast
context.toast.showSuccess('Order created successfully!');

// Error toast
context.toast.showError('Failed to load data');

// Warning toast
context.toast.showWarning('Please check your input');

// Info toast
context.toast.showInfo('Processing your request...');
```

### Toast with Actions

```dart
// Custom action
context.toast.showToast(
  'Connection lost',
  type: ToastType.warning,
  actionLabel: 'Reconnect',
  onAction: () {
    // Reconnect logic
  },
);
```

### Loading Toast

```dart
// Show loading
context.toast.showLoading('Uploading file...');

// Dismiss when done
await uploadFile();
context.toast.dismiss();
```

### AppError Integration

```dart
// In BlocListener
BlocListener<OrderBloc, OrderState>(
  listener: (context, state) {
    state.whenOrNull(
      error: (error) {
        // Automatically shows retry button if error.isRetryable
        context.showError(error);

        // Or with explicit retry
        context.showErrorWithRetry(error, () {
          context.read<OrderBloc>().add(const OrderEvent.fetchOrders());
        });
      },
      success: () {
        context.toast.showSuccess('Operation successful!');
      },
    );
  },
)
```

### Direct IToastService Usage

```dart
// Get service
final toast = context.toast;

// Show AppError with retry
toast.showAppError(
  error,
  onRetry: () {
    // Retry logic
  },
);

// Manual control
toast.showLoading('Processing...');
await doWork();
toast.dismiss();
toast.showSuccess('Done!');
```

## Setup Instructions

### 1. Wrap Your App with ToastServiceProvider

**In your main app file** (e.g., `lib/main.dart` or where you have MaterialApp):

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastServiceProvider(
      child: MaterialApp(
        title: 'Logistix',
        home: YourHomePage(),
      ),
    );
  }
}
```

**Or with GoRouter**:

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastServiceProvider(
      child: MaterialApp.router(
        title: 'Logistix',
        routerConfig: _router,
      ),
    );
  }
}
```

### 2. Import shared Package

In pages that use toasts:

```dart
import 'package:shared/shared.dart';
```

This gives you access to:
- `IToastService`
- `ToastServiceProvider`
- `context.toast` extension
- `context.showError()` extension
- All error handling utilities

### 3. Replace ScaffoldMessenger Calls

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

**Or for success**:
```dart
context.toast.showSuccess(message);
```

### 4. Update BlocListeners

**Before**:
```dart
BlocListener<OrderBloc, OrderState>(
  listener: (context, state) {
    state.whenOrNull(
      error: (msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $msg')),
      ),
    );
  },
)
```

**After**:
```dart
BlocListener<OrderBloc, OrderState>(
  listener: (context, state) {
    state.whenOrNull(
      error: (error) => context.showError(error),
      // or with retry
      error: (error) => context.showErrorWithRetry(error, () {
        // Retry logic
      }),
    );
  },
)
```

## Architecture Benefits

### 1. **Separation of Concerns**
- Toast logic separated from UI code
- Easy to swap implementations (e.g., for different platforms)
- Clean interface for testing

### 2. **Type Safety**
- `ToastType` enum prevents typos
- Proper error handling with `AppError` integration
- Compile-time checks

### 3. **Testability**
```dart
// Mock for tests
class MockToastService implements IToastService {
  List<String> shownMessages = [];

  @override
  void showSuccess(String message, {Duration? duration}) {
    shownMessages.add(message);
  }

  // ... other methods
}

// In tests
testWidgets('shows success toast on save', (tester) async {
  final mockToast = MockToastService();

  await tester.pumpWidget(
    ToastServiceProvider(
      toastService: mockToast, // Inject mock
      child: MyWidget(),
    ),
  );

  // ... trigger action

  expect(mockToast.shownMessages, contains('Saved successfully!'));
});
```

### 4. **Consistency**
- Same look and feel across the app
- Standardized animations and behavior
- Centralized styling

### 5. **Flexibility**
- Not tied to Scaffold (works anywhere)
- Supports custom actions and callbacks
- Configurable duration and styling

### 6. **Integration with Error Strategy**
- Works seamlessly with `AppError`
- Automatic retry button for retryable errors
- Severity-based color coding
- User-friendly messages

## Migration Checklist

### Pages to Update

- [x] `modules/auth/lib/src/presentation/pages/login_page.dart` - Updated (pending AuthState migration)
- [x] `modules/dispatcher/lib/src/presentation/pages/create_order_page.dart` - Updated
- [ ] `modules/dispatcher/lib/src/presentation/pages/order_list_page.dart` - Check for ScaffoldMessenger usage
- [ ] `modules/dispatcher/lib/src/presentation/pages/dispatcher_dashboard_page.dart` - Check for ScaffoldMessenger usage
- [ ] `modules/rider/lib/src/presentation/pages/rider_dashboard_page.dart` - Check for ScaffoldMessenger usage
- [ ] Any other pages using `ScaffoldMessenger`

### Setup Tasks

- [ ] Wrap main app with `ToastServiceProvider`
- [ ] Test toast animations and behavior
- [ ] Verify retry buttons work correctly
- [ ] Test loading toasts

### Testing

- [ ] Test success toasts
- [ ] Test error toasts with retry
- [ ] Test warning toasts
- [ ] Test info toasts
- [ ] Test loading toasts with manual dismiss
- [ ] Test toast dismissal on new toast
- [ ] Test toast on different screen sizes
- [ ] Test accessibility (screen readers, etc.)

## File Structure

```
shared/lib/src/core/
├── services/
│   └── toast/
│       ├── i_toast_service.dart           [✅ NEW]
│       ├── toast_service.dart             [✅ NEW]
│       ├── toast_service_provider.dart    [✅ NEW]
│       └── widgets/
│           └── app_toast.dart             [✅ NEW]
└── errors/
    └── ui_error_handler.dart              [✅ UPDATED]

modules/
├── auth/lib/src/presentation/pages/
│   └── login_page.dart                    [✅ UPDATED]
└── dispatcher/lib/src/presentation/pages/
    └── create_order_page.dart             [✅ UPDATED]
```

## Advanced Usage

### Custom Toast Types

You can extend the system with custom toast types:

```dart
// Add to ToastType enum
enum ToastType {
  success,
  error,
  warning,
  info,
  custom, // Add custom type
}

// Update AppToast styling
_ToastConfig _getToastConfig(ToastType type, ThemeData theme) {
  switch (type) {
    case ToastType.custom:
      return _ToastConfig(
        icon: Icons.star,
        iconColor: Colors.purple.shade700,
        backgroundColor: Colors.purple.shade50,
        borderColor: Colors.purple.shade200,
        textColor: Colors.purple.shade900,
      );
    // ... other cases
  }
}
```

### Toast Position

Currently toasts appear at the top. To change position, modify `AppToast`:

```dart
// In AppToast build method
Positioned(
  bottom: 16, // Change from top to bottom
  left: 16,
  right: 16,
  child: // ...
)
```

### Global Toast Interceptor

To log all toasts for analytics:

```dart
class AnalyticsToastService implements IToastService {
  final IToastService _delegate;
  final Analytics _analytics;

  AnalyticsToastService(this._delegate, this._analytics);

  @override
  void showError(String message, {Duration? duration}) {
    _analytics.logEvent('toast_error', {'message': message});
    _delegate.showError(message, duration: duration);
  }

  // ... delegate other methods
}
```

## Comparison: Before vs After

### Before (ScaffoldMessenger)

**Problems**:
- ❌ Tied to Scaffold (requires ScaffoldMessenger in context)
- ❌ Inconsistent styling across app
- ❌ Hard to test
- ❌ No type safety
- ❌ Limited customization
- ❌ Cannot show without Scaffold
- ❌ Boilerplate code everywhere

**Code**:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(message),
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 4),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: 'Retry',
      onPressed: () { /* ... */ },
    ),
  ),
);
```

### After (ToastService)

**Benefits**:
- ✅ Works anywhere (Overlay-based)
- ✅ Consistent, beautiful design
- ✅ Easy to test (mockable interface)
- ✅ Type-safe toast types
- ✅ Highly customizable
- ✅ Works without Scaffold
- ✅ Clean, concise API

**Code**:
```dart
context.toast.showError(message);

// Or with retry
context.showErrorWithRetry(error, onRetry);

// Or with AppError
context.showError(error);
```

## Summary

The toast service implementation provides:

1. **Clean Architecture**: Interface-based design with provider pattern
2. **Better UX**: Smooth animations, consistent styling, action buttons
3. **Developer Experience**: Simple API, context extensions, less boilerplate
4. **Integration**: Seamless integration with error handling strategy
5. **Testability**: Mockable interface for unit/widget tests
6. **Flexibility**: Not tied to Scaffold, works anywhere in widget tree
7. **Maintainability**: Centralized toast logic and styling

All that's needed now is to:
1. Wrap your app with `ToastServiceProvider`
2. Replace remaining `ScaffoldMessenger` calls
3. Enjoy beautiful, consistent toasts throughout your app! 🎉
