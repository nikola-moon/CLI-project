import 'dart:io';
import 'package:test/test.dart';
import 'package:todo_cli/exception/app_exception.dart';
import 'package:todo_cli/models/priority.dart';
import 'package:todo_cli/models/task.dart';
import 'package:todo_cli/repositories/task_repo.dart';

void main() {
  const testFilePath = 'test_tasks.json';
  late JsonTaskRepository repo;

  // S'exécute AVANT chaque test
  setUp(() {
    repo = JsonTaskRepository(testFilePath);
  });

  // S'exécute APRÈS chaque test pour nettoyer le fichier temporaire
  tearDown(() async {
    final file = File(testFilePath);
    if (await file.exists()) {
      await file.delete();
    }
  });

  group('JsonTaskRepository', () {
    test('Ajouter une tâche enregistre bien l\'élément', () async {
      final task = StandardTask(id: '100', title: 'Test Repo', priority: Priority.faible);

      await repo.add(task);
      final tasks = await repo.getAll();

      expect(tasks.length, equals(1));
      expect(tasks.first.title, equals('Test Repo'));
    });

    test('Récupérer toutes les tâches renvoie une liste vide si le fichier n\'existe pas', () async {
      final tasks = await repo.getAll();

      expect(tasks, isEmpty);
    });

    test('Récupérer une tâche par ID retourne bien la bonne tâche', () async {
      final task = StandardTask(id: '42', title: 'Task 42', priority: Priority.moyenne);
      await repo.add(task);

      final result = await repo.getById('42');

      expect(result, isNotNull);
      expect(result!.title, equals('Task 42'));
    });

    test('Mettre à jour une tâche modifie bien ses données', () async {
      final task = StandardTask(id: '200', title: 'Avant', priority: Priority.faible);
      await repo.add(task);

      final updated = StandardTask(id: '200', title: 'Après', priority: Priority.elevee, isCompleted: true);
      await repo.update(updated);

      final tasks = await repo.getAll();
      expect(tasks.single.title, equals('Après'));
      expect(tasks.single.priority, equals(Priority.elevee));
      expect(tasks.single.isCompleted, isTrue);
    });

    test('Supprimer un ID inexistant doit lever une TaskException', () async {
      expect(
        () async => await repo.delete('id_inexistant'),
        throwsA(isA<TaskException>()),
      );
    });
  });

  group('JsonTaskRepository edge cases', () {
    test('getById returns null for an unknown ID', () async {
      expect(await repo.getById('unknown'), isNull);
    });

    test('update throws when the task does not exist', () async {
      final missing = StandardTask(
        id: 'missing',
        title: 'Missing',
        priority: Priority.faible,
      );

      await expectLater(
        () => repo.update(missing),
        throwsA(isA<TaskException>()),
      );
    });

    test('getAll restores urgent tasks and their due date', () async {
      final dueDate = DateTime.utc(2026, 8, 15);
      await repo.add(UrgentTask(id: 'urgent', title: 'Incident', dueDate: dueDate));

      final task = (await repo.getAll()).single;
      expect(task, isA<UrgentTask>());
      expect(task.dueDate, equals(dueDate));
      expect(task.priority, equals(Priority.elevee));
    });
  });
}
