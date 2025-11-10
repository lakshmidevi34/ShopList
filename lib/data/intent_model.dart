import 'package:hive/hive.dart';

part 'intent_model.g.dart';

@HiveType(typeId: 0)
class IntentItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double expectedPrice;

  @HiveField(3)
  int desireLevel; // 1-10

  @HiveField(4)
  String priority; // now, later, someday

  @HiveField(5)
  String reason;

  @HiveField(6)
  bool bought;

  @HiveField(7)
  DateTime createdAt;

  IntentItem({
    required this.id,
    required this.name,
    required this.expectedPrice,
    required this.desireLevel,
    required this.priority,
    required this.reason,
    this.bought = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
