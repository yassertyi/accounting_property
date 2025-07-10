import 'package:hive/hive.dart';

part 'material_item.g.dart';

@HiveType(typeId: 3)
class MaterialItem extends HiveObject {
  @HiveField(0)
  int supplierId;

  @HiveField(1)
  String name;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  double unitPrice;

  MaterialItem({
    required this.supplierId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  double get totalPrice => quantity * unitPrice;

  Map<String, dynamic> toJson() {
    return {
      'supplierId': supplierId,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}