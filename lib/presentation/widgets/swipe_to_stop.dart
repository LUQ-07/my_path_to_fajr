import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Drag the gold handle from the bottom to the top to stop the alarm.
class SwipeUpToStop extends StatefulWidget {
  final VoidCallback onStop;
  const SwipeUpToStop({super.key, required this.onStop});

  @override
  State<SwipeUpToStop> createState() => _SwipeUpToStopState();
}

class _SwipeUpToStopState extends State<SwipeUpToStop> {
  static const double _height = 220;
  static const double _handle = 64;
  double _dy = 0; // 0 .. _max
  static const double _max = _height - _handle - 12;
  bool _fired = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84,
      height: _height,
      child: Stack(alignment: Alignment.bottomCenter, children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            border: Border.all(color: AppColors.gold.withOpacity(0.6), width: 1.5),
            color: Colors.white10,
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 16),
          child: const Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white38),
            Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white54),
            Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white70),
          ]),
        ),
        Positioned(
          bottom: 6 + _dy,
          child: GestureDetector(
            onVerticalDragUpdate: (d) => setState(() => _dy = (_dy - d.delta.dy).clamp(0.0, _max).toDouble()),
            onVerticalDragEnd: (_) {
              if (_dy >= _max * 0.85 && !_fired) {
                _fired = true;
                widget.onStop();
              } else {
                setState(() => _dy = 0);
              }
            },
            child: const CircleAvatar(
              radius: _handle / 2,
              backgroundColor: AppColors.gold,
              child: Icon(Icons.alarm_off_rounded, color: AppColors.navy, size: 30),
            ),
          ),
        ),
      ]),
    );
  }
}
