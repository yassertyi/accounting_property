import 'package:equatable/equatable.dart';
import '../../models/worker.dart';

abstract class WorkerState extends Equatable {
  const WorkerState();

  @override
  List<Object> get props => [];
}

class WorkerInitial extends WorkerState {}

class WorkerLoaded extends WorkerState {
  final List<Worker> workers;

  const WorkerLoaded(this.workers);

  @override
  List<Object> get props => [workers];
}
