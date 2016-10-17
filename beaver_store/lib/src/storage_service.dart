import 'dart:async';

import './beaver_store_base.dart';
import './model/project.dart';
import './model/trigger_result.dart';
import './storage_service/gcloud_storage_service.dart';
import './storage_service/local_machine_storage_service.dart';

abstract class StorageService {
  Future<Project> loadProject(String projectId);
  Future<String> saveProject(Project project);

  Future<int> getBuildNumber(String projectId);
  Future<bool> setBuildNumber(String projectId, int buildNumber);

  Future<TriggerResult> loadResult(String projectId, int buildNumber);
  Future<bool> saveResult(
      String projectId, int buildNumber, TriggerResult result);

  Future<Null> initialize(Map<String, String> config);
}

final Map<StorageServiceType, CreateStorageService> _map = {
  StorageServiceType.localMachine: () => new LocalMachineStorageService(),
  StorageServiceType.gCloud: () => new GCloudStorageService()
};

typedef StorageService CreateStorageService();

StorageService getStorageService(StorageServiceType type) {
  return _map[type]();
}
