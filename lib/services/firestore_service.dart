import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasksRef {
    return _db.collection('tasks');
  }

  Stream<List<TaskModel>> getTasks(int documentLimit) {
    return _tasksRef
        .orderBy('createdAt', descending: true)
        .limit(documentLimit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> addTask(TaskModel task) async {
    await _tasksRef.add(task.toMap());
  }

  Future<void> updateTask(String taskId, Map<String, dynamic> updatedData) async {
    await _tasksRef.doc(taskId).update(updatedData);
  }

  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }

  // --- NEW: Fetch tasks for a specific team ---
  Stream<List<TaskModel>> getTeamTasks(String teamName) {
    return _tasksRef // Reused your _tasksRef getter for cleaner code
        .where('assignee', isEqualTo: teamName)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs
          .map((doc) =>
      // FIX: Removed the unnecessary 'as Map<String, dynamic>' cast
      TaskModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort locally to avoid needing a complex Firebase composite index
      tasks.sort((a, b) =>
          (b.createdAt ?? DateTime.now()).compareTo(
              a.createdAt ?? DateTime.now()));
      return tasks;
    });
  }
}