import 'package:todo_cli/exception/app_exception.dart';
import 'package:todo_cli/models/priority.dart';
import 'package:todo_cli/models/task.dart';
import 'package:todo_cli/repositories/repository.dart';
import 'package:uuid/uuid.dart';

/// The available ordering modes for the task list.
enum TaskSort { priority, dueDate }

/// Contains the application's task-management rules independently of the UI.
class TaskService {
  final TaskRepository _repository;
  final Uuid _uuid;

  TaskService(this._repository, {Uuid uuid = const Uuid()}) : _uuid = uuid;

  Future<Task> addTask({
    required String title,
    required Priority priority,
    DateTime? dueDate,
    bool isUrgent = false,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty)
      throw TaskException('Le titre ne peut pas être vide.');
    if (isUrgent && priority != Priority.elevee) {
      throw TaskException('Une tâche urgente doit avoir une priorité élevée.');
    }
    final Task task = isUrgent
        ? UrgentTask(id: _uuid.v4(), title: cleanTitle, dueDate: dueDate)
        : StandardTask(
            id: _uuid.v4(),
            title: cleanTitle,
            priority: priority,
            dueDate: dueDate);
    await _repository.add(task);
    return task;
  }

  Future<List<Task>> listTasks(TaskSort sort) async {
    final tasks = await _repository.getAll();
    tasks.sort(switch (sort) {
      TaskSort.priority => (a, b) => b.priority.compareTo(a.priority),
      TaskSort.dueDate => _compareDueDates,
    });
    return tasks;
  }

  Future<void> completeTask(String id) async {
    final task = await _findTask(id);
    if (!task.isCompleted) {
      task.isCompleted = true;
      await _repository.update(task);
    }
  }

  Future<void> deleteTask(String id) async {
    _validateId(id);
    await _repository.delete(id);
  }

  /// Converts a high-priority standard task into an [UrgentTask].
  ///
  /// Urgency is a task type, independent from the priority used for sorting.
  Future<void> markAsUrgent(String id) async {
    final task = await _findTask(id);
    if (task is UrgentTask) return;
    if (task.priority != Priority.elevee) {
      throw TaskException(
        'Seules les tâches de priorité élevée peuvent devenir urgentes.',
      );
    }
    await _repository.update(UrgentTask(
      id: task.id,
      title: task.title,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
    ));
  }

  Future<Task> _findTask(String id) async {
    _validateId(id);
    final task = await _repository.getById(id);
    if (task == null) throw TaskException('Tâche #$id introuvable.');
    return task;
  }

  void _validateId(String id) {
    if (id.trim().isEmpty) throw TaskException('ID invalide.');
  }

  static int _compareDueDates(Task a, Task b) {
    if (a.dueDate == null && b.dueDate == null) return 0;
    if (a.dueDate == null) return 1;
    if (b.dueDate == null) return -1;
    return a.dueDate!.compareTo(b.dueDate!);
  }
}
