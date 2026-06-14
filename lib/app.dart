import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/content_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/shell/main_shell.dart';
import 'screens/shell/splash_screen.dart';
import 'theme/app_theme.dart';

class SlopeApp extends StatelessWidget {
  const SlopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => AppThemeProvider()),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  late final Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = Future.wait([
      context.read<ContentProvider>().load(),
      context.read<ProgressProvider>().init(),
      context.read<AppThemeProvider>().init(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppThemeProvider>().themeMode;

    return MaterialApp(
      title: 'Slope',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: FutureBuilder(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SplashScreen();
          }
          return const MainShell();
        },
      ),
    );
  }
}
