import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  AppSettings _settings = const AppSettings(
    userName: 'Shawn',
    isDarkMode: false,
  );

  @override
  AppSettings getSettings() => _settings;

  @override
  void updateSettings(AppSettings settings) {
    _settings = settings;
  }
}
