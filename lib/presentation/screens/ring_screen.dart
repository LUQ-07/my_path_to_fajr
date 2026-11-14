import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../services/alarm_service.dart';

class RingScreen extends StatelessWidget {
  final AlarmSettings settings;
  const RingScreen({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.alarm, size: 80, color: AppColors.gold),
          const SizedBox(height: 16),
          Text(s.t('ringing'), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(s.t('defaultMsg'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 32),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.navy, padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
            onPressed: () async {
              try {
                await Alarm.stop(settings.id);
                await AlarmService.rescheduleAll(AlarmService.loadFromStore());
              } catch (_) {}
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(s.t('stop'), style: const TextStyle(fontSize: 20)),
          ),
        ]),
      ),
    );
  }
}
