import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadUserTasks();
    });
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red.shade700;
      case 'high':
        return Colors.orange.shade800;
      case 'medium':
        return Colors.amber.shade700;
      default:
        return Colors.blue.shade600;
    }
  }

  // --- NEW: Analytics Banner UI Components ---
  Widget _buildAnalyticsBanner(TaskProvider taskProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statColumn('Active', taskProvider.totalActiveIncidents, Colors.lightBlueAccent),
          _statColumn('Critical', taskProvider.criticalAlerts, Colors.redAccent),
          _statColumn('Resolved', taskProvider.resolvedIncidents, Colors.greenAccent),
        ],
      ),
    );
  }

  Widget _statColumn(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade400),
        ),
      ],
    );
  }
  // ------------------------------------------

  void _showAddTaskModal(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedSeverity = 'Medium';
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Report New Incident',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Incident Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description / Details',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedSeverity,
                    decoration: const InputDecoration(
                      labelText: 'Severity Level',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Low', 'Medium', 'High', 'Critical'].map((level) {
                      return DropdownMenuItem(value: level, child: Text(level));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedSeverity = val);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;

                      Provider.of<TaskProvider>(context, listen: false).createNewTask(
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        severity: selectedSeverity,
                        userId: currentUserId,
                      );

                      Navigator.pop(context);
                    },
                    child: const Text('SUBMIT INCIDENT', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OpsBoard Command Center', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = taskProvider.tasks;

          return Column(
            children: [
              // Inject the banner at the top!
              _buildAnalyticsBanner(taskProvider),

              Expanded(
                child: tasks.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No Active Incidents Reported',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      const Text('Tap the "+" button below to log a new ticket.'),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: tasks.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final TaskModel task = tasks[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getSeverityColor(task.severity),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    task.severity.toUpperCase(),
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              task.description,
                              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DropdownButton<String>(
                                  value: task.status,
                                  underline: const SizedBox(),
                                  items: ['Open', 'In Progress', 'Resolved'].map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                    );
                                  }).toList(),
                                  onChanged: (newStatus) {
                                    if (newStatus != null) {
                                      taskProvider.changeTaskStatus(task.id, newStatus);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () => taskProvider.removeTask(task.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskModal(context),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Incident'),
      ),
    );
  }
}