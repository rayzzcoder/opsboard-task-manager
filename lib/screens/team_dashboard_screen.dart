import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../services/firestore_service.dart';

class TeamDashboardScreen extends StatefulWidget {
  final String teamName;
  final Color teamColor;
  final IconData teamIcon;

  const TeamDashboardScreen({
    super.key,
    required this.teamName,
    required this.teamColor,
    required this.teamIcon,
  });

  @override
  State<TeamDashboardScreen> createState() => _TeamDashboardScreenState();
}

class _TeamDashboardScreenState extends State<TeamDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  String _userRole = 'Agent';
  String _userTeam = 'Unassigned';

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Open': return Colors.blue.shade500;
      case 'In Progress': return Colors.amber.shade600;
      case 'Resolved': return Colors.green.shade500;
      default: return Colors.blueGrey;
    }
  }

  void _showNotesModal(BuildContext context, TaskModel initialTask, TaskProvider taskProvider) {
    final commentController = TextEditingController();
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? 'Unknown User';
    final displayName = _userRole == 'Admin' ? 'Admin Command' : _userTeam;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.blueGrey.shade900, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
                  child: Row(
                    children: [
                      const Icon(Icons.forum, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Activity Log: ${initialTask.title}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      ),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context))
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('tasks').doc(initialTask.id).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final taskData = snapshot.data?.data() as Map<String, dynamic>?;
                      if (taskData == null) return const SizedBox.shrink();

                      final currentTask = TaskModel.fromMap(taskData, snapshot.data!.id);
                      final commentsList = currentTask.comments;

                      if (commentsList.isEmpty) {
                        return Center(
                          child: Text(
                            'No notes yet. Be the first to add an update!',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: commentsList.length,
                        itemBuilder: (context, index) {
                          final rawComment = commentsList[index];
                          if (rawComment == null || rawComment is! Map) {
                            return const SizedBox.shrink();
                          }

                          final comment = rawComment as Map<String, dynamic>;
                          final authorEmail = comment['authorEmail']?.toString() ?? 'Unknown';
                          final isMe = authorEmail == currentUserEmail;
                          final displayAuthor = comment['authorName']?.toString() ?? authorEmail.split('@')[0];

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
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, -2))]),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          decoration: InputDecoration(hintText: 'Add an update or note...', filled: true, fillColor: Theme.of(context).scaffoldBackgroundColor, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.blueAccent,
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: () {
                            if (commentController.text.trim().isNotEmpty) {
                              taskProvider.addComment(initialTask.id, commentController.text.trim(), currentUserEmail, displayName);
                              commentController.clear();
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

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.teamName} Center', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: widget.teamColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: BoxDecoration(
                color: widget.teamColor.withValues(alpha: 0.1),
                border: Border(bottom: BorderSide(color: widget.teamColor.withValues(alpha: 0.3), width: 2))
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: widget.teamColor.withValues(alpha: 0.2),
                  child: Icon(widget.teamIcon, size: 36, color: widget.teamColor),
                ),
                const SizedBox(height: 12),
                Text(
                  '${widget.teamName} Workspace',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: widget.teamColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'Showing operational incidents assigned to this unit.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                )
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: _firestoreService.getTeamTasks(widget.teamName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

                final teamTasks = snapshot.data ?? [];

                if (teamTasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 80, color: Colors.green.shade300),
                        const SizedBox(height: 16),
                        Text('Zero Active Incidents for ${widget.teamName}', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: teamTasks.length,
                  itemBuilder: (context, index) {
                    final task = teamTasks[index];
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
                            if (hasUnread) taskProvider.markAsRead(task.id, currentUserEmail);
                            _showNotesModal(context, task, taskProvider);
                          } else {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Access Denied: Only Admins and the assigned team can view this log.'), backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating));
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
                              Text(task.formattedDate, style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              Text(task.description, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 14)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.assignment_ind_outlined, size: 16, color: widget.teamColor),
                                      const SizedBox(width: 6),
                                      Text(task.assignee, style: TextStyle(color: widget.teamColor, fontSize: 13, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  if (canViewChat)
                                    Row(
                                      children: [
                                        Icon(Icons.forum_outlined, size: 16, color: hasUnread ? Colors.redAccent : Colors.blueGrey.shade300),
                                        if (hasUnread) ...[
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                                            child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
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
                                    icon: Icon(Icons.arrow_drop_down, color: _getStatusColor(task.status)),
                                    style: TextStyle(
                                      color: _getStatusColor(task.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    onChanged: (_userRole == 'Admin' || (_userRole == 'Agent' && task.assignee == _userTeam))
                                        ? (newStatus) {
                                      if (newStatus != null) taskProvider.changeTaskStatus(task.id, newStatus);
                                    } : null,
                                    items: ['Open', 'In Progress', 'Resolved'].map((status) {
                                      return DropdownMenuItem(
                                          value: status,
                                          child: Text(
                                              status,
                                              style: TextStyle(color: _getStatusColor(status), fontSize: 13, fontWeight: FontWeight.bold)
                                          )
                                      );
                                    }).toList(),
                                  ),
                                  if (_userRole == 'Admin')
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                      onPressed: () {
                                        taskProvider.removeTask(task.id);
                                      },
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}