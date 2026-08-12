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
  String _userTeam = 'Unassigned';
  int _selectedIndex = 0;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchUserRole();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 50) {
        Provider.of<TaskProvider>(context, listen: false).loadMoreTasks();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadUserTasks();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && mounted) {
          setState(() {
            _userRole = doc.data()?['role'] ?? 'Agent';
            _userTeam = doc.data()?['team'] ?? 'Unassigned';
          });
        }
      } catch (e) {
        debugPrint("Error fetching role: $e");
      }
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical': return Colors.red.shade700;
      case 'high': return Colors.orange.shade800;
      case 'medium': return Colors.amber.shade700;
      default: return Colors.blue.shade600;
    }
  }

  Widget _buildAnalyticsBanner(TaskProvider taskProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
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
        Text(count.toString(), style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
      ],
    );
  }

  Widget _buildSearchBar(TaskProvider taskProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        onChanged: (value) => taskProvider.setSearchQuery(value),
        decoration: InputDecoration(
          hintText: 'Search incident titles or descriptions...',
          prefixIcon: const Icon(Icons.search, color: Colors.blueGrey),
          filled: true,
          fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
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
                if (selected) taskProvider.setFilter(filter);
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Report New Incident', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Incident Title', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description / Details', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Severity', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSeverity,
                              isDense: true,
                              items: ['Low', 'Medium', 'High', 'Critical'].map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                              onChanged: (val) { if (val != null) setModalState(() => selectedSeverity = val); },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Assign To', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedAssignee,
                              isDense: true,
                              items: ['Unassigned', 'Alpha Team', 'Bravo Team', 'Cyber Sec', 'Net Ops'].map((team) => DropdownMenuItem(value: team, child: Text(team))).toList(),
                              onChanged: (val) { if (val != null) setModalState(() => selectedAssignee = val); },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.blueGrey, foregroundColor: Colors.white),
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

  void _showEditTaskModal(BuildContext context, TaskModel task) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);
    String selectedSeverity = ['Low', 'Medium', 'High', 'Critical'].contains(task.severity) ? task.severity : 'Medium';
    String selectedAssignee = ['Unassigned', 'Alpha Team', 'Bravo Team', 'Cyber Sec', 'Net Ops'].contains(task.assignee) ? task.assignee : 'Unassigned';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 24),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Edit Incident Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Incident Title', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  TextField(controller: descController, maxLines: 3, decoration: const InputDecoration(labelText: 'Description / Details', border: OutlineInputBorder())),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Severity', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedSeverity,
                              isDense: true,
                              items: ['Low', 'Medium', 'High', 'Critical'].map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                              onChanged: (val) { if (val != null) setModalState(() => selectedSeverity = val); },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Assign To', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedAssignee,
                              isDense: true,
                              items: ['Unassigned', 'Alpha Team', 'Bravo Team', 'Cyber Sec', 'Net Ops'].map((team) => DropdownMenuItem(value: team, child: Text(team))).toList(),
                              onChanged: (val) { if (val != null) setModalState(() => selectedAssignee = val); },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;
                      Provider.of<TaskProvider>(context, listen: false).editTaskDetails(
                        taskId: task.id,
                        title: titleController.text.trim(),
                        description: descController.text.trim(),
                        severity: selectedSeverity,
                        assignee: selectedAssignee,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('SAVE CHANGES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  void _showNotesModal(BuildContext context, TaskModel task, TaskProvider taskProvider) {
    final commentController = TextEditingController();
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? 'Unknown User';
    final displayName = _userRole == 'Admin' ? 'Admin Command' : _userTeam;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade900,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.forum, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Activity Log: ${task.title}',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: task.comments.isEmpty
                      ? Center(
                    child: Text(
                      'No notes yet. Be the first to add an update!',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: task.comments.length,
                    itemBuilder: (context, index) {
                      // --- BULLETPROOF NULL SAFETY CHECK ---
                      final rawComment = task.comments[index];
                      if (rawComment == null || rawComment is! Map) {
                        return const SizedBox.shrink(); // Skips corrupted/deleted Firebase data safely
                      }

                      final comment = rawComment as Map<String, dynamic>;
                      final authorEmail = comment['authorEmail']?.toString() ?? 'Unknown';
                      final isMe = authorEmail == currentUserEmail;
                      final displayAuthor = comment['authorName']?.toString() ?? authorEmail.split('@')[0];

                      // Safe Timestamp Parsing
                      String prettyTime = '';
                      if (comment['timestamp'] != null) {
                        try {
                          final stamp = DateTime.parse(comment['timestamp'].toString());
                          prettyTime = "${stamp.month}/${stamp.day} • ${stamp.hour}:${stamp.minute.toString().padLeft(2, '0')}";
                        } catch (e) {
                          prettyTime = 'Unknown Time';
                        }
                      }

                      final textContent = comment['text']?.toString() ?? '[Deleted Message]';
                      // ------------------------------------

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          width: MediaQuery.of(context).size.width * 0.75,
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      isMe ? 'You ($displayAuthor)' : displayAuthor,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: isMe ? Colors.blue.shade800 : Colors.blueGrey.shade800,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    prettyTime,
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                textContent,
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -2))
                      ]
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(
                            hintText: 'Add an update or note...',
                            filled: true,
                            fillColor: Theme.of(context).scaffoldBackgroundColor,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: () {
                            if (commentController.text.trim().isNotEmpty) {
                              taskProvider.addComment(
                                task.id,
                                commentController.text.trim(),
                                currentUserEmail,
                                displayName,
                              );
                              commentController.clear();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncidentsTab(TaskProvider taskProvider) {
    if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final displayTasks = taskProvider.filteredTasks;

    return Column(
      children: [
        _buildAnalyticsBanner(taskProvider),
        _buildSearchBar(taskProvider),
        _buildFilterRow(taskProvider),
        Expanded(
          child: displayTasks.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text('No incidents match this filter', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
              ],
            ),
          )
              : ListView.builder(
            controller: _scrollController,
            itemCount: displayTasks.length + (taskProvider.isFetchingMore ? 1 : 0),
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 20),
            itemBuilder: (context, index) {
              if (index == displayTasks.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final TaskModel task = displayTasks[index];
              final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

              final canViewChat = _userRole == 'Admin' || task.assignee == _userTeam;
              final hasUnread = task.comments.isNotEmpty && !task.readBy.contains(currentUserEmail);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    if (canViewChat) {
                      if (hasUnread) {
                        taskProvider.markAsRead(task.id, currentUserEmail);
                      }
                      _showNotesModal(context, task, taskProvider);
                    } else {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Access Denied: Only Admins and the assigned team can view this log.'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text(task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: _getSeverityColor(task.severity), borderRadius: BorderRadius.circular(6)),
                              child: Text(task.severity.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.formattedDate,
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(task.description, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 14)),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.assignment_ind_outlined, size: 16, color: Colors.blueGrey.shade400),
                                const SizedBox(width: 6),
                                Text(task.assignee, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 13, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            if (canViewChat)
                              Row(
                                children: [
                                  Icon(
                                      Icons.forum_outlined,
                                      size: 16,
                                      color: hasUnread ? Colors.redAccent : Colors.blueGrey.shade300
                                  ),
                                  // --- UPDATED: Replaced the total count with a clean "NEW" tag ---
                                  if (hasUnread) ...[
                                    const SizedBox(width: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'NEW',
                                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ]
                                ],
                              )
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
                              onChanged: (_userRole == 'Admin' || (_userRole == 'Agent' && task.assignee == _userTeam))
                                  ? (newStatus) {
                                if (newStatus != null) taskProvider.changeTaskStatus(task.id, newStatus);
                              } : null,
                              items: ['Open', 'In Progress', 'Resolved'].map((status) {
                                return DropdownMenuItem(value: status, child: Text(status, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)));
                              }).toList(),
                            ),
                            if (_userRole == 'Admin')
                              Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.blueAccent), onPressed: () => _showEditTaskModal(context, task)),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            title: const Text('Delete Incident?', style: TextStyle(fontWeight: FontWeight.bold)),
                                            content: const Text('Are you sure you want to permanently delete this ticket? This action cannot be undone.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(context),
                                                child: const Text('CANCEL', style: TextStyle(color: Colors.blueGrey)),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  taskProvider.removeTask(task.id);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              )
                            else
                              const SizedBox(width: 48),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeamTab() {
    final teams = [
      {'name': 'Alpha Team', 'icon': Icons.security, 'color': Colors.blue},
      {'name': 'Bravo Team', 'icon': Icons.build, 'color': Colors.orange},
      {'name': 'Cyber Sec', 'icon': Icons.lock, 'color': Colors.red},
      {'name': 'Net Ops', 'icon': Icons.router, 'color': Colors.green},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teams.length,
      itemBuilder: (context, index) {
        final team = teams[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: (team['color'] as Color).withValues(alpha: 0.2),
              child: Icon(team['icon'] as IconData, color: team['color'] as Color),
            ),
            title: Text(team['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            subtitle: const Text('Operational Unit'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${team['name']} dashboard coming soon!'),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'Unknown Email';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blueGrey.shade700,
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 20),
          Text(email, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _userRole == 'Admin' ? Colors.red.shade100 : Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _userRole.toUpperCase(),
              style: TextStyle(
                color: _userRole == 'Admin' ? Colors.red.shade800 : Colors.blue.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.group, color: Colors.blueGrey),
            title: Text(_userRole == 'Admin' ? 'Clearance Level' : 'Assigned Team'),
            trailing: Text(
              _userRole == 'Admin' ? 'Global Command' : _userTeam,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _userRole == 'Admin' ? Colors.redAccent : Colors.black87,
              ),
            ),
          ),

          const Divider(),
          const ListTile(
            leading: Icon(Icons.security, color: Colors.blueGrey),
            title: Text('Account Status'),
            trailing: Text('Active', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout),
              label: const Text('SIGN OUT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: () async {
                final currentContext = context;
                await FirebaseAuth.instance.signOut();
                if (!currentContext.mounted) return;
                Navigator.pushReplacement(currentContext, MaterialPageRoute(builder: (context) => const LoginScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final List<Widget> pages = [
      _buildIncidentsTab(taskProvider),
      _buildTeamTab(),
      _buildProfileTab(),
    ];

    final List<String> pageTitles = [
      'OpsBoard ($_userRole)',
      'Team Directory',
      'Account Settings',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[_selectedIndex], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                tooltip: 'Toggle Theme',
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () async {
              final currentContext = context;
              await FirebaseAuth.instance.signOut();
              if (!currentContext.mounted) return;
              Navigator.pushReplacement(currentContext, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: pages[_selectedIndex],
      floatingActionButton: (_selectedIndex == 0 && _userRole == 'Admin')
          ? FloatingActionButton.extended(
        onPressed: () => _showAddTaskModal(context),
        backgroundColor: Colors.blueGrey.shade900,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Incident'),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blueGrey.shade700,
        unselectedItemColor: Colors.grey.shade400,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Incidents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}