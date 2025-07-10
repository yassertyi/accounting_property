import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../models/material_item.dart';
import 'material_state.dart';

class MaterialCubit extends Cubit<MaterialState> {
  MaterialCubit() : super(MaterialInitial());

  final Box<MaterialItem> _materialBox = Hive.box<MaterialItem>('materials');

  void loadMaterials(int supplierId) {
    final materials = _materialBox.values.where((m) => m.supplierId == supplierId).toList();
    emit(MaterialLoaded(materials));
  }

  void addMaterial(MaterialItem material) async {
    await _materialBox.add(material);
    loadMaterials(material.supplierId);
  }

  void deleteMaterialByKey(dynamic key, int supplierId) async {
    await _materialBox.delete(key);
    loadMaterials(supplierId);
  }
}
