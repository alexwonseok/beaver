import 'dart:async';
import 'dart:io';

import 'package:beaver_trigger_handler/beaver_trigger_handler.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

import '../model/project.dart';
import '../storage_service.dart';

final Map<String, Project> _map = {};

class LocalMachineStorageService implements StorageService {
  const LocalMachineStorageService();

  @override
  Future<Project> loadProject(String projectId) async {
    return _map[projectId];
  }

  @override
  Future<String> saveProject(Project project) async {
    if (project.id == null) {
      final id = new Uuid().v4();
      project.id = id;
    }
    _map[project.id] = project;
    return project.id;
  }

  @override
  Future<String> loadConfigFile(String projectId) async {
    final project = await loadProject(projectId);
    final file = new File(project.configFile.path);
    final config = await file.readAsString();
    return config;
  }

  @override
  Future<Uri> saveConfigFile(String projectId, String config) async {
    final dir = await _getProjectDir(projectId);
    final filePath = path.join(dir.path, 'beaver.yaml');
    final file = await new File(filePath).create();
    await file.writeAsString(config);
    return Uri.parse(filePath);
  }

  @override
  Future<bool> saveResult(
      String projectId, int buildNumber, TaskInstanceResult result) async {
    final dir = await _getProjectDir(projectId);
    final filePath = _getResultFilePath(dir, buildNumber);
    final file = await new File(filePath).create(recursive: true);
    await file.writeAsString(result.toString());
    return true;
  }

  @override
  Future<String> getResult(String projectId, int buildNumber) async {
    final dir = await _getProjectDir(projectId);
    final filePath = _getResultFilePath(dir, buildNumber);
    return await new File(filePath).readAsString();
  }

  String _getResultFilePath(Directory base, int buildNumber) {
    return path.join(base.path, 'result', buildNumber.toString());
  }

  Future<Directory> _getProjectDir(String projectId) async {
    final dirPath = path.join(Directory.systemTemp.path, projectId);
    return await new Directory(dirPath).create(recursive: true);
  }
}
