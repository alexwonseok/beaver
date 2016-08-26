import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

import './base.dart';
import './event_detector.dart';
import './task_instance_runner.dart';
import './trigger_config_store/trigger_config_memory_store.dart';
import './utils/enum.dart';

Logger _createLogger() {
  final logger = Logger.root;
  logger.level = Level.ALL;
  logger.clearListeners();
  logger.onRecord.listen((LogRecord rec) {
    print('${rec.level.name}: ${rec.time}: ${rec.message}');
  });
  return logger;
}

Context _createContext() {
  final logger = _createLogger();
  // FIXME: Don't hardcode.
  final triggerConfigStore = new TriggerConfigMemoryStore();
  return new Context(logger, triggerConfigStore);
}

Future<Null> _trigger_handler(Context context, String triggerId,
    Map<String, Object> data, HttpRequest request) async {
  final triggerConfig = await context.triggerConfigStore.load(triggerId);
  context.logger.info('TriggerConfig found: ${triggerConfig}');

  final eventDetector = getEventDetector(
      triggerConfig.sourceType, context, request.headers, data);
  final event = eventDetector.event;
  context.logger.info('Event detected: ${event}');

  final jobDescriptionLoader = new JobDescriptionLoader(context, triggerConfig);
  final jobDescription = await jobDescriptionLoader.load();
  context.logger.info('JobDescription loaded: ${jobDescription}');

  final jobRunner = new TaskInstanceRunner(context, event, jobDescription);
  final result = await jobRunner.run();
  context.logger.info('Job Running Result: ${result}');
}

Future<Null> trigger_handler(String triggerId, Map<String, Object> data,
    {HttpRequest request}) async {
  final context = _createContext();

  try {
    await _trigger_handler(context, triggerId, data, request);
  } catch (e) {
    context.logger.severe(e.toString());
    throw e;
  }
}
