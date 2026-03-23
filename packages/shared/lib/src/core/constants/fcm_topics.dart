abstract class FCMTopics {
  /// Topic for all dispatchers belonging to a specific company.
  static String companyDispatchers(String companyId) =>
      'company_${companyId}_dispatchers';

  /// Topic for global system-wide notifications.
  static const String global = 'global';
}
