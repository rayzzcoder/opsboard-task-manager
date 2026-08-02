import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _taskController = TextEditingController();

  // This is the function that talks to Firestore!
  Future<void> _addTask(String taskTitle) async {
    if (taskTitle.trim().isEmpty) return;

    // 1. Get the logged-in user's UID
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // 2. Push the data to the Firestore database
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .add({
      'title': taskTitle.trim(),
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 3. Clear the text field after saving
    _taskController.clear();
  }

  // --- UPDATE (Toggle Checkbox) ---
  Future<void> _toggleTaskStatus(String taskId, bool currentStatus) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId) // Target the exact task document
        .update({
      'isCompleted': !currentStatus, // Flip the boolean
    });
  }

  // --- DELETE (Remove Task) ---
  Future<void> _deleteTask(String taskId) async {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('tasks')
        .doc(taskId) // Target the exact task document
        .delete();
  }

  // UI for the popup box to type a new task
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Task'),
        content: TextField(
          controller: _taskController,
          decoration: const InputDecoration(hintText: 'Enter task name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _addTask(_taskController.text);
              Navigator.pop(context); // Close the popup
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 1. Point the stream to the logged-in user's tasks folder
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .collection('tasks')
            .orderBy('createdAt', descending: true) // Newest tasks at the top
            .snapshots(),
        builder: (context, snapshot) {
          // 2. Handle loading and error states
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 3. Extract the list of documents
          final tasks = snapshot.data?.docs ?? [];

          // 4. Show a message if the folder is empty
          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No tasks yet. Add one!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // 5. Build the list view lazily for good performance
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final taskDoc = tasks[index];
              final taskData = taskDoc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    taskData['title'] ?? 'Untitled Task',
                    style: TextStyle(
                      decoration: taskData['isCompleted'] == true
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                    value: taskData['isCompleted'] ?? false,
                    onChanged: (bool? newValue) {
                      // Pass the document ID and current status
                      _toggleTaskStatus(taskDoc.id, taskData['isCompleted'] ?? false);
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Pass the document ID to delete it
                      _deleteTask(taskDoc.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      // The '+' button
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}