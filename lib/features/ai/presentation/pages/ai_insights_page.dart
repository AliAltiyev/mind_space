import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/widgets/core/amazing_background.dart' as amazing;
import '../../../../presentation/widgets/core/amazing_glass_surface.dart' as amazing;
import '../../../../core/services/ai_analysis_service.dart';

/// Страница ИИ инсайтов и рекомендаций
class AIInsightsPage extends ConsumerStatefulWidget {
  const AIInsightsPage({super.key});

  @override
  ConsumerState<AIInsightsPage> createState() => _AIInsightsPageState();
}

class _AIInsightsPageState extends ConsumerState<AIInsightsPage> {
  final AIAnalysisService _aiService = AIAnalysisService();
  MoodPatternAnalysis? _patternAnalysis;
  ActivityCorrelationAnalysis? _activityAnalysis;
  List<String> _recommendations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock данные для демонстрации
      final mockEntries = _generateMockEntries();
      
      final patternAnalysis = await _aiService.analyzeMoodPatterns(mockEntries);
      final activityAnalysis = await _aiService.analyzeActivityCorrelations(mockEntries);
      final recommendations = await _aiService.generatePersonalRecommendations(
        mockEntries,
        patternAnalysis,
        activityAnalysis,
      );

      setState(() {
        _patternAnalysis = patternAnalysis;
        _activityAnalysis = activityAnalysis;
        _recommendations = recommendations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading insights: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return amazing.AmazingBackground(
      type: amazing.BackgroundType.cosmic,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'AI Insights',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 10)],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadInsights,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFB9E3A)),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview
                    _buildOverview(),
                    
                    const SizedBox(height: 20),
                    
                    // Pattern Analysis
                    if (_patternAnalysis != null) _buildPatternAnalysis(),
                    
                    const SizedBox(height: 20),
                    
                    // Activity Correlations
                    if (_activityAnalysis != null) _buildActivityCorrelations(),
                    
                    const SizedBox(height: 20),
                    
                    // Recommendations
                    _buildRecommendations(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildOverview() {
    return amazing.AmazingGlassSurface(
      effectType: amazing.GlassEffectType.neon,
      colorScheme: amazing.ColorScheme.neon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.psychology,
                color: Color(0xFFFB9E3A),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'AI Analysis Overview',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 8)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Based on your mood tracking data, here are personalized insights and recommendations to help you understand and improve your mental well-being.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternAnalysis() {
    final analysis = _patternAnalysis!;
    
    return amazing.AmazingGlassSurface(
      effectType: amazing.GlassEffectType.cyber,
      colorScheme: amazing.ColorScheme.cyber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mood Pattern Analysis',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Color(0xFFFCEF91), blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 16),
          
          // Average Mood
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  title: 'Average Mood',
                  value: analysis.averageMood.toStringAsFixed(1),
                  icon: Icons.trending_up,
                  color: _getMoodColor(analysis.averageMood),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TrendCard(
                  trend: analysis.trend,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Insights
          Text(
            'Key Insights',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          ...analysis.insights.map((insight) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline,
                  color: Color(0xFFFB9E3A),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildActivityCorrelations() {
    final analysis = _activityAnalysis!;
    
    return amazing.AmazingGlassSurface(
      effectType: amazing.GlassEffectType.rainbow,
      colorScheme: amazing.ColorScheme.rainbow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity Impact Analysis',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 16),
          
          // Top Positive Activities
          if (analysis.topPositiveActivities.isNotEmpty) ...[
            Text(
              'Positive Impact Activities',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 8),
            ...analysis.topPositiveActivities.map((activity) => _ActivityItem(
              activity: activity,
              isPositive: true,
            )),
            const SizedBox(height: 16),
          ],
          
          // Top Negative Activities
          if (analysis.topNegativeActivities.isNotEmpty) ...[
            Text(
              'Activities to Consider Changing',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 8),
            ...analysis.topNegativeActivities.map((activity) => _ActivityItem(
              activity: activity,
              isPositive: false,
            )),
          ],
          
          if (analysis.topPositiveActivities.isEmpty && analysis.topNegativeActivities.isEmpty)
            const Text(
              'Add more activities to your mood entries to see activity correlations.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white60,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return amazing.AmazingGlassSurface(
      effectType: amazing.GlassEffectType.cosmic,
      colorScheme: amazing.ColorScheme.cosmic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFFFB9E3A),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Personalized Recommendations',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(color: Color(0xFFFB9E3A), blurRadius: 8)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ..._recommendations.asMap().entries.map((entry) {
            final index = entry.key;
            final recommendation = entry.value;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFB9E3A).withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFB9E3A).withOpacity(0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFB9E3A),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _getMoodColor(double mood) {
    if (mood >= 4.0) return const Color(0xFF6D67E4);
    if (mood >= 3.0) return const Color(0xFFFCEF91);
    if (mood >= 2.0) return const Color(0xFFFB9E3A);
    if (mood >= 1.0) return const Color(0xFFE6521F);
    return const Color(0xFFEA2F14);
  }

  List<MoodEntry> _generateMockEntries() {
    final now = DateTime.now();
    return [
      MoodEntry(
        mood: 4,
        dateTime: now.subtract(const Duration(days: 1)),
        note: 'Great day!',
        activities: ['exercise', 'work', 'friends'],
      ),
      MoodEntry(
        mood: 3,
        dateTime: now.subtract(const Duration(days: 2)),
        note: 'Okay day',
        activities: ['work', 'stress'],
      ),
      MoodEntry(
        mood: 5,
        dateTime: now.subtract(const Duration(days: 3)),
        note: 'Amazing day!',
        activities: ['exercise', 'nature', 'friends'],
      ),
      MoodEntry(
        mood: 2,
        dateTime: now.subtract(const Duration(days: 4)),
        note: 'Not feeling well',
        activities: ['work', 'stress', 'tired'],
      ),
      MoodEntry(
        mood: 4,
        dateTime: now.subtract(const Duration(days: 5)),
        note: 'Good day',
        activities: ['exercise', 'work'],
      ),
      MoodEntry(
        mood: 3,
        dateTime: now.subtract(const Duration(days: 6)),
        note: 'Average day',
        activities: ['work'],
      ),
      MoodEntry(
        mood: 4,
        dateTime: now.subtract(const Duration(days: 7)),
        note: 'Feeling good',
        activities: ['exercise', 'nature'],
      ),
    ];
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final MoodTrend trend;

  const _TrendCard({required this.trend});

  @override
  Widget build(BuildContext context) {
    String trendText;
    Color trendColor;
    IconData trendIcon;

    switch (trend) {
      case MoodTrend.improving:
        trendText = 'Improving';
        trendColor = Colors.green;
        trendIcon = Icons.trending_up;
        break;
      case MoodTrend.declining:
        trendText = 'Declining';
        trendColor = Colors.red;
        trendIcon = Icons.trending_down;
        break;
      case MoodTrend.stable:
        trendText = 'Stable';
        trendColor = Colors.orange;
        trendIcon = Icons.trending_flat;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            trendColor.withOpacity(0.2),
            Colors.transparent,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: trendColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(trendIcon, color: trendColor, size: 24),
          const SizedBox(height: 8),
          Text(
            trendText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: trendColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Trend',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String activity;
  final bool isPositive;

  const _ActivityItem({
    required this.activity,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isPositive ? Colors.green : Colors.red).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isPositive ? Colors.green : Colors.red).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.thumb_up : Icons.thumb_down,
            color: isPositive ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            activity,
            style: TextStyle(
              fontSize: 14,
              color: isPositive ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}