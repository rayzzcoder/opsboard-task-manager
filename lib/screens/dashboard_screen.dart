import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import '../models/task_model.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userRole = 'Agent';
  String _userTeam = 'Unassigned'; // --- NEW: Store the user's team ---

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadUserTasks();
    });
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _userRole = doc.data()?['role'] ?? 'Agent';
            _userTeam = doc.data()?['team'] ?? 'Unassigned'; // --- NEW: Fetch their team ---
          });
        }
      } catch (e) {
        debugPrint("Error fetching role: $e");
      }
    }
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

  Widget _buildAnalyticsBanner(TaskProvider taskProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
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

  Widget _buildFilterRow(TaskProvider taskProvider) {
    final filters = ['All', 'Critical', 'Open', 'In Progress', 'Resolved'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: filters.map((filter) {
          final isSelected = taskProvider.currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.blueGrey.shade800,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  )
              ),
              selected: isSelected,
              selectedColor: Colors.blueGrey.shade700,
              backgroundColor: Colors.grey.shade200,
              onSelected: (selected) {
                if (selected) {
                  taskProvider.setFilter(filter);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showAddTaskModal(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedSeverity = 'Medium';
    String selectedAssignee = 'Unassigned';
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

                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Severity',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSeverity,
                              isDense: true,
                              items: ['Low', 'Medium', 'High', 'Critical'].map((level) {
                                return DropdownMenuItem(value: level, child: Text(level));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedSeverity = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Assign To',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedAssignee,
                              isDense: true,
                              items: ['Unassigned', 'Alpha Team', 'Bravo Team', 'Cyber Sec', 'Net Ops'].map((team) {
                                return DropdownMenuItem(value: team, child: Text(team));
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedAssignee = val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
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
                        assignee: selectedAssignee,
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
        // --- NEW: Shows exact Role AND Team ---
        title: Text('OpsBoard ($_userRole - $_userTeam)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                tooltip: 'Toggle Theme',
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
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

          final displayTasks = taskProvider.filteredTasks;

          return Column(
            children: [
              _buildAnalyticsBanner(taskProvider),
              _buildFilterRow(taskProvider),

              Expanded(
                child: displayTasks.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'No incidents match this filter',
                        style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: displayTasks.length,
                  padding: const EdgeInsets.only(left: 12, right: 12, bottom: 80),
                  itemBuilder: (context, index) {
                    final TaskModel task = displayTasks[index];
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
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 14),
                            ),
                            const SizedBox(height: 12),

                            Row(
                              children: [
                                Icon(Icons.assignment_ind_outlined, size: 16, color: Colors.blueGrey.shade400),
                                const SizedBox(width: 6),
                                Text(
                                  task.assignee,
                                  style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DropdownButton<String>(
                                  value: task.status,
                                  underline: const SizedBox(),
                                  // --- NEW: STRICT SECURITY CHECK ---
                                  // Only Admin, or an Agent assigned to THIS team, can edit status!
                                  onChanged: (_userRole == 'Admin' || (_userRole == 'Agent' && task.assignee == _userTeam))
                                      ? (newStatus) {
                                    if (newStatus != null) {
                                      taskProvider.changeTaskStatus(task.id, newStatus);
                                    }
                                  }
                                      : null, // Otherwise disable the dropdown!
                                  // ----------------------------------
                                  items: ['Open', 'In Progress', 'Resolved'].map((status) {
                                    return DropdownMenuItem(
                                      value: status,
                                      child: Text(status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                    );
                                  }).toList(),
                                ),
                                if (_userRole == 'Admin')
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => taskProvider.removeTask(task.id),
                                  )
                                else
                                  const SizedBox(width: 48),
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
      floatingActionButton: _userRole == 'Admin'
          ? FloatingActionButton.extended(
        onPressed: () => _showAddTaskModal(context),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Incident'),
      )
          : null,
    );
  }
}