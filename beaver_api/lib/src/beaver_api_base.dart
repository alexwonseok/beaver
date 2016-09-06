import 'dart:async';

import 'package:beaver_config_store/beaver_config_store.dart';

Future<Map<String, Object>> apiHandler(
    String api, Map<String, Object> data) async {
  final ret = {};
  switch (api) {
    case 'register':
      final projectName = data['project'];
      final config = data['config'];
      final id = await _registerProject(projectName, config);
      ret['project'] = projectName;
      ret['id'] = id;
      break;
    case 'upload':
      // FIXME: Get file by a better way.
      final projectId = data['id'];
      final config = data['config'];
      await _uploadConfigFile(projectId, config);
      break;
    case 'result':
      final projectId = data['id'];
      final buildNumber = int.parse(data['build_number']);
      final format = data['format'];
      final result = await _getResult(projectId, buildNumber, format);
      ret['result'] = result;
      break;
    default:
      throw new Exception('Wrong API.');
  }
  return ret;
}

// FIXME: Don't use StorageServiceType.localMachine here.
final _configStore = new ConfigStore(StorageServiceType.localMachine);

/// Set new project. Returns the id of the registered project.
Future<String> _registerProject(String projectName, String config) async {
  final projectId = await _configStore.setNewProject(projectName);
  await _configStore.setConfig(projectId, config);
  return projectId;
}

Future<Null> _uploadConfigFile(String projectId, String config) =>
    _configStore.setConfig(projectId, config);

Future<String> _getResult(
    String projectId, int buildNumber, String format) async {
  final result = await _configStore.getResult(projectId, buildNumber);
  switch (format) {
    case 'html':
      // FIXME: implement.
      throw new Exception('Not implemented.');
    case 'text':
    default:
      return result.toString();
  }
}
