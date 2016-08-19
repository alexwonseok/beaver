import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

import './base.dart';
import './event_detector/github_event_detector.dart';
import './job.dart';
import './trigger_config_store/trigger_config_memory_store.dart';
import './utils/enum_from_string.dart';

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

Future<Null> _trigger(Context context, String triggerId,
    Map<String, Object> data, HttpRequest request) async {
  final triggerConfig = await context.triggerConfigStore.load(triggerId);
  context.logger.info('TriggerConfig found: ${triggerConfig}');

  // FIXME: Get EventDetector using the reflection.
  var event;
  switch (triggerConfig.sourceType) {
    case SourceType.github:
      final eventDetector =
          new GithubEventDetector(context, request.headers, data);
      event = eventDetector.event;
      break;
    default:
      context.logger.severe(
          'Not supported source type. Plase check your trigger\'s source type.');
      throw new Exception('Not supported.');
  }
  context.logger.info('Event detected: ${event}');

  final jobDescriptionLoader = new JobDescriptionLoader(context, triggerConfig);
  final jobDescription = await jobDescriptionLoader.load();
  context.logger.info('JobDescription loaded: ${jobDescription}');

  final jobRunner = new JobRunner(context, event, jobDescription);
  final result = await jobRunner.run();
  context.logger.info('Job Running Result: ${result}');
}

Future<Null> trigger(String triggerId, Map<String, Object> data,
    {HttpRequest request}) async {
  final context = _createContext();

  try {
    await _trigger(context, triggerId, data, request);
  } catch (e) {
    context.logger.severe(e.toString());
    throw e;
  }
}

Future<String> setTrigger(Map<String, Object> data) async {
  final context = _createContext();

  return await setTriggerConfig(context,
      sourceTypeFromString(data['sourceType']), Uri.parse(data['sourceUrl']));
}
