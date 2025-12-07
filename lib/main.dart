import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
// Routes managed via GoRouter in router.dart
import 'package:campus_wave/theme/theme_provider.dart';
import 'package:campus_wave/theme/locale_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:campus_wave/l10n/app_localizations.dart';
import 'package:campus_wave/router.dart';
import 'package:campus_wave/data/search_repository.dart';
import 'package:campus_wave/services/notification_service.dart';
import 'package:campus_wave/services/initialization_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  // Initialize demo professor account
  await InitializationService.initializeApp();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? true;

  // Do NOT seed secrets in code. Expect GROQ_API_KEY via --dart-define or
  // store locally by the user through app settings. This avoids committing
  // secrets and passing GitHub push protection.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ThemeProvider(isDarkMode: isDark)),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(
            create: (_) => SearchRepository()..rebuildIndex()),
      ],
      child: const MyApp(),
    ),
  );

  // Initialize local notifications after providers are set up
  await NotificationService.ensureInitialized();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LocaleProvider>(
      builder: (context, themeProvider, localeProvider, child) {
        return MaterialApp.router(
          title: 'Campus Wave',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.theme,
          locale: localeProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('ur'),
          ],
          routerDelegate: _router.routerDelegate,
          routeInformationParser: _router.routeInformationParser,
          routeInformationProvider: _router.routeInformationProvider,
        );
      },
    );
  }
}
