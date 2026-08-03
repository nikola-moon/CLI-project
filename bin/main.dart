import 'package:todo_cli/repositories/task_repo.dart';
import 'package:todo_cli/services/cli_service.dart';

Future<void> main() => CliService(JsonTaskRepository('tasks.json')).run();
