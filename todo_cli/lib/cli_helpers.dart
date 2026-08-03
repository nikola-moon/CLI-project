import 'package:todo_cli/exception/app_exception.dart';
import 'package:todo_cli/repositories/task_repo.dart';

/// Parses a user-entered due date. Empty values are accepted and treated as no deadline.
DateTime? parseDueDate(String? dateInput) {
  if (dateInput == null || dateInput.trim().isEmpty) {
    return null;
  }

  final value = dateInput.trim();
  final parsed = DateTime.tryParse(value);
  // DateTime.tryParse normalizes overflowing values (for example, February
  // 30th); comparing the canonical date keeps the CLI input strict.
  if (parsed == null ||
      !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ||
      parsed.toIso8601String().split('T').first != value) {
    throw TaskException('Format de date invalide (attendu : AAAA-MM-JJ).');
  }
  return parsed;
}

/// Updates an existing task as completed, with clear error messages for missing IDs.
Future<void> completeTask(String? id, {JsonTaskRepository? repository}) async {
  final targetRepo = repository ?? JsonTaskRepository('tasks.json');

  if (id == null || id.isEmpty) {
    throw TaskException('ID invalide.');
  }

  final task = await targetRepo.getById(id);
  if (task == null) {
    throw TaskException('Tâche #$id introuvable.');
  }

  task.isCompleted = true;
  await targetRepo.update(task);
}

/// Deletes an existing task and raises a specific exception when the ID is unknown.
Future<void> deleteTask(String? id, {JsonTaskRepository? repository}) async {
  final targetRepo = repository ?? JsonTaskRepository('tasks.json');

  if (id == null || id.isEmpty) {
    throw TaskException('ID invalide.');
  }

  await targetRepo.delete(id);
}
