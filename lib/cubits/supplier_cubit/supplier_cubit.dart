import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../models/supplier.dart';
import 'supplier_state.dart';

class SupplierCubit extends Cubit<SupplierState> {
  SupplierCubit() : super(SupplierInitial());

  final Box<Supplier> _supplierBox = Hive.box<Supplier>('suppliers');

  void loadSuppliers() {
    final suppliers = _supplierBox.values.toList();
    emit(SupplierLoaded(suppliers));
  }

  void addSupplier(Supplier supplier) async {
    await _supplierBox.add(supplier);
    loadSuppliers();
  }

  void updateSupplier(int index, Supplier supplier) async {
    await _supplierBox.putAt(index, supplier);
    loadSuppliers();
  }

  void deleteSupplier(int index) async {
    await _supplierBox.deleteAt(index);
    loadSuppliers();
  }
}
