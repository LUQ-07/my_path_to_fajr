import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../../services/tone_service.dart';
import '../providers.dart';
import '../widgets/common.dart';
import '../widgets/tone_dropdown.dart';

/// Settings of one alarm: time, days, tone (with preview), volume, auto-stop and repeat.
class AlarmDetailScreen extends ConsumerStatefulWidget {
  final int alarmId;
  const AlarmDetailScreen({super.key, required this.alarmId});

  @override
  ConsumerState<AlarmDetailScreen> createState() => _AlarmDetailScreenState();
}

class _AlarmDetailScreenState extends ConsumerState<AlarmDetailScreen> {
  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<void>? _sub;
  bool _playing = false;
  double? _vol; // while dragging the slider

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

  Future<void> _togglePreview(String tone, double volume) async {
    try {
      if (_playing) {
        await _stopPreview();
      } else {
        await _player.setVolume(volume);
        await _player.play(ToneService.source(tone));
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
    final s = AppStrings.of(context);
    final n = ref.read(alarmsProvider.notifier);
    final alarm = ref.watch(alarmsProvider).where((a) => a.id == widget.alarmId).firstOrNull;
    if (alarm == null) {
      return Scaffold(appBar: AppBar(backgroundColor: AppColors.navy, foregroundColor: Colors.white));
    }
    final h24 = alarm.minutes ~/ 60;
    final min = alarm.minutes % 60;
    final isPm = h24 >= 12;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    String two(int v) => v.toString().padLeft(2, '0');
    final vol = _vol ?? alarm.volume;

    Widget label(String key) => Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(s.t(key), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(s.t('alarmSettings')),
        actions: [
          IconButton(
            tooltip: s.t('deleteAlarm'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(s.t('deleteAlarm')),
                  content: Text(s.t('deleteAlarmMsg')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.t('cancel'))),
                    FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(s.t('delete'))),
                  ],
                ),
              );
              if (ok == true) {
                await n.remove(alarm);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        CardBox(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
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
                        Text('${two(h12)}:${two(min)}', style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(isPm ? 'PM' : 'AM', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                        const SizedBox(width: 8),
                        const Padding(padding: EdgeInsets.only(bottom: 12), child: Icon(Icons.edit_outlined, size: 18, color: AppColors.gold)),
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
          ]),
        ),
        CardBox(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            label('alarmTone'),
            Row(children: [
              IconButton.filledTonal(
                tooltip: s.t('preview'),
                icon: Icon(_playing ? Icons.stop_rounded : Icons.play_arrow_rounded),
                onPressed: () => _togglePreview(alarm.tone, vol),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ToneDropdown(
                  value: alarm.tone,
                  hideUnderline: true,
                  onChanged: (v) {
                    _stopPreview();
                    n.replace(alarm.copyWith(tone: v));
                  },
                ),
              ),
            ]),
            label('volume'),
            Row(children: [
              const Icon(Icons.volume_down, color: AppColors.gold),
              Expanded(
                child: Slider(
                  value: vol,
                  min: 0.1,
                  max: 1.0,
                  onChanged: (v) {
                    setState(() => _vol = v);
                    _player.setVolume(v);
                  },
                  onChangeEnd: (v) async {
                    await n.replace(alarm.copyWith(volume: v));
                    if (mounted) setState(() => _vol = null);
                  },
                ),
              ),
              const Icon(Icons.volume_up, color: AppColors.gold),
            ]),
          ]),
        ),
        CardBox(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            label('autoStop'),
            Wrap(spacing: 8, children: [
              for (final v in const [5, 10])
                ChoiceChip(
                  label: Text(s.t('minutesN', {'n': '$v'})),
                  selected: alarm.autoStopMinutes == v,
                  onSelected: (_) => n.replace(alarm.copyWith(autoStopMinutes: v)),
                ),
            ]),
            label('repeatEvery'),
            Wrap(spacing: 8, runSpacing: 4, children: [
              for (final v in const [0, 5, 10, 15])
                ChoiceChip(
                  label: Text(v == 0 ? s.t('noRepeat') : s.t('minutesN', {'n': '$v'})),
                  selected: alarm.repeatMinutes == v,
                  onSelected: (_) => n.replace(alarm.copyWith(repeatMinutes: v)),
                ),
            ]),
            if (alarm.repeatMinutes > 0)
              Padding(padding: const EdgeInsets.only(top: 10), child: Text(s.t('repeatNote'), style: const TextStyle(fontSize: 12))),
          ]),
        ),
      ]),
    );
  }
}
