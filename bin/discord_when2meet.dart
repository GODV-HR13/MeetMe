import 'dart:io';

import 'package:discord_when2meet/commands/ping.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

void main() async {
  final client = NyxxFactory.createNyxxWebsocket(
    Platform.environment['TOKEN']!,
    GatewayIntents.allUnprivileged,
  );

  final commands = CommandsPlugin(
      prefix: (_) => '!',
      options: CommandsOptions(type: CommandType.slashOnly));

  client
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    // ..registerPlugin(IgnoreExceptions())
    ..registerPlugin(commands);

  // Register commands, listeners, services and setup any extra packages here
  commands.addCommand(ping);

  await client.connect();
}
