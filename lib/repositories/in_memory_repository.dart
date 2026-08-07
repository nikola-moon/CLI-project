import '../models/task.dart';
import '../exception/app_exception.dart';
import 'repository.dart';

/// Reusable generic repository for demos, tests, or a non-persistent mode.
class InMemoryRepository<T> implements Repository<T> {
  final String Function(T item) _idOf;
  final Map<String, T> _items = {};

  InMemoryRepository(this._idOf);

  @override
  Future<void> add(T item) async => _items[_idOf(item)] = item;

  @override
  Future<void> delete(String id) async {
    if (_items.remove(id) == null) throw TaskException('Élément $id introuvable.');
  }

  @override
  Future<List<T>> getAll() async => List.unmodifiable(_items.values);

  @override
  Future<T?> getById(String id) async => _items[id];

  @override
  Future<void> update(T item) async {
    final id = _idOf(item);
    if (!_items.containsKey(id)) throw TaskException('Élément $id introuvable.');
    _items[id] = item;
  }
}

/// Task-specific adapter proving that [TaskService] is storage-agnostic.
class InMemoryTaskRepository extends InMemoryRepository<Task>
    implements TaskRepository {
  InMemoryTaskRepository() : super((task) => task.id);
}
