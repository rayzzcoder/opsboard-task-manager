import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  // --- Analytics Getters ---
  int get totalActiveIncidents => _tasks.where((task) => task.status != 'Resolved').length;

  int get criticalAlerts => _tasks.where((task) =>
  task.severity.toLowerCase() == 'critical' && task.status != 'Resolved'
  ).length;

  int get resolvedIncidents => _tasks.where((task) => task.status == 'Resolved').length;
  // -------------------------

  void loadUserTasks() {
    _isLoading = true;
    notifyListeners();

    _firestoreService.getTasks().listen((taskList) {
      _tasks = taskList;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> createNewTask({
    required String title,
    required String description,
    required String severity,
    required String userId,
  }) async {
    final newTask = TaskModel(
      id: '',
      title: title,
      description: description,
      severity: severity,
      status: 'Open',
      userId: userId,
    );

    await _firestoreService.addTask(newTask);
  }

  Future<void> changeTaskStatus(String taskId, String newStatus) async {
    await _firestoreService.updateTask(taskId, {'status': newStatus});
  }

  Future<void> removeTask(String taskId) async {
    await _firestoreService.deleteTask(taskId);
  }
}