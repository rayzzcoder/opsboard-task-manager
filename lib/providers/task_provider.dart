import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  String _currentFilter = 'All';

  // --- NEW: Search Engine State ---
  String _searchQuery = '';
  // --------------------------------

  int _documentLimit = 10;
  StreamSubscription<List<TaskModel>>? _taskSubscription;
  bool _isFetchingMore = false;

  String get currentFilter => _currentFilter;
  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get isFetchingMore => _isFetchingMore;

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // --- NEW: Method to update search query ---
  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }
  // ------------------------------------------

  // --- UPDATED: Applies both Chip Filters AND Search Queries simultaneously ---
  List<TaskModel> get filteredTasks {
    List<TaskModel> tempTasks = _tasks;

    // 1. Apply the Chip Filter (Open, Critical, etc.)
    if (_currentFilter == 'Critical') {
      tempTasks = tempTasks.where((t) => t.severity.toLowerCase() == 'critical').toList();
    } else if (_currentFilter != 'All') {
      tempTasks = tempTasks.where((t) => t.status == _currentFilter).toList();
    }

    // 2. Apply the Search Bar Text Filter
    if (_searchQuery.isNotEmpty) {
      tempTasks = tempTasks.where((t) =>
      t.title.toLowerCase().contains(_searchQuery) ||
          t.description.toLowerCase().contains(_searchQuery)
      ).toList();
    }

    return tempTasks;
  }
  // -----------------------------------------------------------------------------

  int get totalActiveIncidents => _tasks.where((task) => task.status != 'Resolved').length;
  int get criticalAlerts => _tasks.where((task) => task.severity.toLowerCase() == 'critical' && task.status != 'Resolved').length;
  int get resolvedIncidents => _tasks.where((task) => task.status == 'Resolved').length;

  void loadUserTasks() {
    _currentFilter = 'All';
    _searchQuery = ''; // Reset search on login
    _documentLimit = 10;
    _isLoading = true;
    notifyListeners();

    _listenToTasks();
  }

  void _listenToTasks() {
    _taskSubscription?.cancel();

    _taskSubscription = _firestoreService.getTasks(_documentLimit).listen((taskList) {
      _tasks = taskList;
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      _isFetchingMore = false;
      notifyListeners();
    });
  }

  void loadMoreTasks() {
    if (_isFetchingMore) return;

    if (_tasks.length < _documentLimit) return;

    _isFetchingMore = true;
    _documentLimit += 10;
    notifyListeners();

    _listenToTasks();
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
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
      createdAt: DateTime.now(),
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