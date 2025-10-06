import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Страница аналитики
class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('analytics.title'.tr()),
      ),
      body: Center(
        child: Text(
          'analytics.page'.tr(),
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

