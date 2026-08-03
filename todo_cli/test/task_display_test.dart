import 'package:test/test.dart';
import 'package:todo_cli/models/priority.dart';
import 'package:todo_cli/models/task.dart';

void main() {
  test('L’affichage d’une date UTC ne la convertit pas en heure locale', () {
    final task = StandardTask(
      id: '6',
      title: 'Échéance UTC',
      priority: Priority.moyenne,
      dueDate: DateTime.utc(2026, 8, 15, 23),
    );

    expect(task.toString(), contains('Limite: 2026-08-15'));
  });
}
