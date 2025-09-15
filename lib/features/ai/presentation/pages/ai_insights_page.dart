import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/ai_features_provider.dart';
import '../../../../presentation/widgets/core/glass_surface.dart';
import '../blocs/ai_insights_bloc.dart';
import '../widgets/ai_insight_card.dart';

/// Страница AI Insights с расширенным функционалом
class AIInsightsPage extends ConsumerStatefulWidget {
  const AIInsightsPage({super.key});

  @override
  ConsumerState<AIInsightsPage> createState() => _AIInsightsPageState();
}

class _AIInsightsPageState extends ConsumerState<AIInsightsPage> {
  @override
  void initState() {
    super.initState();
    // Загружаем AI insights при открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<AIInsightsBloc>().isClosed) {
        context.read<AIInsightsBloc>().add(LoadAIInsights([]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Insights'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (!context.read<AIInsightsBloc>().isClosed) {
                context.read<AIInsightsBloc>().add(LoadAIInsights([]));
              }
            },
          ),
        ],
      ),
      body: BlocProvider<AIInsightsBloc>(
        create: (context) => ref.read(aiInsightsBlocProvider),
        child: RefreshIndicator(
          onRefresh: () async {
            if (!context.read<AIInsightsBloc>().isClosed) {
              context.read<AIInsightsBloc>().add(LoadAIInsights([]));
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
                                Icons.psychology,
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
                                    'AI Insights',
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
                                    'Персональные инсайты на основе ваших настроений',
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

                // AI Insights Content
                BlocBuilder<AIInsightsBloc, AIInsightsState>(
                  builder: (context, state) {
                    if (state is AIInsightsLoading) {
                      return const _AIInsightsLoadingWidget();
                    } else if (state is AIInsightsLoaded) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: AIInsightCard(insight: state.insight),
                      );
                    } else if (state is AIInsightsError) {
                      return _AIInsightsErrorWidget(
                        message: state.message,
                        onRetry: () {
                          if (!context.read<AIInsightsBloc>().isClosed) {
                            context.read<AIInsightsBloc>().add(
                              LoadAIInsights([]),
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

class _AIInsightsLoadingWidget extends StatelessWidget {
  const _AIInsightsLoadingWidget();

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
              'Генерируем персональные инсайты...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIInsightsErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _AIInsightsErrorWidget({required this.message, required this.onRetry});

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
              'Ошибка загрузки',
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
            ElevatedButton(onPressed: onRetry, child: const Text('Повторить')),
          ],
        ),
      ),
    );
  }
}
