import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../l10n/app_strings.dart';
import '../../services/notification_service.dart';
import '../providers.dart';
import '../widgets/common.dart';
import '../widgets/tone_dropdown.dart';

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
          for (final a in alarms) _AlarmCard(key: ValueKey(a.id), alarm: a),
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
            },
            child: Text(s.t('addAlarm')),
          ),
        ),
      ),
    ]);
  }
}

class _AlarmCard extends ConsumerWidget {
  final AlarmItem alarm;
  const _AlarmCard({super.key, required this.alarm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final n = ref.read(alarmsProvider.notifier);
    final h24 = alarm.minutes ~/ 60;
    final min = alarm.minutes % 60;
    final isPm = h24 >= 12;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    String two(int v) => v.toString().padLeft(2, '0');

    Widget arrows(VoidCallback up, VoidCallback down) => Column(children: [
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.keyboard_arrow_up, color: AppColors.gold), onPressed: up),
          IconButton(visualDensity: VisualDensity.compact, icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.gold), onPressed: down),
        ]);

    int setHour(int delta) => ((h24 + delta) % 24) * 60 + min;
    int setMin(int delta) => h24 * 60 + ((min + delta) % 60 + 60) % 60;

    return CardBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
            onTap: () => n.replace(alarm.copyWith(minutes: (alarm.minutes + 720) % 1440)),
            child: Text(isPm ? 'PM' : 'AM', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          arrows(() => n.replace(alarm.copyWith(minutes: setHour(1))), () => n.replace(alarm.copyWith(minutes: setHour(-1)))),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text('${two(h12)}:${two(min)}', style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w600)),
          ),
          arrows(() => n.replace(alarm.copyWith(minutes: setMin(1))), () => n.replace(alarm.copyWith(minutes: setMin(-1)))),
          const SizedBox(width: 8),
          Switch(value: alarm.enabled, onChanged: (v) => n.replace(alarm.copyWith(enabled: v))),
        ]),
        const SizedBox(height: 8),
        Wrap(alignment: WrapAlignment.center, spacing: 6, runSpacing: 6, children: [
          for (var d = 0; d < 7; d++)
            GestureDetector(
              onTap: () {
                final days = [...alarm.days];
                days.contains(d) ? days.remove(d) : days.add(d);
                n.replace(alarm.copyWith(days: days));
              },
              child: CircleAvatar(
                radius: 22,
                backgroundColor: alarm.days.contains(d) ? AppColors.gold : Colors.grey.shade300,
                child: Text(s.weekdays[d], style: const TextStyle(fontSize: 9, color: AppColors.navy), textAlign: TextAlign.center, overflow: TextOverflow.clip),
              ),
            ),
        ]),
        const Divider(height: 24),
        Row(children: [
          const Icon(Icons.volume_up, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: ToneDropdown(
              value: alarm.tone,
              prefix: '${s.t('alarmTone')}: ',
              hideUnderline: true,
              onChanged: (v) => n.replace(alarm.copyWith(tone: v)),
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => n.remove(alarm)),
        ]),
      ]),
    );
  }
}
