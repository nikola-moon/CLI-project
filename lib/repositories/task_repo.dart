import 'dart:convert';
import 'dart:io';
import '../models/task.dart';
import '../models/priority.dart';
import '../exception/app_exception.dart';
import 'repository.dart';

/// JSON-file implementation of the task persistence contract.
class JsonTaskRepository implements TaskRepository {
  final File _file;

  JsonTaskRepository(String filePath) : _file = File(filePath);

  Future<List<Task>> _readFromFile() async {
    try {
      if (!await _file.exists()) {
        return [];
      }
      final content = await _file.readAsString();
      if (content.trim().isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(content);
      return jsonList.map((item) {
        final map = item as Map<String, dynamic>;
        final dueDateStr = map['dueDate'] as String?;
        final dueDate = dueDateStr != null ? DateTime.parse(dueDateStr) : null;
        final priority = Priority.fromString(map['priority'] ?? 'faible');

        if (map['type'] == 'URGENTE') {
          return UrgentTask(
            id: map['id'],
            title: map['title'],
            dueDate: dueDate,
            isCompleted: map['isCompleted'] ?? false,
          );
        } else {
          return StandardTask(
            id: map['id'],
            title: map['title'],
            priority: priority,
            dueDate: dueDate,
            isCompleted: map['isCompleted'] ?? false,
          );
        }
      }).toList();
    } catch (e) {
      throw TaskException('Échec de la lecture du fichier JSON : $e');
    }
  }

  Future<void> _saveToFile(List<Task> tasks) async {
    try {
      final jsonList = tasks.map((t) => t.toJson()).toList();
      final encoder = JsonEncoder.withIndent('  ');
      await _file.writeAsString(encoder.convert(jsonList));
    } catch (e) {
      throw TaskException('Échec de la sauvegarde dans le fichier : $e');
    }
  }

  @override
  Future<List<Task>> getAll() async => await _readFromFile();

  @override
  Future<Task?> getById(String id) async {
    final tasks = await _readFromFile();
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> add(Task item) async {
    final tasks = await _readFromFile();
    tasks.add(item);
    await _saveToFile(tasks);
  }

  @override
  Future<void> update(Task item) async {
    final tasks = await _readFromFile();
    final index = tasks.indexWhere((t) => t.id == item.id);
    if (index == -1) {
      throw TaskException('Tâche introuvable avec l\'ID : ${item.id}');
    }
    tasks[index] = item;
    await _saveToFile(tasks);
  }

  @override
  Future<void> delete(String id) async {
    final tasks = await _readFromFile();
    final initialLength = tasks.length;
    tasks.removeWhere((t) => t.id == id);
    if (tasks.length == initialLength) {
      throw TaskException('Impossible de supprimer : ID $id inexistant.');
    }
    await _saveToFile(tasks);
  }
}
