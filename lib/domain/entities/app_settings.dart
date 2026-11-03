class AppSettings {
  final String userName;
  final bool isDarkMode;

  const AppSettings({
    required this.userName,
    required this.isDarkMode,
  });

  AppSettings copyWith({
    String? userName,
    bool? isDarkMode,
  }) {
    return AppSettings(
      userName: userName ?? this.userName,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
