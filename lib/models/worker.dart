import 'package:hive/hive.dart';

part 'worker.g.dart';

@HiveType(typeId: 0)
class Worker extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double totalAgreed;

  @HiveField(2)
  double totalPaid;

  Worker({required this.name, required this.totalAgreed, required this.totalPaid});

  double get balance => totalAgreed - totalPaid;

  double get totalCost => totalAgreed;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalAgreed': totalAgreed,
      'totalPaid': totalPaid,
    };
  }
}