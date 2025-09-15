import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/ai_features_provider.dart';
import '../../../../presentation/widgets/core/glass_surface.dart';
import '../blocs/gratitude_bloc.dart';
import '../widgets/gratitude_suggestion_card.dart';

/// Страница журнала благодарности
class GratitudeJournalPage extends ConsumerStatefulWidget {
  const GratitudeJournalPage({super.key});

  @override
  ConsumerState<GratitudeJournalPage> createState() =>
      _GratitudeJournalPageState();
}

class _GratitudeJournalPageState extends ConsumerState<GratitudeJournalPage> {
  @override
  void initState() {
    super.initState();
    // Загружаем предложения благодарности при открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<GratitudeBloc>().isClosed) {
        context.read<GratitudeBloc>().add(LoadGratitudePrompts([]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gratitude Journal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (!context.read<GratitudeBloc>().isClosed) {
                context.read<GratitudeBloc>().add(LoadGratitudePrompts([]));
              }
            },
          ),
        ],
      ),
      body: BlocProvider<GratitudeBloc>(
        create: (context) => ref.read(gratitudeBlocProvider),
        child: RefreshIndicator(
          onRefresh: () async {
            if (!context.read<GratitudeBloc>().isClosed) {
              context.read<GratitudeBloc>().add(LoadGratitudePrompts([]));
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
                                Icons.favorite,
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
                                    'Gratitude Journal',
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
                                    'Записывайте то, за что благодарны',
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

                // Gratitude Content
                BlocBuilder<GratitudeBloc, GratitudeState>(
                  builder: (context, state) {
                    if (state is GratitudeLoading) {
                      return const _GratitudeLoadingWidget();
                    } else if (state is GratitudeLoaded) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GratitudeSuggestionCard(
                          gratitude: state.gratitude,
                        ),
                      );
                    } else if (state is GratitudeError) {
                      return _GratitudeErrorWidget(
                        message: state.message,
                        onRetry: () {
                          if (!context.read<GratitudeBloc>().isClosed) {
                            context.read<GratitudeBloc>().add(
                              LoadGratitudePrompts([]),
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

class _GratitudeLoadingWidget extends StatelessWidget {
  const _GratitudeLoadingWidget();

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
              'Генерируем предложения для благодарности...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _GratitudeErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _GratitudeErrorWidget({required this.message, required this.onRetry});

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
