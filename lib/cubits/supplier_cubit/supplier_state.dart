import 'package:equatable/equatable.dart';
import '../../models/supplier.dart';

abstract class SupplierState extends Equatable {
  const SupplierState();

  @override
  List<Object> get props => [];
}

class SupplierInitial extends SupplierState {}

class SupplierLoaded extends SupplierState {
  final List<Supplier> suppliers;

  const SupplierLoaded(this.suppliers);

  @override
  List<Object> get props => [suppliers];
}
