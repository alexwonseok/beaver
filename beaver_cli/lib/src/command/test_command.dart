import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:ini/ini.dart';

class TestCommand extends Command {
  @override
  String get description => 'Test the trigger.';

  @override
  String get name => 'test';

  TestCommand(Config config) : super() {
    address = config.get('server', 'address');
    port = int.parse(config.get('server', 'port'));

    argParser.addOption('project-id', abbr: 'p', callback: (value) {
      if (value == null) {
        print('project-id is required.');
        exit(0);
      }
    }, help: 'Project ID to be tested.');

    argParser.addOption('trigger-type',
        abbr: 't', defaultsTo: 'github', help: 'Trigger\'s type to be tested.');

    argParser.addOption('event',
        abbr: 'e', defaultsTo: 'create', help: 'Event will be sent.');

    argParser.addOption('data', abbr: 'd', callback: (value) {
      if (value == null) {
        print('data is required.');
        exit(0);
      }
    }, help: 'Data will be sent as POST data.');

    argParser.addOption('data-format',
        abbr: 'f', defaultsTo: 'json', help: 'Data\'s format.');
  }

  static const _triggerPath = const {'github': '/github'};

  String get api => _triggerPath[argResults['trigger-type']];
  String address;
  int port;

  @override
  Future<Null> run() async {
    final httpClient = new HttpClient();
    final path = api + '/' + argResults['project-id'];
    final request = await httpClient.open('POST', address, port, path);
    request.headers
        .add('Content-Type', 'application/' + argResults['data-format']);
    if (argResults['trigger-type'] == 'github') {
      request.headers.add('X-Github-Event', argResults['event']);
    }
    request.write(argResults['data']);
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    print(responseBody);
  }
}
