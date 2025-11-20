import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../app/providers/app_providers.dart';

/// Страница загрузки
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Получаем настройки приложения
      final settingsNotifier = ref.read(appSettingsProvider.notifier);

      // Проверяем, показывался ли уже splash screen
      final hasShownSplash = await settingsNotifier.hasShownSplash();

      if (!hasShownSplash) {
        // Показываем splash screen в первый раз
        await Future.delayed(const Duration(seconds: 2));

        // Отмечаем, что splash был показан
        await settingsNotifier.setSplashShown();
      } else {
        // Если splash уже показывался, делаем короткую задержку для инициализации
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (mounted) {
        // Проверяем, нужно ли показать onboarding
        final isFirstLaunch = await settingsNotifier.isFirstLaunch();

        if (isFirstLaunch) {
          // Отмечаем, что первый запуск завершен
          await settingsNotifier.setFirstLaunchCompleted();
          context.go('/onboarding');
        } else {
          context.go('/home');
        }
      }
    } catch (e) {
      // В случае ошибки переходим на главный экран
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFB9E3A), // Vibrant Orange
              Color(0xFFE6521F), // Deep Orange-Red
              Color(0xFFEA2F14), // Rich Red
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.psychology, size: 100, color: Colors.white),
              const SizedBox(height: 24),
              Text(
                'splash.title'.tr(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'splash.subtitle'.tr(),
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
