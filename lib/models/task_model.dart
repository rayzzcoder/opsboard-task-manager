import 'package:cloud_firestore/cloud_firestore.dart';

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String severity; // Low, Medium, High, Critical
  final String status;   // Open, In Progress, Resolved
  final DateTime? createdAt;
  final String userId;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.status,
    this.createdAt,
    required this.userId,
  });

  // Convert Firestore Document to a TaskModel object (Deserialization)
  factory TaskModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TaskModel(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      severity: map['severity'] ?? 'Low',
      status: map['status'] ?? 'Open',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      userId: map['userId'] ?? '',
    );
  }

  // Convert TaskModel object to a Map for Firestore (Serialization)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'severity': severity,
      'status': status,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'userId': userId,
    };
  }
}