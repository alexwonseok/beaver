import 'dart:async';

import 'package:uuid/uuid.dart';

import '../model/project.dart';
import '../model/trigger_result.dart';
import '../storage_service.dart';

final Map<String, Project> _projectMap = {};
final Map<String, TriggerResult> _resultMap = {};
final Map<String, int> _buildNumberMap = {};

class LocalMachineStorageService implements StorageService {
  const LocalMachineStorageService();

  @override
  Future<Project> loadProject(String projectId) async {
    return _projectMap[projectId];
  }

  @override
  Future<String> saveProject(Project project) async {
    if (project.id == null) {
      final id = new Uuid().v4();
      project.id = id;
    }
    _projectMap[project.id] = project;
    return project.id;
  }

  @override
  Future<bool> saveResult(
      String projectId, int buildNumber, TriggerResult result) async {
    final key = projectId + '__' + buildNumber.toString();
    _resultMap[key] = result;
    return true;
  }

  @override
  Future<TriggerResult> loadResult(String projectId, int buildNumber) async {
    final key = projectId + '__' + buildNumber.toString();
    return _resultMap[key];
  }

  @override
  Future<int> getBuildNumber(String projectId) async {
    if (!_buildNumberMap.containsKey(projectId)) {
      _buildNumberMap[projectId] = 0;
    }
    return _buildNumberMap[projectId];
  }

  @override
  Future<bool> setBuildNumber(String projectId, int buildNumber) async {
    _buildNumberMap[projectId] = buildNumber;
    return true;
  }

  @override
  Future<Null> initialize(Map<String, String> config) => null;
}
