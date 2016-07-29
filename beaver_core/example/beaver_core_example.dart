// Copyright (c) 2016, Fluidic Inc. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:beaver_core/beaver_core.dart';
import 'package:beaver_dart_task/beaver_dart_task.dart';

import 'package:quiver_strings/strings.dart' as strings;

final task = (Context context) async {
  List<Task> tasks = [
    new InstallDartSdkTask(withContentShell: true, withDartium: true),
    new GitTask(['clone', 'git@github.com:fluidic/symbol.git']),
    new PubTask(['get'], processWorkingDir: 'symbol'),
    new PubTask(['run', 'test'], processWorkingDir: 'symbol')
  ];
  return Future.forEach(tasks, (task) => task.execute(context));
};

main() async {
  Configuration conf = new YamlConfiguration.fromFile('beaver.yaml');
  final jsonCredentialsPath =
      conf['gcloud']['service_account_credentials_path'];
  final projectName = conf['gcloud']['project_name'];
  final jsonCredentials = await new File(jsonCredentialsPath).readAsString();
  final parts = [new GCloudContextPart(jsonCredentials, projectName)];
  final logger = new ConsoleLogger();
  Context context =
      await DefaultContext.create(conf, parts: parts, logger: logger);
  TaskRunner runner = new TaskRunner(context, task);
  TaskRunResult result = await runner.run();
  JsonReporter reporter = new JsonReporter(result);
  print(reporter.toJson());
}
