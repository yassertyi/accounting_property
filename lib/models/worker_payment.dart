import 'package:hive/hive.dart';

part 'worker_payment.g.dart';

@HiveType(typeId: 1)
class WorkerPayment extends HiveObject {
  @HiveField(0)
  int workerId;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String note;

  WorkerPayment({
    required this.workerId,
    required this.amount,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'workerId': workerId,
      'amount': amount,
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}