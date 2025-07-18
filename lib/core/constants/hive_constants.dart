abstract class HiveConstants {
  static const String trackedBoxes = '__tracked_boxes';
  static const String app = 'app';
  static const String auth = 'auth';
  static const String savedAddresses = 'saved_addresses';
  static const String permissions = 'permissions';

  static const List<String> startupBoxes = [app,
    auth,
    permissions,
  ];
}
