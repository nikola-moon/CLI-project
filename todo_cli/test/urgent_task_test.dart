import 'package:test/test.dart';
import 'package:todo_cli/models/task.dart';

void main() {
  test('Une UrgentTask est sérialisée avec une priorité élevée', () {
    final task = UrgentTask(id: '7', title: 'Panne critique');

    final json = task.toJson();

    expect(json['type'], equals('URGENTE'));
    expect(json['priority'], equals('elevee'));
    expect(json['dueDate'], isNull);
  });
}
