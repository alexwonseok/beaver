import 'dart:async';

import 'package:beaver_config_store/beaver_config_store.dart';
/// For [Task] registration.
import 'package:beaver_task/beaver_task.dart' as beaver_task;
import 'package:beaver_task/beaver_task_runner.dart';

import './base.dart';

class TaskInstanceRunner {
  final Context _context;
  final Project _project;
  final Map _taskInstance;

  TaskInstanceRunner(this._context, this._project, this._taskInstance);

  Future<TaskInstanceRunResult> run() async {
    _context.logger.fine('TaskInstanceRunner started.');

    final result = await runBeaver(
        _taskInstance['name'], _taskInstance['args'], _project.config);

    return new TaskInstanceRunResult(
        TaskInstanceStatus.success, _project, result);
  }
}

enum TaskInstanceStatus { success, failure }

class TaskInstanceRunResult {
  TaskInstanceStatus status;
  Project project;
  TaskRunResult taskRunResult;

  TaskInstanceRunResult(this.status, this.project, this.taskRunResult);

  @override
  String toString() {
    var taskInstanceStatus = 'success';
    if (status != TaskInstanceStatus.success) {
      taskInstanceStatus = 'failure';
    }

    var taskStatus = 'success';
    if (taskRunResult.status != TaskStatus.Success) {
      taskStatus = 'failure';
    }

    final buffer = new StringBuffer();
    buffer
      ..writeln('Project: ${project.name}')
      ..writeln('Build Number: ${project.buildNumber}')
      ..writeln('TaskInstanceResult -------')
      ..writeln('status: ${taskInstanceStatus}')
      ..writeln('project: ${project.toString()}')
      ..writeln('TaskResult: ---')
      ..writeln('status: ${taskStatus}')
      ..writeln('config: ${taskRunResult.config.toString()}')
      ..writeln('log: ${taskRunResult.log}');
    return buffer.toString();
  }
}
