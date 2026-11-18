import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../widgets/common.dart';
import 'about_screen.dart';
import 'alarm_screen.dart';
import 'home_screen.dart';
import 'monthly_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'updates_screen.dart';

/// Bottom navigation: Home, Monthly session, Alarm, More.
/// "More" opens Settings, Notifications, About and Updates.
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _pages = <Widget>[HomeScreen(), MonthlyScreen(), AlarmScreen(), _MoreScreen()];

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          const _Header(),
          Expanded(child: _pages[_index]),
        ]),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: AppColors.navy,
            indicatorColor: AppColors.gold.withOpacity(0.25),
            iconTheme: WidgetStateProperty.resolveWith((st) => IconThemeData(color: st.contains(WidgetState.selected) ? AppColors.gold : Colors.white)),
            labelTextStyle: WidgetStateProperty.resolveWith((st) => TextStyle(fontSize: 11, color: st.contains(WidgetState.selected) ? AppColors.gold : Colors.white)),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_rounded), label: s.t('home')),
            NavigationDestination(icon: const Icon(Icons.photo_library_outlined), label: s.t('monthly')),
            NavigationDestination(icon: const Icon(Icons.alarm_rounded), label: s.t('alarm')),
            NavigationDestination(icon: const Icon(Icons.more_horiz_rounded), label: s.t('more')),
          ],
        ),
      ),
    );
  }
}

/// "More": a list that opens Settings, Notifications, About and Updates.
class _MoreScreen extends StatelessWidget {
  const _MoreScreen();

  void _open(BuildContext context, String title, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(backgroundColor: AppColors.navy, foregroundColor: Colors.white, title: Text(title)),
        body: page,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final entries = <(IconData, String, Widget)>[
      (Icons.settings_rounded, s.t('settings'), const SettingsScreen()),
      (Icons.notifications_rounded, s.t('notifications'), const NotificationsScreen()),
      (Icons.info_outline_rounded, s.t('about'), const AboutScreen()),
      (Icons.sync_rounded, s.t('updates'), const UpdatesScreen()),
    ];
    return ListView(padding: const EdgeInsets.all(16), children: [
      CardBox(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: [
          for (var i = 0; i < entries.length; i++) ...[
            ListTile(
              leading: Icon(entries[i].$1, color: AppColors.gold),
              title: Text(entries[i].$2),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _open(context, entries[i].$2, entries[i].$3),
            ),
            if (i < entries.length - 1) const Divider(height: 1),
          ],
        ]),
      ),
      const Center(child: Text('V.1.00', style: TextStyle(fontSize: 12))),
    ]);
  }
}

class _Header extends StatefulWidget {
  const _Header();
  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    String time;
    try {
      time = DateFormat('hh:mm a', Localizations.localeOf(context).languageCode).format(_now);
    } catch (_) {
      time = DateFormat('HH:mm').format(_now);
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(6, 6, 6, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.vertical(bottom: Radius.circular(26))),
      child: Row(children: [
        Expanded(child: Text(s.t('appTitle'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
        Text(time, style: const TextStyle(color: AppColors.gold, fontSize: 13)),
      ]),
    );
  }
}
