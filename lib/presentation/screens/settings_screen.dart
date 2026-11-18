import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../providers.dart';
import '../widgets/common.dart';

/// Settings: appearance, language and "start over". (Alarm tones live on the alarm screen,
/// notification switch lives on the notifications screen.)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          _LanguageTile(current: st.lang, onChanged: (v) => n.update(st.copyWith(lang: v), reschedule: true)),
          const SizedBox(height: 16),
          PillButton(
            label: s.t('startOver'),
            icon: Icons.restart_alt_rounded,
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: Text(s.t('startOver')),
                  content: Text(s.t('startOverMsg')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: Text(s.t('cancel'))),
                    FilledButton(onPressed: () => Navigator.pop(c, true), child: Text(s.t('startOver'))),
                  ],
                ),
              );
              if (ok == true) await ref.read(daysProvider.notifier).reset();
            },
          ),
        ]),
      ),
    ]);
  }
}

/// Tap to open the list of languages, then pick one.
class _LanguageTile extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;
  const _LanguageTile({required this.current, required this.onChanged});

  static const _names = {'ar': 'العربية', 'en': 'English', 'fr': 'Français'};

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        final r = await showModalBottomSheet<String>(
          context: context,
          builder: (c) => SafeArea(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              for (final e in _names.entries)
                ListTile(
                  title: Text(e.value),
                  trailing: e.key == current ? const Icon(Icons.check, color: AppColors.gold) : null,
                  onTap: () => Navigator.pop(c, e.key),
                ),
            ]),
          ),
        );
        if (r != null) onChanged(r);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gold)),
        child: Row(children: [
          const Icon(Icons.language, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(child: Text(_names[current] ?? current, style: const TextStyle(fontSize: 16))),
          const Icon(Icons.keyboard_arrow_down),
        ]),
      ),
    );
  }
}
