import 'dart:io';

import 'package:todo_cli/cli_helpers.dart';
import 'package:todo_cli/exception/app_exception.dart';
import 'package:todo_cli/models/priority.dart';
import 'package:todo_cli/repositories/repository.dart';
import 'package:todo_cli/services/task_service.dart';

/// Displays the terminal interface and delegates business rules to [TaskService].
class CliService {
  final TaskService _taskService;

  CliService(TaskRepository repository)
      : _taskService = TaskService(repository);

  Future<void> run() async {
    print('    GESTIONNAIRE DE TÂCHES CLI     ');
    var running = true;
    while (running) {
      _printMenu();
      try {
        switch (stdin.readLineSync()?.trim()) {
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
      } on TaskException catch (error) {
        print('Erreur : ${error.message}');
      } catch (error) {
        print('Erreur inattendue : $error');
      }
    }
  }

  void _printMenu() {
    print('\nMenu:');
    print('1. Ajouter une tâche');
    print('2. Lister les tâches');
    print('3. Marquer une tâche comme terminée');
    print('4. Supprimer une tâche');
    print('5. Quitter');
    stdout.write('Choix > ');
  }

  Future<void> _addTask() async {
    stdout.write('Titre de la tâche : ');
    final title = stdin.readLineSync() ?? '';
    stdout.write('Priorité (1: faible, 2: moyenne, 3: élevée) : ');
    final priority = _readPriority(stdin.readLineSync());
    var isUrgent = false;
    if (priority == Priority.elevee) {
      stdout.write('Marquer comme urgente ? (o/n) [n] : ');
      isUrgent = stdin.readLineSync()?.trim().toLowerCase() == 'o';
    }
    stdout.write('Date limite facultative (AAAA-MM-JJ) : ');
    final task = await _taskService.addTask(
      title: title,
      priority: priority,
      dueDate: parseDueDate(stdin.readLineSync()),
      isUrgent: isUrgent,
    );
    print('Tâche ajoutée avec succès (#${task.id}) !');
  }

  Future<void> _listTasks() async {
    print('\nTrier par :');
    print('1. Priorité (élevée vers faible)');
    print('2. Date limite (la plus proche en premier)');
    stdout.write('Choix : ');
    final tasks = await _taskService.listTasks(_readSort(stdin.readLineSync()));
    if (tasks.isEmpty) {
      print('Aucune tâche enregistrée.');
      return;
    }
    print('\n--- Liste des tâches ---');
    for (final task in tasks) {
      print(task);
    }
  }

  Future<void> _completeTask() async {
    stdout.write('ID de la tâche à terminer : ');
    final id = stdin.readLineSync()?.trim() ?? '';
    await _taskService.completeTask(id);
    print('Tâche #$id marquée comme terminée !');
  }

  Future<void> _deleteTask() async {
    stdout.write('ID de la tâche à supprimer : ');
    final id = stdin.readLineSync()?.trim() ?? '';
    await _taskService.deleteTask(id);
    print('Tâche #$id supprimée avec succès !');
  }

  Priority _readPriority(String? input) => switch (input?.trim()) {
        '1' => Priority.faible,
        '2' => Priority.moyenne,
        '3' => Priority.elevee,
        _ => throw TaskException('Priorité invalide. Choisissez 1, 2 ou 3.'),
      };

  TaskSort _readSort(String? input) => switch (input?.trim()) {
        '1' => TaskSort.priority,
        '2' => TaskSort.dueDate,
        _ => throw TaskException('Tri invalide. Choisissez 1 ou 2.'),
      };
}
