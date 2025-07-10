import 'package:hive/hive.dart';

part 'supplier.g.dart';

@HiveType(typeId: 2)
class Supplier extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double totalCost;

  @HiveField(2)
  double totalPaid;

  Supplier({
    required this.name,
    this.totalCost = 0,
    this.totalPaid = 0,
  });

  double get balance => totalCost - totalPaid;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalCost': totalCost,
      'totalPaid': totalPaid,
    };
  }
}