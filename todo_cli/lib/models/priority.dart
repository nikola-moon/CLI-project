enum Priority implements Comparable<Priority> {
  faible(1),
  moyenne(2),
  elevee(3);

  final int value;
  const Priority(this.value);

  @override
  int compareTo(Priority other) => value.compareTo(other.value);

  static Priority fromString(String str) {
    switch (str.toLowerCase()) {
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