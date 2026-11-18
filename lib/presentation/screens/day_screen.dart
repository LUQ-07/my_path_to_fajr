import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/fajr_quotes.dart';
import '../../core/security/sanitizer.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_strings.dart';
import '../providers.dart';
import '../widgets/common.dart';

const kDayGreen = Color(0xFF2E7D32);
const kDayRed = Color(0xFFC62828);

/// A page dedicated to one day: quote, note and "completed?".
/// The day is the one currently selected in [daysProvider].
class DayScreen extends ConsumerWidget {
  const DayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings.of(context);
    final d = ref.watch(daysProvider);
    final n = ref.read(daysProvider.notifier);
    final lang = ref.watch(settingsProvider).lang;
    final e = d.current;
    final quote = (e['quote'] as String?) ?? '';
    final note = (e['note'] as String?) ?? '';
    final done = e['done'] as bool?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: Text(s.t('dayN', {'n': '${d.selected}'})),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        CardBox(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(s.t('dayN', {'n': '${d.selected}'}), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (quote.isNotEmpty)
              Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(quote, textAlign: TextAlign.center, style: const TextStyle(fontStyle: FontStyle.italic))),
            PillButton(label: s.t('addQuote'), onTap: () => _pickQuote(context, ref, lang)),
            const SizedBox(height: 10),
            if (note.isNotEmpty)
              Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(note, textAlign: TextAlign.center)),
            PillButton(label: s.t('myNote'), onTap: () => _editNote(context, ref, note)),
            const SizedBox(height: 16),
            Text(s.t('completed'), textAlign: TextAlign.end, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: PillButton(label: s.t('yes'), icon: Icons.check_circle_outline, color: kDayGreen, filled: done == true, onTap: () => n.setDone(true))),
              const SizedBox(width: 12),
              Expanded(child: PillButton(label: s.t('no'), icon: Icons.cancel_outlined, color: kDayRed, filled: done == false, onTap: () => n.setDone(false))),
            ]),
            const SizedBox(height: 12),
            Text(s.t('streak', {'n': '${d.streak}'}), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ]),
        ),
      ]),
    );
  }

  Future<void> _editNote(BuildContext context, WidgetRef ref, String current) async {
    final s = AppStrings.of(context);
    final r = await showDialog<String>(
      context: context,
      builder: (_) => NoteDialog(title: s.t('myNote'), hint: s.t('noteHint'), initial: current, maxLength: 500),
    );
    if (r == null) return;
    await ref.read(daysProvider.notifier).setNote(Sanitizer.clean(r, max: 500, multiline: true));
  }

  Future<void> _pickQuote(BuildContext context, WidgetRef ref, String lang) async {
    final r = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _QuoteSheet(lang: lang),
    );
    if (r == null) return;
    await ref.read(daysProvider.notifier).setQuote(Sanitizer.clean(r, max: 400));
  }
}

class _QuoteSheet extends StatefulWidget {
  final String lang;
  const _QuoteSheet({required this.lang});
  @override
  State<_QuoteSheet> createState() => _QuoteSheetState();
}

class _QuoteSheetState extends State<_QuoteSheet> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _c,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: s.t('writeQuote'),
                suffixIcon: IconButton(icon: const Icon(Icons.check), onPressed: () => Navigator.pop(context, _c.text)),
              ),
            ),
          ),
          Text(s.t('pickQuote'), style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.separated(
              itemCount: fajrQuotes.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final t = fajrQuotes[i].text(widget.lang);
                return ListTile(title: Text(t), subtitle: Text(fajrQuotes[i].source), onTap: () => Navigator.pop(context, t));
              },
            ),
          ),
        ]),
      ),
    );
  }
}
