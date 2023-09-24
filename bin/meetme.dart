import 'dart:io';

import 'package:meetme/commands/create_event.dart';
import 'package:meetme/commands/ping.dart';
import 'package:meetme/utils/image_utils.dart';
import 'package:meetme/utils/mongo_api.dart';
import 'package:meetme/utils/permanence_utils.dart';
import 'package:meetme/utils/picker_utils.dart';
import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

void main() async {
  await MongoApi.connectToDb();

  final client = NyxxFactory.createNyxxWebsocket(
    Platform.environment['TOKEN']!,
    GatewayIntents.allUnprivileged,
  );

  final commands = CommandsPlugin(
      prefix: (_) => '!',
      options: CommandsOptions(type: CommandType.slashOnly),
      guild: Snowflake('1155188691011121232'));

  client
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions())
    ..registerPlugin(commands);

  // Register commands, listeners, services and setup any extra packages here
  commands
    ..addCommand(ping)
    ..addCommand(createEvent);

  await client.connect();

  final interactions =
      IInteractions.create(WebsocketInteractionBackend(client));

  print((await interactions
      .fetchGuildCommands(Snowflake('1155188691011121232'))
      .toList()));

  interactions
    ..registerButtonHandler('add-availability', (event) async {
      final messageId = event.interaction.message!.id.toString();

      /// Map of days to available times
      /// EG
      /// {"sunday": ["0-1", "5-6", "6-7"], "wednesday": ["6-7"] }
      final userId = event.interaction.userAuthor!.id.toString();
      final dayToTimeAvailabilities =
          PermanenceUtils.fetchSession(messageId, userId) ?? {};

      // Send the original message, or edit the latest loopContext, to be
      // the day picker message + submit button
      // final dayPickerId =
      dayPicker(dayToTimeAvailabilities, buttonEvent: event);

      print(messageId);
      // 1155314717770907720

      PermanenceUtils.storeSession(dayToTimeAvailabilities,
          messageId: messageId, userId: userId);
    })
    ..registerMultiselectHandler('day-picker', (daySelectEvent) async {
      // "What the heck happened here..."
      // Basically this is how we find the original message ID. Button response
      // messages "reply" to the original, but it's considered a cross post.
      final messageId = daySelectEvent
          .interaction.message!.crossPostReference!.message!.id
          .toString();
      print(messageId); // 1155320435785863268
      final userId = daySelectEvent.interaction.userAuthor!.id.toString();
      final dayToTimeAvailabilities =
          PermanenceUtils.fetchSession(messageId, userId);
      // final timePickerId =
      timePicker(dayToTimeAvailabilities!, event: daySelectEvent);
    })
    ..registerMultiselectHandler('time-picker', (timeSelectEvent) async {
      // Append to the map:
      // EG:
      // dayToTimeAvailabilities["sunday"] = ["0-1", "5-6", "6-7"]
      final messageId = timeSelectEvent
          .interaction.message!.crossPostReference!.message!.id
          .toString();
      final userId = timeSelectEvent.interaction.userAuthor!.id.toString();
      final dayToTimeAvailabilities =
          PermanenceUtils.fetchSession(messageId, userId);

      final content = timeSelectEvent.interaction.message!.content;
      final firstMatch =
          RegExp(r'Choose your availability for (.*)').firstMatch(content);
      final selectedDay = firstMatch!.group(1);

      dayToTimeAvailabilities![selectedDay!] =
          timeSelectEvent.interaction.values;
      print(dayToTimeAvailabilities);

      final calendar = await MongoApi.fetchCalendar(messageId);
      if (calendar == null) {
        timeSelectEvent.respond(
            MessageBuilder.content('Unable to fetch calendar from DB. Sorry!'));
        return;
      }
      calendar.update(dayToTimeAvailabilities,
          timeSelectEvent.interaction.userAuthor!.id.toString());
      await MongoApi.updateCalendar(calendar);
      await ImageUtils.createCalendar(calendar, messageId);

      final message = await client.httpEndpoints.fetchMessage(
          timeSelectEvent.interaction.channel.id, Snowflake(messageId));
      await client.httpEndpoints.editMessage(
        timeSelectEvent.interaction.channel.id,
        Snowflake(messageId),
        MessageBuilder.fromMessage(message)
          ..embeds = [
            EmbedBuilder()..imageUrl = 'attachment://cal_$messageId.png'
          ]
          ..addFileAttachment(File('generated/cal_$messageId.png')),
      );

      dayPicker(dayToTimeAvailabilities, selectEvent: timeSelectEvent);
    })
    ..syncOnReady();
}
