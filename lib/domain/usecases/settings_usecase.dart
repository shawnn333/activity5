import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsUseCase {
  final SettingsRepository repository;

  SettingsUseCase(this.repository);

  AppSettings getSettings() => repository.getSettings();

  void updateSettings(AppSettings settings) {
    repository.updateSettings(settings);
  }
}
