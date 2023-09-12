import 'package:flutter/material.dart';
import '/providers/connectivity_provider.dart';
import '/utils/theme.dart';
import '/repo_injection.dart';
import '/services/auth_service.dart';

import 'MyApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initRepos().then((value) async => sl.get<ConnectivityProvider>());
  // colorScheme = await generateColorSchemeFromImage(Brightness.light);
  // darkColorScheme = await generateColorSchemeFromImage(Brightness.dark);
  runApp(StreamAuthScope(child: const MyApp()));
}
