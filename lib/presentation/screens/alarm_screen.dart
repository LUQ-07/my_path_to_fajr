import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../l10n/app_strings.dart';
import '../../services/notification_service.dart';
import '../../services/tone_service.dart';
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

class _AlarmCard extends ConsumerStatefulWidget {
  final AlarmItem alarm;
  const _AlarmCard({super.key, required this.alarm});

  @override
  ConsumerState<_AlarmCard> createState() => _AlarmCardState();
}

class _AlarmCardState extends ConsumerState<_AlarmCard> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _sub;
  bool _playing = false;
  late double _vol = widget.alarm.volume;

  @override
  void initState() {
    super.initState();
    _sub = _player.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _stopPreview() async {
    try {
      await _player.stop();
    } catch (_) {}
    if (mounted) setState(() => _playing = false);
  }

  Future<void> _togglePreview() async {
    try {
      if (_playing) {
        await _stopPreview();
      } else {
        await _player.setVolume(_vol);
        await _player.play(ToneService.source(widget.alarm.tone));
        if (mounted) setState(() => _playing = true);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _playing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.of(context).t('error'))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final alarm = widget.alarm;
    final s = AppStrings.of(context);
    final n = ref.read(alarmsProvider.notifier);
    final h24 = alarm.minutes ~/ 60;
    final min = alarm.minutes % 60;
    final isPm = h24 >= 12;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    String two(int v) => v.toString().padLeft(2, '0');

    return CardBox(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: TimeOfDay(hour: h24, minute: min));
                if (t != null) await n.replace(alarm.copyWith(minutes: t.hour * 60 + t.minute));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('${two(h12)}:${two(min)}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(isPm ? 'PM' : 'AM', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    const Padding(padding: EdgeInsets.only(bottom: 10), child: Icon(Icons.edit_outlined, size: 18, color: AppColors.gold)),
                  ]),
                ),
              ),
            ),
          ),
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
          IconButton.filledTonal(
            tooltip: s.t('preview'),
            icon: Icon(_playing ? Icons.stop_rounded : Icons.play_arrow_rounded),
            onPressed: _togglePreview,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ToneDropdown(
              value: alarm.tone,
              prefix: '${s.t('alarmTone')}: ',
              hideUnderline: true,
              onChanged: (v) {
                _stopPreview();
                n.replace(alarm.copyWith(tone: v));
              },
            ),
          ),
          IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => n.remove(alarm)),
        ]),
        Row(children: [
          const Icon(Icons.volume_down, color: AppColors.gold),
          Expanded(
            child: Slider(
              value: _vol,
              min: 0.1,
              max: 1.0,
              onChanged: (v) {
                setState(() => _vol = v);
                _player.setVolume(v);
              },
              onChangeEnd: (v) => n.replace(alarm.copyWith(volume: v)),
            ),
          ),
          const Icon(Icons.volume_up, color: AppColors.gold),
        ]),
      ]),
    );
  }
}
