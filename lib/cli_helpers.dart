import 'package:todo_cli/exception/app_exception.dart';

/// Parses a user-entered due date. Empty values are accepted as no deadline.
DateTime? parseDueDate(String? dateInput) {
  if (dateInput == null || dateInput.trim().isEmpty) return null;

  final value = dateInput.trim();
  final parsed = DateTime.tryParse(value);
  // DateTime.tryParse normalizes overflowing values (for example, February 30).
  if (parsed == null ||
      !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value) ||
      parsed.toIso8601String().split('T').first != value) {
    throw TaskException('Format de date invalide (attendu : AAAA-MM-JJ).');
  }
  return parsed;
}
