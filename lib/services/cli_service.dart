import 'dart:io';

import 'package:todo_cli/cli_helpers.dart';
import 'package:todo_cli/exception/app_exception.dart';
import 'package:todo_cli/models/priority.dart';
import 'package:todo_cli/models/task.dart';
import 'package:todo_cli/repositories/repository.dart';
import 'package:uuid/uuid.dart';

/// Coordinates the interactive CLI while keeping persistence behind a contract.
class CliService {
  final TaskRepository _repository;

  CliService(this._repository);

  /// Starts the menu loop and converts expected application failures to messages.
  Future<void> run() async {
    print('    GESTIONNAIRE DE TACHES CLI     ');
    var running = true;

    while (running) {
      _printMenu();
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
            print('Option invalide, reessayez.');
        }
      } on TaskException catch (error) {
        print('Erreur : $error');
      } catch (error) {
        print('Erreur inattendue : $error');
      }
    }
  }

  void _printMenu() {
    print('\nMenu:');
    print('1. Ajouter une tache');
    print('2. Lister les taches');
    print('3. Marquer une tache comme terminee');
    print('4. Supprimer une tache');
    print('5. Quitter');
    stdout.write('Choix > ');
  }

  Future<void> _addTask() async {
    stdout.write('Titre de la tache : ');
    final title = stdin.readLineSync()?.trim();
    if (title == null || title.isEmpty) {
      throw TaskException('Le titre ne peut pas etre vide.');
    }

    stdout.write('Est-ce une tache urgente ? (o/n) [n] : ');
    final isUrgent = stdin.readLineSync()?.trim().toLowerCase() == 'o';
    var priority = Priority.faible;
    if (!isUrgent) {
      stdout.write('Priorite (1: Faible, 2: Moyenne, 3: Elevee) [1] : ');
      priority = Priority.fromString(stdin.readLineSync() ?? '1');
    }

    stdout.write('Date limite facultative (AAAA-MM-JJ) : ');
    final dueDate = parseDueDate(stdin.readLineSync());
    final id = const Uuid().v4();
    final Task task = isUrgent
        ? UrgentTask(id: id, title: title, dueDate: dueDate)
        : StandardTask(id: id, title: title, priority: priority, dueDate: dueDate);

    await _repository.add(task);
    print('Tache ajoutee avec succes (#$id) !');
  }

  Future<void> _listTasks() async {
    final tasks = await _repository.getAll();
    if (tasks.isEmpty) {
      print('Aucune tache enregistree.');
      return;
    }

    print('\nTrier par :\n1. Priorite\n2. Date limite');
    stdout.write('Choix [1] > ');
    if (stdin.readLineSync()?.trim() == '2') {
      tasks.sort((a, b) {
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    } else {
      tasks.sort((a, b) => b.priority.compareTo(a.priority));
    }

    print('\n--- Liste des Taches ---');
    for (final task in tasks) {
      print(task);
    }
  }

  Future<void> _completeTask() async {
    stdout.write('ID de la tache a terminer : ');
    final id = stdin.readLineSync()?.trim();
    await completeTask(id, repository: _repository);
    print('Tache #$id marquee comme terminee !');
  }

  Future<void> _deleteTask() async {
    stdout.write('ID de la tache a supprimer : ');
    final id = stdin.readLineSync()?.trim();
    await deleteTask(id, repository: _repository);
    print('Tache #$id supprimee avec succes !');
  }
}
