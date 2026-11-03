import 'package:flutter/material.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/settings_usecase.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsUseCase useCase;
  late AppSettings _settings;

  SettingsProvider(this.useCase) {
    _settings = useCase.getSettings();
  }

  AppSettings get settings => _settings;
  String get userName => _settings.userName;
  bool get isDarkMode => _settings.isDarkMode;

  void toggleTheme() {
    _settings = _settings.copyWith(isDarkMode: !_settings.isDarkMode);
    useCase.updateSettings(_settings);
    notifyListeners();
  }

  void updateUserName(String name) {
    final value = name.trim();
    if (value.isEmpty) return;

    _settings = _settings.copyWith(userName: value);
    useCase.updateSettings(_settings);
    notifyListeners();
  }
}
