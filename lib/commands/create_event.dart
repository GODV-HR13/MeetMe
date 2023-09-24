import 'dart:io';

import 'package:meetme/objects/fixed_calendar.dart';
import 'package:meetme/utils/mongo_api.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

final createEvent = ChatCommand(
  'create-event',
  'Creates an event.',
  id('create-event', (IChatContext context, String eventName) async {
    final embedBuilder = EmbedBuilder()
      ..title = eventName
      ..imageUrl = 'attachment://schedule.png';
    final message = await context.respond(ComponentMessageBuilder()
      ..embeds = [embedBuilder]
      ..componentRows = [
        ComponentRowBuilder()
          ..addComponent(ButtonBuilder(
              'Add availability', 'add-availability', ButtonStyle.primary))
      ]
      ..addFileAttachment(File('assets/schedule.png'), name: 'schedule.png'));

    // Add the event to database
    final result = await MongoApi.insertCalendar(
        FixedCalendar(eventName: eventName, messageId: message.id.toString()));
    if (!result.isSuccess) {
      await context.respond(
          MessageBuilder.content('Unable to create an event—sorry!'),
          level: ResponseLevel.private);
      return;
    }
  }),
);
