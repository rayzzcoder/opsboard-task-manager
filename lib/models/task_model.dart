import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String severity;
  final String status;
  final DateTime? createdAt;
  final String userId;
  final String assignee;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    this.createdAt,
    required this.userId,
    required this.assignee,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      severity: map['severity'] ?? 'Low',
      status: map['status'] ?? 'Open',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      userId: map['userId'] ?? '',
      assignee: map['assignee'] ?? 'Unassigned',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'severity': severity,
      'status': status,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'userId': userId,
      'assignee': assignee,
    };
  }

  // --- UPDATED: Safe getter for the UI that includes Time! ---
  String get formattedDate {
    if (createdAt == null) return "Just now";

    // Get the hour and minute
    final hour = createdAt!.hour;
    final minute = createdAt!.minute.toString().padLeft(2, '0'); // Adds a leading zero (e.g., 12:05)
    final period = hour >= 12 ? 'PM' : 'AM';

    // Convert 24-hour time to standard 12-hour time
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return "${createdAt!.month}/${createdAt!.day}/${createdAt!.year}  •  $displayHour:$minute $period";
  }
}