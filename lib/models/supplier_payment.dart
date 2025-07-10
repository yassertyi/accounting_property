import 'package:hive/hive.dart';

part 'supplier_payment.g.dart';

@HiveType(typeId: 4)
class SupplierPayment extends HiveObject {
  @HiveField(0)
  int supplierId;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String note;

  SupplierPayment({
    required this.supplierId,
    required this.amount,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}