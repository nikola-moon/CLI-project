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
  });
}