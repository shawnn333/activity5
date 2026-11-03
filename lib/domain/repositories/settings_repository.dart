import '../entities/app_settings.dart';

abstract class SettingsRepository {
  AppSettings getSettings();
  void updateSettings(AppSettings settings);
}
