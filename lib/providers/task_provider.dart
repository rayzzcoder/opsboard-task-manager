import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  String _currentFilter = 'All';

  String get currentFilter => _currentFilter;

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  List<TaskModel> get filteredTasks {
    if (_currentFilter == 'All') return _tasks;
    if (_currentFilter == 'Critical') {
      return _tasks.where((t) => t.severity.toLowerCase() == 'critical').toList();
    }
    return _tasks.where((t) => t.status == _currentFilter).toList();
  }

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  int get totalActiveIncidents => _tasks.where((task) => task.status != 'Resolved').length;

  int get criticalAlerts => _tasks.where((task) =>
  task.severity.toLowerCase() == 'critical' && task.status != 'Resolved'
  ).length;

  int get resolvedIncidents => _tasks.where((task) => task.status == 'Resolved').length;

  void loadUserTasks() {
    _currentFilter = 'All';
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
    required String assignee,
  }) async {
    final newTask = TaskModel(
      id: '',
      title: title,
      description: description,
      severity: severity,
      status: 'Open',
      userId: userId,
      assignee: assignee,
    );

    await _firestoreService.addTask(newTask);
  }

  // --- NEW: Full Edit Capability ---
  Future<void> editTaskDetails({
    required String taskId,
    required String title,
    required String description,
    required String severity,
    required String assignee,
  }) async {
    await _firestoreService.updateTask(taskId, {
      'title': title,
      'description': description,
      'severity': severity,
      'assignee': assignee,
    });
  }
  // ---------------------------------

  Future<void> changeTaskStatus(String taskId, String newStatus) async {
    await _firestoreService.updateTask(taskId, {'status': newStatus});
  }

  Future<void> removeTask(String taskId) async {
    await _firestoreService.deleteTask(taskId);
  }
}