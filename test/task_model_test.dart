import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/models/task_model.dart'; // Ensure this path matches your project

void main() {
  group('TaskModel Unit Tests', () {
    test('fromMap correctly parses valid data', () {
      final timestamp = Timestamp.fromDate(DateTime(2026, 8, 20, 14, 30)); // 2:30 PM
      final map = {
        'title': 'Server Outage',
        'description': 'Main server is down',
        'severity': 'Critical',
        'status': 'In Progress',
        'createdAt': timestamp,
        'userId': 'admin_123',
        'assignee': 'Alpha Team',
        'comments': ['Working on it'],
        'readBy': ['admin_123'],
      };

      final task = TaskModel.fromMap(map, 'doc_123');

      expect(task.id, 'doc_123');
      expect(task.title, 'Server Outage');
      expect(task.severity, 'Critical');
      expect(task.createdAt, DateTime(2026, 8, 20, 14, 30));
      expect(task.assignee, 'Alpha Team');
      expect(task.comments.length, 1);
    });

    test('fromMap handles missing fields with your exact defaults', () {
      final map = <String, dynamic>{};
      final task = TaskModel.fromMap(map, 'fallback_doc');

      expect(task.id, 'fallback_doc');
      expect(task.title, '');
      expect(task.description, '');
      expect(task.severity, 'Low');
      expect(task.status, 'Open');
      expect(task.createdAt, isNull);
      expect(task.userId, '');
      expect(task.assignee, 'Unassigned');
      expect(task.comments, isEmpty);
      expect(task.readBy, isEmpty);
    });

    test('formattedDate returns correct AM/PM and null fallbacks', () {
      // Test PM Logic
      final pmTask = TaskModel(
        id: '1', title: '', description: '', severity: '', status: '', userId: '', assignee: '',
        createdAt: DateTime(2026, 8, 20, 15, 5), // 3:05 PM
      );
      expect(pmTask.formattedDate, '8/20/2026  •  3:05 PM');

      // Test Midnight/AM Logic
      final amTask = TaskModel(
        id: '2', title: '', description: '', severity: '', status: '', userId: '', assignee: '',
        createdAt: DateTime(2026, 8, 20, 0, 15), // 12:15 AM
      );
      expect(amTask.formattedDate, '8/20/2026  •  12:15 AM');

      // Test Null Logic
      final nullTask = TaskModel(
        id: '3', title: '', description: '', severity: '', status: '', userId: '', assignee: '',
        createdAt: null,
      );
      expect(nullTask.formattedDate, 'Just now');
    });
  });
}