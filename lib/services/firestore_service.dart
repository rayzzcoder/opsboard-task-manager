import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Helper getter to secure the current user's task subcollection path
  CollectionReference<Map<String, dynamic>>? get _tasksRef {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('tasks');
  }

  // 1. READ: Stream tasks in real-time (newest first)
  Stream<List<TaskModel>> getTasks() {
    final ref = _tasksRef;
    if (ref == null) return Stream.value([]);

    return ref.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 2. CREATE: Add a new incident/task
  Future<void> addTask(TaskModel task) async {
    final ref = _tasksRef;
    if (ref == null) return;
    await ref.add(task.toMap());
  }

  // 3. UPDATE: Modify specific fields (e.g., status, severity, title)
  Future<void> updateTask(String taskId, Map<String, dynamic> updatedData) async {
    final ref = _tasksRef;
    if (ref == null) return;
    await ref.doc(taskId).update(updatedData);
  }

  // 4. DELETE: Remove an incident document
  Future<void> deleteTask(String taskId) async {
    final ref = _tasksRef;
    if (ref == null) return;
    await ref.doc(taskId).delete();
  }
}