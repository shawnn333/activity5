import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/providers/settings_provider.dart';
import '../presentation/screens/activity1/activity1_screen.dart';
import '../presentation/screens/activity2/activity2_screen.dart';
import '../presentation/screens/activity3/activity3_screen.dart';
import '../presentation/screens/activity4/activity4_screen.dart';
import '../presentation/screens/activity5/activity5_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import 'routes/app_routes.dart';
import 'theme/app_theme.dart';

class LabActivityMasterApp extends StatelessWidget {
  const LabActivityMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab Activity Master',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.activity1: (_) => const Activity1Screen(),
        AppRoutes.activity2: (_) => const Activity2Screen(),
        AppRoutes.activity3: (_) => const Activity3Screen(),
        AppRoutes.activity4: (_) => const Activity4Screen(),
        AppRoutes.activity5: (_) => const Activity5Screen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
