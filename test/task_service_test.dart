import 'dart:io';

import 'package:test/test.dart';
import 'package:todo_cli/exception/app_exception.dart';
import 'package:todo_cli/models/priority.dart';
import 'package:todo_cli/models/task.dart';
import 'package:todo_cli/repositories/task_repo.dart';
import 'package:todo_cli/repositories/in_memory_repository.dart';
import 'package:todo_cli/services/task_service.dart';

void main() {
  const filePath = 'test_task_service_tasks.json';
  late TaskService service;

  setUp(() => service = TaskService(JsonTaskRepository(filePath)));
  tearDown(() async {
    final file = File(filePath);
    if (await file.exists()) await file.delete();
  });

  test('creates a task with the selected priority and optional deadline',
      () async {
    final dueDate = DateTime(2026, 9, 1);
    final task = await service.addTask(
      title: 'Préparer la démo',
      priority: Priority.moyenne,
      dueDate: dueDate,
    );

    expect(task, isA<StandardTask>());
    expect(task.priority, Priority.moyenne);
    expect(task.dueDate, dueDate);
  });

  test('sorts independently by priority and deadline', () async {
    await service.addTask(
        title: 'Faible',
        priority: Priority.faible,
        dueDate: DateTime(2026, 10, 1));
    await service.addTask(
        title: 'Élevée',
        priority: Priority.elevee,
        dueDate: DateTime(2026, 12, 1));
    await service.addTask(
        title: 'Moyenne',
        priority: Priority.moyenne,
        dueDate: DateTime(2026, 8, 1));

    expect((await service.listTasks(TaskSort.priority)).first.title, 'Élevée');
    expect((await service.listTasks(TaskSort.dueDate)).first.title, 'Moyenne');
  });

  test('rejects an urgent task that is not high priority', () async {
    await expectLater(
      () => service.addTask(
          title: 'Incident', priority: Priority.faible, isUrgent: true),
      throwsA(isA<TaskException>()),
    );
  });

  test('marks an existing high-priority task as an UrgentTask', () async {
    final task = await service.addTask(title: 'Incident', priority: Priority.elevee);

    await service.markAsUrgent(task.id);
    final stored = (await service.listTasks(TaskSort.priority)).single;

    expect(stored, isA<UrgentTask>());
    expect(stored.toString(), contains('🚨'));
  });

  test('works with the interchangeable in-memory repository', () async {
    final memoryService = TaskService(InMemoryTaskRepository());
    final task = await memoryService.addTask(title: 'Démo', priority: Priority.faible);

    await memoryService.completeTask(task.id);

    expect((await memoryService.listTasks(TaskSort.priority)).single.isCompleted, isTrue);
  });
}
