import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/stats_bloc.dart';
import '../widgets/stats_grid_widget.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: BlocProvider(
        create: (context) => context.read<StatsBloc>()..add(LoadStats()),
        child: const _StatisticsPageContent(),
      ),
    );
  }
}

class _StatisticsPageContent extends StatelessWidget {
  const _StatisticsPageContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatsBloc, StatsState>(
      builder: (context, state) {
        if (state is StatsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StatsLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<StatsBloc>().add(RefreshStats());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: StatsGridWidget(stats: state.stats),
            ),
          );
        } else if (state is StatsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Ошибка загрузки статистики',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<StatsBloc>().add(LoadStats());
                  },
                  child: const Text('Повторить'),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('Неизвестное состояние'));
      },
    );
  }
}
