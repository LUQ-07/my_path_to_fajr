import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import 'about_screen.dart';
import 'alarm_screen.dart';
import 'home_screen.dart';
import 'monthly_screen.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'updates_screen.dart';

/// Collapsible navigation rail. In RTL (Arabic) the Row places it on the right,
/// in LTR (English/French) on the left, automatically.
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _expanded = true;

  static const _pages = <Widget>[HomeScreen(), SettingsScreen(), NotificationsScreen(), AboutScreen(), UpdatesScreen(), AlarmScreen(), MonthlyScreen()];

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final items = <(int, IconData, String)>[
      (0, Icons.home_rounded, s.t('home')),
      (1, Icons.settings_rounded, s.t('settings')),
      (2, Icons.notifications_rounded, s.t('notifications')),
      (6, Icons.photo_library_outlined, s.t('monthly')),
      (3, Icons.info_outline_rounded, s.t('about')),
      (4, Icons.sync_rounded, s.t('updates')),
    ];
    return Scaffold(
      body: SafeArea(
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _expanded ? 84 : 52,
            margin: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(22)),
            child: Column(children: [
              const SizedBox(height: 10),
              _RailItem(icon: Icons.menu_rounded, label: s.t('menu'), selected: false, showLabel: _expanded, onTap: () => setState(() => _expanded = !_expanded)),
              for (final it in items)
                _RailItem(icon: it.$2, label: it.$3, selected: _index == it.$1, showLabel: _expanded, onTap: () => setState(() => _index = it.$1)),
              const Spacer(),
              _RailItem(icon: Icons.alarm_rounded, label: s.t('alarm'), selected: _index == 5, showLabel: _expanded, onTap: () => setState(() => _index = 5)),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('V.1.00', style: TextStyle(color: Colors.white70, fontSize: 10))),
            ]),
          ),
          Expanded(
            child: Column(children: [
              const _Header(),
              Expanded(child: _pages[_index]),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected, showLabel;
  final VoidCallback onTap;
  const _RailItem({required this.icon, required this.label, required this.selected, required this.showLabel, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: selected ? Colors.white10 : Colors.transparent,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: selected ? AppColors.gold : Colors.white, size: 24),
            if (showLabel)
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: selected ? AppColors.gold : Colors.white, fontSize: 10)),
          ]),
        ),
      );
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
      margin: const EdgeInsets.only(top: 6, right: 6, left: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.vertical(bottom: Radius.circular(26))),
      child: Row(children: [
        Expanded(child: Text(s.t('appTitle'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
        Text(time, style: const TextStyle(color: AppColors.gold, fontSize: 13)),
      ]),
    );
  }
}
