import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _tasksRef {
    return _db.collection('tasks');
  }

  // --- NEW: Added limit parameter for Pagination ---
  Stream<List<TaskModel>> getTasks(int documentLimit) {
    return _tasksRef
        .limit(documentLimit) // Only fetch the exact amount we ask for!
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
}