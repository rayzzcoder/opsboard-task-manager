import 'dart:async'; // --- NEW: Required for managing Stream connections ---
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String _currentFilter = 'All';

  // --- NEW: Pagination Variables ---
  int _documentLimit = 10; // Start by loading 10 tickets
  StreamSubscription<List<TaskModel>>? _taskSubscription;
  bool _isFetchingMore = false;
  // --------------------------------

  String get currentFilter => _currentFilter;
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore; // Expose this so UI can show a loader at the bottom

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

  int get totalActiveIncidents => _tasks.where((task) => task.status != 'Resolved').length;
  int get criticalAlerts => _tasks.where((task) => task.severity.toLowerCase() == 'critical' && task.status != 'Resolved').length;
  int get resolvedIncidents => _tasks.where((task) => task.status == 'Resolved').length;

  void loadUserTasks() {
    _currentFilter = 'All';
    _documentLimit = 10; // Reset limit when first logging in
    _isLoading = true;
    notifyListeners();

    _listenToTasks();
  }

  // --- NEW: The Engine that handles the dynamic stream ---
  void _listenToTasks() {
    _taskSubscription?.cancel(); // Close the old 10-ticket connection

    // Open a new connection with the updated limit
    _taskSubscription = _firestoreService.getTasks(_documentLimit).listen((taskList) {
      _tasks = taskList;
      _isLoading = false;
      _isFetchingMore = false; // Turn off the bottom loader
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    });
  }

  // --- NEW: Triggered by the UI when the user scrolls to the bottom ---
  void loadMoreTasks() {
    if (_isFetchingMore) return; // Prevent spamming the database

    // If the database gave us fewer tickets than our limit, we reached the end!
    if (_tasks.length < _documentLimit) return;

    _isFetchingMore = true;
    _documentLimit += 10; // Increase the fetch limit
    notifyListeners();

    _listenToTasks(); // Restart stream with the new limit
  }

  @override
  void dispose() {
    _taskSubscription?.cancel(); // Always clean up connections to prevent memory leaks
    super.dispose();
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

  Future<void> changeTaskStatus(String taskId, String newStatus) async {
    await _firestoreService.updateTask(taskId, {'status': newStatus});
  }

  Future<void> removeTask(String taskId) async {
    await _firestoreService.deleteTask(taskId);
  }
}