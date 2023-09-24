import 'dart:io';

import 'package:discord_when2meet/commands/create_event.dart';
import 'package:discord_when2meet/commands/hello.dart';
import 'package:discord_when2meet/commands/ping.dart';
import 'package:discord_when2meet/utils/image_utils.dart';
import 'package:discord_when2meet/utils/mongo_api.dart';
import 'package:discord_when2meet/utils/permanence_utils.dart';
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
      // DEBUG
      guild: Snowflake('1155188691011121232'));

  client
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    // ..registerPlugin(IgnoreExceptions())
    ..registerPlugin(commands);

  // Register commands, listeners, services and setup any extra packages here
  commands
    ..addCommand(ping)
    ..addCommand(hello)
    ..addCommand(createEvent);

  await client.connect();

  final interactions =
      IInteractions.create(WebsocketInteractionBackend(client));

  print((await interactions
      .fetchGuildCommands(Snowflake('1155188691011121232'))
      .toList()));

  interactions
    ..registerButtonHandler('add-availability', (event) async {
      /// Map of days to available times
      /// EG
      /// {"sunday": ["0-1", "5-6", "6-7"], "wednesday": ["6-7"] }
      Map<String, List<String>> dayToTimeAvailabilities = {};

      // Send the original message, or edit the latest loopContext, to be
      // the day picker message + submit button
      // final dayPickerId =
      dayPicker(dayToTimeAvailabilities, buttonEvent: event);

      print(event.interaction.message!.id.toString());
      // 1155314717770907720

      PermanenceUtils.storeSession(
          event.interaction.message!.id.toString(), dayToTimeAvailabilities);
    })
    ..syncOnReady();

  interactions
    ..registerMultiselectHandler('day-picker', (daySelectEvent) async {
      // "What the heck happened here..."
      // Basically this is how we find the original message ID. Button response
      // messages "reply" to the original, but it's considered a cross post.
      final id = daySelectEvent
          .interaction.message!.crossPostReference!.message!.id
          .toString();
      print(id); // 1155320435785863268
      final dayToTimeAvailabilities = PermanenceUtils.fetchSession(id);
      // final timePickerId =
      timePicker(dayToTimeAvailabilities!, event: daySelectEvent);
    })
    ..syncOnReady();

  interactions
    ..registerMultiselectHandler('time-picker', (timeSelectEvent) async {
      timeSelectEvent.acknowledge(hidden: true);
      // Append to the map:
      // EG:
      // dayToTimeAvailabilities["sunday"] = ["0-1", "5-6", "6-7"]
      final id = timeSelectEvent
          .interaction.message!.crossPostReference!.message!.id
          .toString();
      final dayToTimeAvailabilities = PermanenceUtils.fetchSession(id);

      final content = timeSelectEvent.interaction.message!.content;
      final firstMatch =
          RegExp(r'Choose your availability for (.*)').firstMatch(content);
      final selectedDay = firstMatch!.group(1);

      dayToTimeAvailabilities![selectedDay!] =
          timeSelectEvent.interaction.values;
      print(dayToTimeAvailabilities);
      
      final calendar = await MongoApi.fetchCalendar(id);
      if (calendar == null) {
        timeSelectEvent.respond(
            MessageBuilder.content('Unable to fetch calendar from DB. Sorry!'));
        return;
      }
      calendar.update(dayToTimeAvailabilities);
      await MongoApi.updateCalendar(calendar);
      ImageUtils.createCalendar(calendar, id);

      final message = await client.httpEndpoints
          .fetchMessage(timeSelectEvent.interaction.channel.id, Snowflake(id));
      await client.httpEndpoints.editMessage(
        timeSelectEvent.interaction.channel.id,
        Snowflake(id),
        MessageBuilder.fromMessage(message)
          ..embeds = [EmbedBuilder()..imageUrl = 'attachment://cal_$id.png']
          ..addFileAttachment(File('generated/cal_$id.png')),
      );
      
      dayPicker(dayToTimeAvailabilities, context: );
    })
    ..syncOnReady();
}
