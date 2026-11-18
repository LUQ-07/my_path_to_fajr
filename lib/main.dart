import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/security/secure_store.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_strings.dart';
import 'presentation/providers.dart';
import 'presentation/screens/main_shell.dart';
import 'presentation/screens/ring_screen.dart';
import 'services/alarm_service.dart';
import 'services/notification_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SecureStore.init();
  await NotificationService.init();
  await AlarmService.init();
  runApp(const ProviderScope(child: FajrApp()));
}

class FajrApp extends ConsumerStatefulWidget {
  const FajrApp({super.key});
  @override
  ConsumerState<FajrApp> createState() => _FajrAppState();
}

class _FajrAppState extends ConsumerState<FajrApp> {
  StreamSubscription<AlarmSettings>? _ringSub;

  @override
  void initState() {
    super.initState();
    // Re-arm everything on launch (rolling window refresh).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NotificationService.reschedule(ref.read(settingsProvider));
      await AlarmService.rescheduleAll(ref.read(alarmsProvider));
      await ref.read(monthlyImageProvider.notifier).recoverLost();
    });
    try {
      _ringSub = Alarm.ringStream.stream.listen((settings) {
        navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => RingScreen(settings: settings)));
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _ringSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(settingsProvider);
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (c) => AppStrings.of(c).t('appTitle'),
      locale: Locale(s.lang),
      supportedLocales: AppStrings.supported,
      localizationsDelegates: const [
        AppStrings.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildTheme(dark: false),
      darkTheme: buildTheme(dark: true),
      themeMode: s.dark ? ThemeMode.dark : ThemeMode.light,
      home: const MainShell(),
    );
  }
}
