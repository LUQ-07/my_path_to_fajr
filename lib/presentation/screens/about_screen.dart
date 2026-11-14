import 'package:flutter/material.dart';

import '../../l10n/app_strings.dart';
import '../widgets/common.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return ListView(padding: const EdgeInsets.all(16), children: [
      CardBox(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.t('aboutTitle'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(s.t('aboutBody'), style: const TextStyle(height: 1.6)),
        ]),
      ),
    ]);
  }
}
