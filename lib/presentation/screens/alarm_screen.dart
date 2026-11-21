import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../l10n/app_strings.dart';
import '../../services/notification_service.dart';
import '../providers.dart';
import '../widgets/common.dart';
import 'alarm_detail_screen.dart';

/// List of alarms. Tap an alarm to open its own settings page.
class AlarmScreen extends ConsumerWidget {
  const AlarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final alarms = ref.watch(alarmsProvider);
    final n = ref.read(alarmsProvider.notifier);

    return Column(children: [
      Expanded(
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Text(s.t('alarmTitle'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          for (final a in alarms) _AlarmTile(key: ValueKey(a.id), alarm: a),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: AppColors.gold, padding: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            onPressed: () async {
              if (alarms.isEmpty) {
                if (!await showPermissionRationale(context)) return;
                await NotificationService.requestPermissions();
              }
              await n.add();
              final created = ref.read(alarmsProvider);
              if (created.isNotEmpty && context.mounted) {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => AlarmDetailScreen(alarmId: created.last.id)));
              }
            },
            child: Text(s.t('addAlarm')),
          ),
        ),
      ),
    ]);
  }
}

class _AlarmTile extends ConsumerWidget {
  final AlarmItem alarm;
  const _AlarmTile({super.key, required this.alarm});

  String _days(AppStrings s) {
    if (alarm.days.isEmpty) return s.t('oneTime');
    if (alarm.days.length == 7) return s.t('everyDay');
    final sorted = [...alarm.days]..sort();
    return sorted.map((d) => s.weekdays[d]).join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final n = ref.read(alarmsProvider.notifier);
    final h24 = alarm.minutes ~/ 60;
    final min = alarm.minutes % 60;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    String two(int v) => v.toString().padLeft(2, '0');

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => AlarmDetailScreen(alarmId: alarm.id))),
      child: CardBox(
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${two(h12)}:${two(min)}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(h24 >= 12 ? 'PM' : 'AM', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                ]),
              ),
              const SizedBox(height: 2),
              Text(_days(s), style: const TextStyle(fontSize: 12)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded),
          Switch(value: alarm.enabled, onChanged: (v) => n.replace(alarm.copyWith(enabled: v))),
        ]),
      ),
    );
  }
}
