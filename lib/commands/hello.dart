import 'package:nyxx/nyxx.dart';
import 'package:nyxx_commands/nyxx_commands.dart';
import 'package:nyxx_commands/src/context/component_context.dart';
import 'package:nyxx_interactions/nyxx_interactions.dart';

final hello = ChatCommand(
  'hello',
  'test',
  id('hello', (InteractionChatContext context) async {
    /// Map of days to available times
    /// EG
    /// {"sunday": ["0-1", "5-6", "6-7"], "wednesday": ["6-7"] }
    Map<String, List<String>> dayToTimeAvailabilities = {};

    bool submitted = false;
    bool firstResponse = true;

    IInteractiveContext loopContext = context;

    while (!submitted) {
      // Send the original message, or edit the latest loopContext, to be
      // the day picker message + submit button
      final dayPickerId =
          await dayPicker(loopContext, dayToTimeAvailabilities, context, firstResponse);
      firstResponse = false;

      // after day multiselect is run, select the time
      MultiselectComponentContext<String> selectedDayContext =
          await context.awaitSelection(dayPickerId);

      final timePickerId = await timePicker(selectedDayContext,
          dayToTimeAvailabilities, selectedDayContext.selected, context);

      // Wait for user to select availability times.
      MultiselectComponentContext<List<String>> selectedTimeContext =
          await selectedDayContext.awaitMultiSelection(timePickerId);

      // Append to the map:
      // EG:
      // dayToTimeAvailabilities["sunday"] = ["0-1", "5-6", "6-7"]
      dayToTimeAvailabilities[selectedDayContext.selected] =
          selectedTimeContext.selected;
      print(dayToTimeAvailabilities);

      loopContext = selectedTimeContext;
    }
  }),
);

Future<ComponentId> dayPicker(
  IInteractiveContext context,
  Map<String, List<String>> dayToTimeAvailabilities,
  InteractionChatContext originalContext,
  bool firstResponse,
) async {
  final embedBuilder = EmbedBuilder()..title = '[EVENT NAME]';

  var id = ComponentId.generate();

  Map<String, String> multiselectDays = {
    'Sunday': 'sunday',
    'Monday': 'monday',
    'Tuesday': 'tuesday',
    'Wednesday': 'wednesday',
    'Thursday': 'thursday',
    'Friday': 'friday',
    'Saturday': 'saturday',
  };

  final newMSDays = {};
  // Determines whether a day's availability has been picked and assigns a check to it
  for (var entry in multiselectDays.entries) {
    if (dayToTimeAvailabilities.containsKey(entry.value)) {
      newMSDays['✅ ${entry.key}'] = entry.value;
    } else {
      newMSDays[entry.key] = entry.value;
    }
  }

  final multiselectBuilder = MultiselectBuilder(
    id.toString(),
    // Map newMSDays into MultiselectOptionBuilders
    newMSDays.entries.map((e) => MultiselectOptionBuilder(e.key, e.value)),
  );

  // sends message with embed and components
  final messageBuilder = ComponentMessageBuilder()
    ..embeds = [embedBuilder]
    ..componentRows = [
      // a multiselect component
      ComponentRowBuilder()..addComponent(multiselectBuilder),

      // a button component which submits availability
      ComponentRowBuilder()
        ..addComponent(ButtonBuilder(
            'Submit Availability', 'submit_availability', ButtonStyle.primary)),
    ];

  // Send the original message if it doesn't yet exist—otherwise edit the
  // ephemeral one.
  if (firstResponse) {
    await originalContext.respond(messageBuilder,
        level: ResponseLevel(
            hideInteraction: true,
            isDm: false,
            mention: false,
            preserveComponentMessages: false));
  } else {
    await originalContext.interactionEvent.editOriginalResponse(
      messageBuilder,
    );
  }

  return id;
}

Future<ComponentId> timePicker(
  MultiselectComponentContext<String> selectedDayContext,
  Map<String, List<String>> dayToTimeAvailabilities,
  String dayId,
  InteractionChatContext originalContext,
) async {
  final timePickerId = ComponentId.generate();

  Map<String, String> multiselectTimes = {
    'Midnight to 1 AM': '0-1',
    '1 AM to 2 AM': '1-2',
    '2 AM to 3 AM': '2-3',
    '3 AM to 4 AM': '3-4',
    '4 AM to 5 AM': '4-5',
    '5 AM to 6 AM': '5-6',
    '6 AM to 7 AM': '6-7',
    '7 AM to 8 AM': '7-8',
    '8 AM to 9 AM': '8-9',
    '9 AM to 10 AM': '9-10',
    '10 AM to 11 AM': '10-11',
    '11 AM to Noon': '11-12',
    'Noon to 1 PM': '12-13',
    '1 PM to 2 PM': '13-14',
    '2 PM to 3 PM': '14-15',
    '3 PM to 4 PM': '15-16',
    '4 PM to 5 PM': '16-17',
    '5 PM to 6 PM': '17-18',
    '6 PM to 7 PM': '18-19',
    '7 PM to 8 PM': '19-20',
    '8 PM to 9 PM': '20-21',
    '9 PM to 10 PM': '21-22',
    '10 PM to 11 PM': '22-23',
    '11 PM to Midnight': '23-0',
  };

  List<MultiselectOptionBuilder> newMSTimes = [];
  // Determines whether a day's availability has been picked and assigns a check to it
  for (var entry in multiselectTimes.entries) {
    // If dayToTimeAvailabilities[dayId] exists and has the current looped time
    // in it, then preselect it.
    final shouldPreselect = dayToTimeAvailabilities[dayId] != null &&
        dayToTimeAvailabilities[dayId]!.contains(entry.value);
    newMSTimes
        .add(MultiselectOptionBuilder(entry.key, entry.value, shouldPreselect));
  }

  final timeSelectBuilder =
      MultiselectBuilder(timePickerId.toString(), newMSTimes);

  // sends message with embed and components
  await originalContext.interactionEvent.editOriginalResponse(
    ComponentMessageBuilder()
      ..content = 'Choose your availability for ${selectedDayContext.selected}'
      ..embeds = []
      ..componentRows = [
        ComponentRowBuilder()..addComponent(timeSelectBuilder..maxValues = 24)
      ],
  );
  return timePickerId;
}
