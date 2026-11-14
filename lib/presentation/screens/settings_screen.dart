import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../services/notification_service.dart';
import '../providers.dart';
import '../widgets/common.dart';
import '../widgets/tone_dropdown.dart';
import '../../services/tone_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePreview(String tone) async {
    try {
      if (_playing) {
        await _player.stop();
        setState(() => _playing = false);
      } else {
        await _player.play(ToneService.source(tone));
        setState(() => _playing = true);
        _player.onPlayerComplete.first.then((_) {
          if (mounted) setState(() => _playing = false);
        });
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
    final st = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return ListView(padding: const EdgeInsets.all(16), children: [
      CardBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.t('settings'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text(s.t('appStyle'), style: const TextStyle(fontSize: 16))),
            const Icon(Icons.light_mode, size: 18),
            Switch(value: st.dark, onChanged: (v) => n.update(st.copyWith(dark: v))),
            const Icon(Icons.dark_mode, size: 18),
          ]),
          const SizedBox(height: 8),
          Text(s.t('languages'), style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'ar', label: Text('العربية')),
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'fr', label: Text('Français')),
              ],
              selected: {st.lang},
              onSelectionChanged: (v) => n.update(st.copyWith(lang: v.first), reschedule: true),
            ),
          ),
          const SizedBox(height: 14),
          Text(s.t('alarmSound'), style: const TextStyle(fontSize: 16)),
          Row(children: [
            IconButton.filledTonal(
              icon: Icon(_playing ? Icons.stop : Icons.volume_up),
              onPressed: () => _togglePreview(st.sound),
            ),
            const SizedBox(width: 8),
            Expanded(child: ToneDropdown(value: st.sound, onChanged: (v) => n.update(st.copyWith(sound: v)))),
            if (st.sound.startsWith('custom_'))
              IconButton(
                tooltip: s.t('deleteTone'),
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await ref.read(customTonesProvider.notifier).remove(st.sound);
                  await n.update(st.copyWith(sound: 'fajr_adhan'));
                },
              ),
          ]),
          Row(children: [
            Expanded(child: Text(s.t('notifications'), style: const TextStyle(fontSize: 16))),
            Switch(
              value: st.notificationsOn,
              onChanged: (v) async {
                if (v && !await showPermissionRationale(context)) return;
                if (v) await NotificationService.requestPermissions();
                await n.update(st.copyWith(notificationsOn: v), reschedule: true);
              },
            ),
          ]),
        ]),
      ),
    ]);
  }
}
