import 'dart:async';

import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/fajr_quotes.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../l10n/app_strings.dart';
import '../../services/alarm_service.dart';
import '../providers.dart';
import '../widgets/swipe_to_stop.dart';

/// Shown when an alarm rings. Swipe up to stop. If nobody stops it, it stops by itself after the
/// chosen time (and rings again later if the alarm has "repeat" enabled).
class RingScreen extends ConsumerStatefulWidget {
  final AlarmSettings settings;
  const RingScreen({super.key, required this.settings});

  static int _open = 0;
  static bool get isOpen => _open > 0;

  @override
  ConsumerState<RingScreen> createState() => _RingScreenState();
}

class _RingScreenState extends ConsumerState<RingScreen> {
  Timer? _timer;
  bool _done = false;
  AlarmItem? _item;

  @override
  void initState() {
    super.initState();
    RingScreen._open++;
    final alarmId = AlarmService.alarmIdOf(widget.settings.id);
    _item = AlarmService.loadFromStore().where((a) => a.id == alarmId).firstOrNull;
    _timer = Timer(Duration(minutes: AlarmService.ringMinutes(_item)), () => _finish(auto: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    RingScreen._open--;
    super.dispose();
  }

  Future<void> _finish({required bool auto}) async {
    if (_done) return;
    _done = true;
    _timer?.cancel();
    try {
      await Alarm.stop(widget.settings.id);
    } catch (_) {}
    final item = _item;
    // Swiping ends the whole sequence. An automatic stop ends it only after the last repeat.
    final endOfSequence = !auto ||
        item == null ||
        item.repeatMinutes == 0 ||
        AlarmService.repeatIndexOf(widget.settings.id) >= AlarmService.maxRepeats;
    if (endOfSequence) {
      try {
        if (item != null && item.days.isEmpty) {
          // One-time alarm: turn it off (this also cancels any pending repeats).
          await ref.read(alarmsProvider.notifier).replace(item.copyWith(enabled: false));
        } else {
          // Cancels pending repeats and arms the next occurrence.
          await AlarmService.rescheduleAll(ref.read(alarmsProvider));
        }
      } catch (_) {}
    }
    // pop() (not maybePop) so the PopScope that blocks the back button does not stop us.
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final quote = fajrQuotes[DateTime.now().day % fajrQuotes.length].text(s.code);
    return PopScope(
      canPop: false, // only the swipe (or the automatic stop) closes this screen
      child: Scaffold(
        backgroundColor: AppColors.navy,
        body: SafeArea(
          child: Column(children: [
            const SizedBox(height: 40),
            const Icon(Icons.alarm, size: 72, color: AppColors.gold),
            const SizedBox(height: 12),
            Text(s.t('ringing'), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(quote, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 17, height: 1.7)),
              ),
            ),
            Text(s.t('swipeToStop'), style: const TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 10),
            SwipeUpToStop(onStop: () => _finish(auto: false)),
            const SizedBox(height: 28),
          ]),
        ),
      ),
    );
  }
}
