import 'package:test/test.dart';
import 'package:todo_cli/cli_helpers.dart';
import 'package:todo_cli/exception/app_exception.dart';
import 'package:todo_cli/models/priority.dart';

void main() {
  group('Priority.fromString', () {
    test('accepts numeric values, accents, and casing', () {
      expect(Priority.fromString('ÉLEVÉE'), Priority.elevee);
      expect(Priority.fromString(' moyenne '), Priority.moyenne);
      expect(Priority.fromString('1'), Priority.faible);
    });

    test('rejects unknown priorities with a validation exception', () {
      expect(
        () => Priority.fromString('inconnu'),
        throwsA(isA<TaskValidationException>()),
      );
    });
  });

  group('parseDueDate', () {
    test('accepts an empty optional deadline', () {
      expect(parseDueDate(''), isNull);
      expect(parseDueDate(null), isNull);
    });

    test('rejects malformed and impossible dates', () {
      expect(() => parseDueDate('date-invalide'), throwsA(isA<TaskException>()));
      expect(() => parseDueDate('2026-02-30'), throwsA(isA<TaskException>()));
      expect(() => parseDueDate('2026-08-15T10:00:00'), throwsA(isA<TaskException>()));
    });
  });
}
