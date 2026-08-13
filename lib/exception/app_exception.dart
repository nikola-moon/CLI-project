/// Base exception for expected errors in the task-management domain.
class TaskException implements Exception {
  final String message;

  TaskException(this.message);

  @override
  String toString() => 'TaskException: $message';
}

/// Raised when the user provides an invalid title, ID, priority, or date.
class TaskValidationException extends TaskException {
  TaskValidationException(super.message);
}

/// Raised when an operation targets a task that does not exist.
class TaskNotFoundException extends TaskException {
  TaskNotFoundException(String id) : super('Tâche #$id introuvable.');
}

/// Raised when the JSON storage cannot be read or written safely.
class TaskStorageException extends TaskException {
  TaskStorageException(super.message);
}
