import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/fajr_quotes.dart';
import '../../core/security/sanitizer.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../services/notification_service.dart';
import '../providers.dart';
import '../widgets/common.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final st = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    final times = [...st.alertMinutes]..sort();

    Future<void> addOrEdit({int? old}) async {
      final init = old ?? 4 * 60 + 15;
      final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: init ~/ 60, minute: init % 60));
      if (t == null) return;
      final m = t.hour * 60 + t.minute;
      final list = [...st.alertMinutes];
      if (old != null) list.remove(old);
      if (!list.contains(m)) list.add(m);
      await n.update(st.copyWith(alertMinutes: list), reschedule: true);
    }

    return ListView(padding: const EdgeInsets.all(16), children: [
      CardBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(s.t('fajrNotifs'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Row(children: [
            Expanded(child: Text(s.t('enableReminders'))),
            Switch(
              value: st.notificationsOn,
              onChanged: (v) async {
                if (v && !await showPermissionRationale(context)) return;
                if (v) await NotificationService.requestPermissions();
                await n.update(st.copyWith(notificationsOn: v), reschedule: true);
              },
            ),
          ]),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.25), borderRadius: BorderRadius.circular(18)),
            child: Column(children: [
              Text('${fajrQuotes.length}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
              Text(s.t('reminders')),
              Text(s.t('remindersDesc'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              Text(s.t('queued', {'n': '${NotificationService.lastScheduled}'}), style: const TextStyle(fontSize: 11)),
            ]),
          ),
          const SizedBox(height: 12),
          PillButton(
            label: st.reminderMsg.isEmpty ? s.t('customMsg') : st.reminderMsg,
            onTap: () async {
              final r = await showDialog<String>(
                context: context,
                builder: (_) => TextInputDialog(title: s.t('customMsg'), hint: s.t('defaultMsg'), initial: st.reminderMsg, maxLength: 140),
              );
              if (r == null) return;
              await n.update(st.copyWith(reminderMsg: Sanitizer.clean(r, max: 140)), reschedule: true);
            },
          ),
          const SizedBox(height: 16),
          Text(s.t('notifTime'), textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          PillButton(label: s.t('setAlertTimes'), filled: true, onTap: () => addOrEdit()),
          if (times.isEmpty) Padding(padding: const EdgeInsets.all(12), child: Text(s.t('noTimes'), textAlign: TextAlign.center)),
          for (final m in times)
            ListTile(
              dense: true,
              leading: const Icon(Icons.access_time, color: AppColors.gold),
              title: Text(fmtMinutes(context, m)),
              onTap: () => addOrEdit(old: m),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => n.update(st.copyWith(alertMinutes: st.alertMinutes.where((x) => x != m).toList()), reschedule: true),
              ),
            ),
          const SizedBox(height: 8),
          PillButton(label: s.t('addNewTime'), onTap: () => addOrEdit()),
        ]),
      ),
    ]);
  }
}
