import 'package:equatable/equatable.dart';

enum InsightType { pattern, recommendation, trend, warning, celebration }

class AIInsight extends Equatable {
  final String id;
  final InsightType type;
  final String title;
  final String description;
  final String? action;
  final DateTime createdAt;
  final int priority; // 1-5, где 5 - высший приоритет
  final Map<String, dynamic>? metadata;

  const AIInsight({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.action,
    required this.createdAt,
    this.priority = 1,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    type,
    title,
    description,
    action,
    createdAt,
    priority,
    metadata,
  ];

  AIInsight copyWith({
    String? id,
    InsightType? type,
    String? title,
    String? description,
    String? action,
    DateTime? createdAt,
    int? priority,
    Map<String, dynamic>? metadata,
  }) {
    return AIInsight(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      action: action ?? this.action,
      createdAt: createdAt ?? this.createdAt,
      priority: priority ?? this.priority,
      metadata: metadata ?? this.metadata,
    );
  }
}
