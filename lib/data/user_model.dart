import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  double walletBalance;

  @HiveField(4)
  DateTime createdAt;

  // 🆕 Added: wallet limit for user customization
  @HiveField(5)
  double walletLimit;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.walletBalance,
    this.walletLimit = 10000.0, // default limit
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
