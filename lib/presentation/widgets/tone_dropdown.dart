import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_strings.dart';
import '../../services/tone_service.dart';
import '../providers.dart';

/// Built-in adhans + the user's own tones + an "add from phone" entry.
class ToneDropdown extends ConsumerWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String prefix;
  final bool hideUnderline;
  const ToneDropdown({super.key, required this.value, required this.onChanged, this.prefix = '', this.hideUnderline = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final customs = ref.watch(customTonesProvider);
    final ids = [...ToneService.builtin, ...customs.map((c) => c.id)];
    final safe = ids.contains(value) ? value : 'fajr_adhan';
    return DropdownButton<String>(
      isExpanded: true,
      underline: hideUnderline ? const SizedBox.shrink() : null,
      value: safe,
      items: [
        for (final id in ids)
          DropdownMenuItem(value: id, child: Text('$prefix${ToneService.label(s, id, customs)}', overflow: TextOverflow.ellipsis)),
        DropdownMenuItem(
          value: ToneService.addMarker,
          child: Row(children: [const Icon(Icons.add, size: 18), const SizedBox(width: 6), Flexible(child: Text(s.t('addTone'), overflow: TextOverflow.ellipsis))]),
        ),
      ],
      onChanged: (v) async {
        if (v == null) return;
        if (v == ToneService.addMarker) {
          final t = await ref.read(customTonesProvider.notifier).pick();
          if (t != null) {
            onChanged(t.id);
          } else if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s.t('toneTooBig'))));
          }
        } else {
          onChanged(v);
        }
      },
    );
  }
}
