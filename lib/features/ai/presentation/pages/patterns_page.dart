import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../app/providers/ai_features_provider.dart';
import '../../../../presentation/widgets/core/glass_surface.dart';
import '../blocs/patterns_bloc.dart';
import '../widgets/pattern_analysis_card.dart';

/// Страница анализа паттернов настроения
class PatternsPage extends ConsumerStatefulWidget {
  const PatternsPage({super.key});

  @override
  ConsumerState<PatternsPage> createState() => _PatternsPageState();
}

class _PatternsPageState extends ConsumerState<PatternsPage> {
  @override
  void initState() {
    super.initState();
    // Загружаем анализ паттернов при открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<PatternsBloc>().isClosed) {
        context.read<PatternsBloc>().add(LoadPatternAnalysis([]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ai.patterns.title'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (!context.read<PatternsBloc>().isClosed) {
                context.read<PatternsBloc>().add(LoadPatternAnalysis([]));
              }
            },
          ),
        ],
      ),
      body: BlocProvider<PatternsBloc>(
        create: (context) => ref.read(patternsBlocProvider),
        child: RefreshIndicator(
          onRefresh: () async {
            if (!context.read<PatternsBloc>().isClosed) {
              context.read<PatternsBloc>().add(LoadPatternAnalysis([]));
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                GlassSurface(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.analytics,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Patterns Analysis',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Анализ паттернов и трендов вашего настроения',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Patterns Content
                BlocBuilder<PatternsBloc, PatternsState>(
                  builder: (context, state) {
                    if (state is PatternsLoading) {
                      return const _PatternsLoadingWidget();
                    } else if (state is PatternsLoaded) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PatternAnalysisCard(patterns: state.patterns),
                      );
                    } else if (state is PatternsError) {
                      return _PatternsErrorWidget(
                        message: state.message,
                        onRetry: () {
                          if (!context.read<PatternsBloc>().isClosed) {
                            context.read<PatternsBloc>().add(
                              LoadPatternAnalysis([]),
                            );
                          }
                        },
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PatternsLoadingWidget extends StatelessWidget {
  const _PatternsLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Анализируем паттерны настроения...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternsErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PatternsErrorWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.withOpacity(0.7),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка анализа',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: Text('common.try_again'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
