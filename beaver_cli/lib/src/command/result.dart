import 'dart:async';
import 'dart:convert';
import 'dart:io';

import './http.dart';

class ResultCommand extends HttpCommand {
  @override
  String get description => 'Show the result of the build.';

  @override
  String get name => 'result';

  ResultCommand() : super() {
    argParser.addOption('project-id', abbr: 'p', callback: (value) {
      if (value == null) {
        print('project-id is required.');
        exitWithHelpMessage();
      }
    }, help: 'Project ID.');

    argParser.addOption('build-number', abbr: 'b', callback: (value) {
      if (value == null) {
        print('build-number is required.');
        exitWithHelpMessage();
      }
    }, help: 'Build number to be got.');

    argParser.addOption('format',
        abbr: 'f',
        defaultsTo: 'text',
        allowed: ['text', 'html'],
        help: 'The result format.');

    argParser.addOption('count', abbr: 'n', defaultsTo: '1', callback: (value) {
      if (int.parse(value, onError: (source) => -1) <= 0) {
        print('The option -n requires a positive integer.');
        exitWithHelpMessage();
      }
    }, help: 'Number of results to output.');
  }

  @override
  String get api => '/api/result';

  @override
  Future<Null> run() async {
    final url = getServerUrl();
    print(url.toString() + ' will be requested.');

    final data = JSON.encode({
      'id': argResults['project-id'],
      'build_number': argResults['build-number'],
      'format': argResults['format'],
      'count': argResults['count']
    });

    final httpClient = new HttpClient();
    final request = await httpClient.openUrl('POST', url);
    request.headers.add('Content-Type', 'application/json');
    request.write(data);
    final response = await request.close();
    final responseBody = await response.transform(UTF8.decoder).join();
    httpClient.close();

    final jsonBody = JSON.decode(responseBody);
    if (jsonBody['status'] == 'success') {
      print(jsonBody['result'].toString());
    } else {
      print(responseBody);
    }
  }
}
