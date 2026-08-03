import 'package:test/test.dart';
import 'package:todo_cli/models/priority.dart';
import 'package:todo_cli/models/task.dart';

void main() {
  group('Tests des tâches', () {
    test('Une UrgentTask doit toujours avoir une priorité élevée', () {
      final task = UrgentTask(id: '1', title: 'Bug critique');

      expect(task.priority, equals(Priority.elevee));
      expect(task.typeName, equals('URGENTE'));
    });

    test('Une StandardTask convertie en JSON contient les bonnes propriétés', () {
      final task = StandardTask(
        id: '2',
        title: 'Faire les courses',
        priority: Priority.moyenne,
      );

      final json = task.toJson();

      expect(json['id'], equals('2'));
      expect(json['title'], equals('Faire les courses'));
      expect(json['priority'], equals('moyenne'));
      expect(json['type'], equals('Standard'));
      expect(json['isCompleted'], equals(false));
    });

    test('Une tâche Standard conserve sa date limite dans le JSON', () {
      final dueDate = DateTime(2026, 8, 15);
      final task = StandardTask(
        id: '3',
        title: 'Rendez-vous',
        priority: Priority.faible,
        dueDate: dueDate,
      );

      final json = task.toJson();

      expect(json['dueDate'], equals(dueDate.toIso8601String()));
    });

    test('Une UrgentTask garde un typeName spécifique et une priorité élevée', () {
      final task = UrgentTask(id: '4', title: 'Incident majeur');

      expect(task.typeName, equals('URGENTE'));
      expect(task.priority, equals(Priority.elevee));
    });

    test('Une tâche marquée comme terminée affiche bien l\'état completé', () {
      final task = StandardTask(
        id: '5',
        title: 'Validation finale',
        priority: Priority.moyenne,
        isCompleted: true,
      );

      expect(task.isCompleted, isTrue);
      expect(task.toString(), contains('[X]'));
    });

  });
}
