import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:todo_cli/cli_helpers.dart';
import 'package:todo_cli/exception/app_exception.dart';
import 'package:todo_cli/models/priority.dart';
import 'package:todo_cli/models/task.dart';
import 'package:todo_cli/repositories/task_repo.dart';

final repo = JsonTaskRepository('tasks.json');

void main() async {
  print('    GESTIONNAIRE DE TÂCHES CLI     ');


  bool running = true;
  while (running) {
    print('\nMenu:');
    print('1. Ajouter une tâche');
    print('2. Lister les tâches');
    print('3. Marquer une tâche comme terminée');
    print('4. Supprimer une tâche');
    print('5. Quitter');
    stdout.write('Choix > ');

    final input = stdin.readLineSync()?.trim();

    try {
      switch (input) {
        case '1':
          await _addTask();
          break;
        case '2':
          await _listTasks();
          break;
        case '3':
          await _completeTask();
          break;
        case '4':
          await _deleteTask();
          break;
        case '5':
          running = false;
          print('Au revoir !');
          break;
        default:
          print('Option invalide, réessayez.');
      }
    } on TaskException catch (e) {
      print('⚠️ $e');
    } catch (e) {
      print('⚠️ Erreur inattendue : $e');
    }
  }
}

Future<void> _addTask() async {
  stdout.write('Titre de la tâche : ');
  final title = stdin.readLineSync()?.trim();
  if (title == null || title.isEmpty) {
    throw TaskException('Le titre ne peut pas être vide.');
  }

  stdout.write('Est-ce une tâche urgente ? (o/n) [n] : ');
  final isUrgent = stdin.readLineSync()?.trim().toLowerCase() == 'o';

  Priority priority = Priority.faible;
  if (!isUrgent) {
    stdout.write('Priorité (1: Faible, 2: Moyenne, 3: Élevée) [1] : ');
    final pInput = stdin.readLineSync()?.trim();
    priority = Priority.fromString(pInput ?? '1');
  }

  stdout.write('Date limite facultative (AAAA-MM-JJ) : ');
  final dateInput = stdin.readLineSync()?.trim();
  final dueDate = parseDueDate(dateInput);

  // UUID v4 avoids collisions from time-based identifiers and makes task IDs safer.
  final id = const Uuid().v4();
  final Task newTask = isUrgent
      ? UrgentTask(id: id, title: title, dueDate: dueDate)
      : StandardTask(id: id, title: title, priority: priority, dueDate: dueDate);

  await repo.add(newTask);
  print('✅ Tâche ajoutée avec succès (#$id) !');
}

Future<void> _listTasks() async {
  final tasks = await repo.getAll();
  if (tasks.isEmpty) {
    print('Aucune tâche enregistrée.');
    return;
  }

  print('\nTrier par :');
  print('1. Priorité');
  print('2. Date limite');
  stdout.write('Choix [1] > ');
  final sortOption = stdin.readLineSync()?.trim();

  if (sortOption == '2') {
    tasks.sort((a, b) {
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
  } else {
    tasks.sort((a, b) => b.priority.compareTo(a.priority));
  }

  print('\n--- Liste des Tâches ---');
  for (var task in tasks) {
    print(task);
  }
}

Future<void> _completeTask() async {
  stdout.write('ID de la tâche à terminer : ');
  final id = stdin.readLineSync()?.trim();
  if (id == null || id.isEmpty) throw TaskException('ID invalide.');

  await completeTask(id, repository: repo);
  print('✅ Tâche #$id marquée comme terminée !');
}

Future<void> _deleteTask() async {
  stdout.write('ID de la tâche à supprimer : ');
  final id = stdin.readLineSync()?.trim();

  await deleteTask(id, repository: repo);
  print('🗑️ Tâche #$id supprimée avec succès !');
}