import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import '../../models/worker.dart';
import 'worker_state.dart';

class WorkerCubit extends Cubit<WorkerState> {
  WorkerCubit() : super(WorkerInitial());

  final Box<Worker> _workerBox = Hive.box<Worker>('workers');
  List<Worker> _allWorkers = [];

  void loadWorkers() {
    _allWorkers = _workerBox.values.toList();
    emit(WorkerLoaded(_allWorkers));
  }

  void addWorker(Worker worker) async {
    await _workerBox.add(worker);
    loadWorkers();
  }

  void deleteWorker(int index) async {
    await _workerBox.deleteAt(index);
    loadWorkers();
  }

  void filterWorkers(String query) {
    final filtered = _allWorkers.where((worker) =>
      worker.name.toLowerCase().contains(query.toLowerCase())
    ).toList();

    emit(WorkerLoaded(filtered));
  }
}
