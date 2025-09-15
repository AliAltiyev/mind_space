import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/ai_features_provider.dart';
import '../../../../presentation/widgets/core/glass_surface.dart';
import '../blocs/meditation_bloc.dart';
import '../widgets/meditation_suggestion_card.dart';

/// Страница медитации и релаксации
class MeditationPage extends ConsumerStatefulWidget {
  const MeditationPage({super.key});

  @override
  ConsumerState<MeditationPage> createState() => _MeditationPageState();
}

class _MeditationPageState extends ConsumerState<MeditationPage> {
  @override
  void initState() {
    super.initState();
    // Загружаем предложения медитации при открытии страницы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.read<MeditationBloc>().isClosed) {
        context.read<MeditationBloc>().add(LoadMeditationSession([]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (!context.read<MeditationBloc>().isClosed) {
                context.read<MeditationBloc>().add(LoadMeditationSession([]));
              }
            },
          ),
        ],
      ),
      body: BlocProvider<MeditationBloc>(
        create: (context) => ref.read(meditationBlocProvider),
        child: RefreshIndicator(
          onRefresh: () async {
            if (!context.read<MeditationBloc>().isClosed) {
              context.read<MeditationBloc>().add(LoadMeditationSession([]));
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
                                Icons.self_improvement,
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
                                    'Meditation',
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
                                    'Персональные практики медитации и релаксации',
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

                // Meditation Content
                BlocBuilder<MeditationBloc, MeditationState>(
                  builder: (context, state) {
                    if (state is MeditationLoading) {
                      return const _MeditationLoadingWidget();
                    } else if (state is MeditationLoaded) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: MeditationSuggestionCard(
                          meditation: state.meditation,
                        ),
                      );
                    } else if (state is MeditationError) {
                      return _MeditationErrorWidget(
                        message: state.message,
                        onRetry: () {
                          if (!context.read<MeditationBloc>().isClosed) {
                            context.read<MeditationBloc>().add(
                              LoadMeditationSession([]),
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

class _MeditationLoadingWidget extends StatelessWidget {
  const _MeditationLoadingWidget();

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
              'Подбираем персональные практики медитации...',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeditationErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MeditationErrorWidget({required this.message, required this.onRetry});

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
