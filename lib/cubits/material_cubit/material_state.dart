import 'package:equatable/equatable.dart';
import '../../models/material_item.dart';

abstract class MaterialState extends Equatable {
  const MaterialState();

  @override
  List<Object> get props => [];
}

class MaterialInitial extends MaterialState {}

class MaterialLoaded extends MaterialState {
  final List<MaterialItem> materials;

  const MaterialLoaded(this.materials);

  @override
  List<Object> get props => [materials];
}

class MaterialError {}
