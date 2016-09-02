import 'dart:async';

import './model/config.dart';
import './model/project.dart';
import './storage_service.dart';

enum StorageServiceType { localMachine, gCloud }

class ConfigStore {
  final StorageService _storageService;

  ConfigStore(StorageServiceType storageServiceType)
      : _storageService = getStorageService(storageServiceType);

  /// Return the id of Project.
  Future<String> setNewProject(String name) {
    return _storageService.saveProject(new Project(name));
  }

  Future<Project> getProject(String id) {
    return _storageService.loadProject(id);
  }

  Future<Null> setConfig(String id, String yaml) async {
    final config = new YamlConfig(yaml);
    final project = await _storageService.loadProject(id);
    if (project == null) {
      throw new Exception('No project for ${id}');
    }
    if (project.name != config['project_name']) {
      throw new Exception('Project name is not valid.');
    }
    project.config = config;
    project.configFile = await _storageService.saveConfigFile(project.id, yaml);
    await _storageService.saveProject(project);
  }
}
