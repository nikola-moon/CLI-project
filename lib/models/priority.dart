enum Priority implements Comparable<Priority> {
  faible(1),
  moyenne(2),
  elevee(3);

  final int value;
  const Priority(this.value);

  @override
  int compareTo(Priority other) => value.compareTo(other.value);

  /// Converts CLI and JSON priority values to their enum representation.
  ///
  /// Unknown values deliberately fall back to [Priority.faible], preserving
  /// compatibility with older or manually edited task files.
  static Priority fromString(String str) {
    switch (str.trim().toLowerCase()) {
      case 'elevee':
      case 'élevée':
      case '3':
        return Priority.elevee;
      case 'moyenne':
      case '2':
        return Priority.moyenne;
      case 'faible':
      case '1':
      default:
        return Priority.faible;
    }
  }
}
