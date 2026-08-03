import '../models/task.dart';

/// Generic contract for collections that can be persisted and queried by ID.
abstract interface class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> add(T item);
  Future<void> update(T item);
  Future<void> delete(String id);
}

/// Task-specific repository contract used by the application services.
///
/// Keeping this abstraction separate from its JSON implementation allows the
/// CLI to use another storage mechanism without changing its business logic.
abstract interface class TaskRepository implements Repository<Task> {}
