/// Centralized storage for all module entry routes
///
/// This class contains the entry point routes for each feature module
/// in the application. These routes are used for navigation between modules.
abstract class ModuleRoutePaths {
  // Auth module routes
  static const String auth = '/auth';

  // Onboarding module routes
  static const String onboarding = '/onboarding';

  // Rider module routes
  static const String rider = '/rider';

  // Dispatcher module routes
  static const String dispatcher = '/dispatcher';
}
