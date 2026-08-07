import 'dart:io';

import 'package:test/test.dart';
import 'package:todo_cli/cli_helpers.dart';
import 'package:todo_cli/exception/app_exception.dart';
import 'package:todo_cli/models/priority.dart';
import 'package:todo_cli/models/task.dart';
import 'package:todo_cli/repositories/task_repo.dart';

void main() {
  group('Priority.fromString', () {
    test('accepte les valeurs avec casse et accents', () {
      expect(Priority.fromString('ÉLEVÉE'), equals(Priority.elevee));
      expect(Priority.fromString('MOYENNE'), equals(Priority.moyenne));
      expect(Priority.fromString('FAIBLE'), equals(Priority.faible));
    });

    test('retourne faibe pour une valeur inconnue', () {
      expect(Priority.fromString('inconnu'), equals(Priority.faible));
    });
  });

  group('parseDueDate', () {
    test('renvoie null pour une saisie vide', () {
      expect(parseDueDate(''), isNull);
      expect(parseDueDate(null), isNull);
    });

    test('levoie une TaskException pour une date invalide', () {
      expect(
        () => parseDueDate('date-invalide'),
        throwsA(isA<TaskException>()),
      );
    });
  });

  group('completeTask / deleteTask', () {
    const filePath = 'test_cli_helpers_tasks.json';
    late JsonTaskRepository repo;

    setUp(() {
      repo = JsonTaskRepository(filePath);
    });

    tearDown(() async {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    });

    test('completeTask marque une tâche existante comme terminée', () async {
      final task = StandardTask(
        id: 'task-1',
        title: 'Tâche à terminer',
        priority: Priority.moyenne,
      );
      await repo.add(task);

      await completeTask(task.id, repository: repo);
      final saved = await repo.getById(task.id);

      expect(saved, isNotNull);
      expect(saved!.isCompleted, isTrue);
    });

    test('completeTask lance une exception si la tâche n\'existe pas',
        () async {
      await expectLater(
        () => completeTask('inconnu', repository: repo),
        throwsA(isA<TaskException>()),
      );
    });

    test('deleteTask supprime une tâche existante', () async {
      final task = StandardTask(
        id: 'task-2',
        title: 'À supprimer',
        priority: Priority.faible,
      );
      await repo.add(task);

      await deleteTask(task.id, repository: repo);
      final remaining = await repo.getAll();

      expect(remaining, isEmpty);
    });

    test('deleteTask lance une exception si l\'ID n\'existe pas', () async {
      await expectLater(
        () => deleteTask('inconnu', repository: repo),
        throwsA(isA<TaskException>()),
      );
    });
  });
  group('additional validation paths', () {
    test('Priority.fromString trims numeric input and defaults unknown values',
        () {
      expect(Priority.fromString(' 3 '), equals(Priority.elevee));
      expect(Priority.fromString('2'), equals(Priority.moyenne));
      expect(Priority.fromString(''), equals(Priority.faible));
      expect(Priority.fromString('0'), equals(Priority.faible));
    });

    test('parseDueDate rejects impossible dates and date-times', () {
      expect(() => parseDueDate('2026-02-30'), throwsA(isA<TaskException>()));
      expect(() => parseDueDate('2026-08-15T10:00:00'),
          throwsA(isA<TaskException>()));
    });

    test('completeTask and deleteTask reject empty IDs', () async {
      const filePath = 'test_cli_helpers_validation.json';
      final repository = JsonTaskRepository(filePath);
      addTearDown(() async {
        final file = File(filePath);
        if (await file.exists()) await file.delete();
      });

      await expectLater(
        () => completeTask('', repository: repository),
        throwsA(isA<TaskException>()),
      );
      await expectLater(
        () => deleteTask(null, repository: repository),
        throwsA(isA<TaskException>()),
      );
    });
  });
}
