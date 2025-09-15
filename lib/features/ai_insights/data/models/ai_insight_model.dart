import 'package:hive/hive.dart';
import '../../domain/entities/ai_insight.dart';

part 'ai_insight_model.g.dart';

@HiveType(typeId: 1)
class AIInsightModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int typeValue;

  @HiveField(2)
  String title;

  @HiveField(3)
  String description;

  @HiveField(4)
  String? action;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  int priority;

  @HiveField(7)
  Map<String, dynamic>? metadata;

  AIInsightModel({
    required this.id,
    required this.typeValue,
    required this.title,
    required this.description,
    this.action,
    required this.createdAt,
    this.priority = 1,
    this.metadata,
  });

  factory AIInsightModel.fromEntity(AIInsight insight) {
    return AIInsightModel(
      id: insight.id,
      typeValue: insight.type.index,
      title: insight.title,
      description: insight.description,
      action: insight.action,
      createdAt: insight.createdAt,
      priority: insight.priority,
      metadata: insight.metadata,
    );
  }

  AIInsight toEntity() {
    return AIInsight(
      id: id,
      type: InsightType.values[typeValue],
      title: title,
      description: description,
      action: action,
      createdAt: createdAt,
      priority: priority,
      metadata: metadata,
    );
  }
}

