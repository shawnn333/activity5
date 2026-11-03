import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'data/repositories/diagnostic_repository_impl.dart';
import 'data/repositories/geofence_repository_impl.dart';
import 'data/repositories/location_repository_impl.dart';
import 'data/repositories/mesh_repository_impl.dart';
import 'data/repositories/network_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/usecases/diagnostic_usecase.dart';
import 'domain/usecases/geofence_usecase.dart';
import 'domain/usecases/mesh_usecase.dart';
import 'domain/usecases/network_usecase.dart';
import 'domain/usecases/settings_usecase.dart';
import 'presentation/providers/diagnostic_provider.dart';
import 'presentation/providers/geofence_provider.dart';
import 'presentation/providers/mesh_chat_provider.dart';
import 'presentation/providers/network_provider.dart';
import 'presentation/providers/settings_provider.dart';

void main() {
  final settingsRepository = SettingsRepositoryImpl();
  final settingsUseCase = SettingsUseCase(settingsRepository);

  final networkRepository = NetworkRepositoryImpl();
  final networkUseCase = NetworkUseCase(networkRepository);

  final diagnosticRepository = DiagnosticRepositoryImpl(
    networkRepository: networkRepository,
  );
  final diagnosticUseCase = DiagnosticUseCase(diagnosticRepository);

  final meshRepository = MeshRepositoryImpl();
  final meshUseCase = MeshUseCase(meshRepository);

  final geofenceUseCase = GeofenceUseCase(
    zones: GeofenceRepositoryImpl(),
    location: LocationRepositoryImpl(),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => NetworkProvider(networkUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => DiagnosticProvider(diagnosticUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => MeshChatProvider(meshUseCase),
        ),
        ChangeNotifierProvider(
          create: (_) => GeofenceProvider(geofenceUseCase),
        ),
      ],
      child: const LabActivityMasterApp(),
    ),
  );
}
