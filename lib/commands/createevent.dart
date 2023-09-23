import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';

final createEvent = ChatCommand(
  'createevent',
  'Creates an event.',
  id('ping', (IChatContext context) async {
    await context.respond(MessageBuilder.content('Pong!'));
  }),
);
