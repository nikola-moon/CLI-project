import '../exception/app_exception.dart';

enum Priority implements Comparable<Priority> {
  faible(1),
  moyenne(2),
  elevee(3);

  final int value;
  const Priority(this.value);

  @override
  int compareTo(Priority other) => value.compareTo(other.value);

  /// Converts the supported CLI and JSON values to a priority.
  ///
  /// Invalid values are rejected so a manual JSON edit cannot silently change
  /// a task to low priority.
  static Priority fromString(String value) {
    switch (value.trim().toLowerCase()) {
      case 'elevee':
      case 'élevée':
      case '3':
        return Priority.elevee;
      case 'moyenne':
      case '2':
        return Priority.moyenne;
      case 'faible':
      case '1':
        return Priority.faible;
      default:
        throw TaskValidationException('Priorité invalide : "$value".');
    }
  }
}
