import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- FIX: Global Operations Board ---
  // We removed the user ID requirement. Now, every single user (Admins and Agents)
  // points to the exact same global 'tasks' collection!
  CollectionReference<Map<String, dynamic>> get _tasksRef {
    return _db.collection('tasks');
  }

  // 1. READ: Stream global tasks in real-time
  Stream<List<TaskModel>> getTasks() {
    return _tasksRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 2. CREATE: Add a new incident/task to the global board
  Future<void> addTask(TaskModel task) async {
    await _tasksRef.add(task.toMap());
  }

  // 3. UPDATE: Modify specific fields (e.g., status, severity, title)
  Future<void> updateTask(String taskId, Map<String, dynamic> updatedData) async {
    await _tasksRef.doc(taskId).update(updatedData);
  }

  // 4. DELETE: Remove an incident document
  Future<void> deleteTask(String taskId) async {
    await _tasksRef.doc(taskId).delete();
  }
}