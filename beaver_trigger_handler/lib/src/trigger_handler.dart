import 'dart:async';

import 'package:beaver_store/beaver_store.dart';
import 'package:logging/logging.dart';
import 'package:yaml/yaml.dart';

import './base.dart';
import './task_instance_runner.dart';
import './trigger_parser.dart';

BeaverStore _beaverStore;

void initTriggerHandler(BeaverStore beaverStore) {
  _beaverStore = beaverStore;
}

Logger _createLogger() {
  final logger = Logger.root;
  logger.level = Level.ALL;
  logger.clearListeners();
  logger.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  return logger;
}

Future<Context> _createContext() async {
  final logger = _createLogger();
  final beaverStore = _beaverStore;
  return new Context(logger, beaverStore);
}

List _getTriggerConfigs(Project project) {
  return (project.config['triggers'] as YamlList).toList(growable: false);
}

Map _findTriggerConfig(List<Map> triggerConfigs, ParsedTrigger parsedTrigger) {
  return triggerConfigs.firstWhere((triggerConfig) {
    if (triggerConfig['url'] != parsedTrigger.url) {
      return false;
    }
    for (final eventStr in triggerConfig['events']) {
      final event = new Event.fromString(eventStr);
      return event.isMatch(parsedTrigger.event);
    }
  }, orElse: () => throw new Exception('No config for ${parsedTrigger}'));
}

Future<int> _triggerHandler(
    Context context, Trigger trigger, String projectId) async {
  context.logger.info('TriggerHandler is started.');
  final project = await context.beaverStore.getProject(projectId);
  if (project == null) {
    throw new Exception('No project for id \'${projectId}\'.');
  }
  context.logger.info('Project: ${project}');
  final buildNumber =
      await context.beaverStore.getAndUpdateBuildNumber(projectId);

  final parsedTrigger = parseTrigger(context, trigger);
  context.logger.info('Trigger: ${parsedTrigger}');

  final triggerConfig =
      _getTriggerConfigs(project) as List<Map<String, Object>>;
  final taskInstance =
      _findTriggerConfig(triggerConfig, parsedTrigger) as Map<String, Object>;
  context.logger.info('TriggerConfig: ${triggerConfig}');

  final taskInstanceRunner = new TaskInstanceRunner(
      context, project.config, parsedTrigger, taskInstance);
  final result = await taskInstanceRunner.run();
  context.logger.info('TaskInstanceRunResult: ${result}');

  await context.beaverStore.saveResult(
      projectId, buildNumber, trigger, parsedTrigger, taskInstance, result);
  context.logger.info('Result is saved.');
  return buildNumber;
}

Future<int> triggerHandler(Trigger trigger, String projectId) async {
  final context = await _createContext();

  try {
    return await _triggerHandler(context, trigger, projectId);
  } catch (e) {
    context.logger.severe(e.toString());
    throw e;
  }
}
