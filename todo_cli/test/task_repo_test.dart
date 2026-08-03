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

    test('Supprimer un ID inexistant doit lever une TaskException', () async {
      expect(
        () async => await repo.delete('id_inexistant'),
        throwsA(isA<TaskException>()),
      );
    });
  });
}