import 'dart:async';

import 'package:beaver_task/beaver_task.dart';
import 'package:command_wrapper/command_wrapper.dart';

@TaskClass('pub')
class PubTask extends Task {
  final List<String> args;
  final String processWorkingDir;

  PubTask(this.args, {String processWorkingDir})
      : this.processWorkingDir = processWorkingDir;

  @override
  Future<Null> execute(Context context) async {
    CommandResult result =
        await pub.run(args, processWorkingDir: processWorkingDir);
    for (final line in result.stderr) {
      context.logger.info(line);
    }
    for (final line in result.stdout) {
      context.logger.shout(line);
    }
  }
}

