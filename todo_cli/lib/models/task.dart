import 'priority.dart';

abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}
abstract class Task implements JsonSerializable {
  final String id;
  String title;
  Priority priority;
  DateTime? dueDate;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.dueDate,
    this.isCompleted = false,
  });

  String get typeName;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'priority': priority.name,
      'dueDate': dueDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'type': typeName,
    };
  }

  @override
  String toString() {
    final status = isCompleted ? '[X]' : '[ ]';
    // Store the date in a stable ISO format to avoid implicit timezone conversion in the CLI display.
    final dateStr = dueDate != null ? ' | Limite: ${dueDate!.toIso8601String().split('T').first}' : '';
    return '$status #$id - [$typeName] $title (Priorité: ${priority.name.toUpperCase()}$dateStr)';
  }
}

// Classes concrètes dérivees de Task
class StandardTask extends Task {
  StandardTask({
    required super.id,
    required super.title,
    required super.priority,
    super.dueDate,
    super.isCompleted,
  });

  @override
  String get typeName => 'Standard';
}

class UrgentTask extends Task {
  UrgentTask({
    required super.id,
    required super.title,
    super.dueDate,
    super.isCompleted,
  }) : super(priority: Priority.elevee);

  @override
  String get typeName => 'URGENTE';
}