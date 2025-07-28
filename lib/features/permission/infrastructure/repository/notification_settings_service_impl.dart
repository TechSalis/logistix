import 'package:app_settings/app_settings.dart';
import 'package:logistix/features/permission/domain/repository/settings_service.dart';

class LocationSettingsImpl extends SettingsService {
  @override
  Future<void> open() {
    return AppSettings.openAppSettings(type: AppSettingsType.notification);
  }
}
