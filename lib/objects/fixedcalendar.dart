class FixedCalendar {
  // Name of event.
  String eventName;

  // Total number of people who have responded.
  int totalResponses = 0;

  Map<String, Map<String, int>> allAvailability = {
    'Sunday': {},
    'Monday': {},
    'Tuesday': {},
    'Wednesday': {},
    'Thursday': {},
    'Friday': {},
    'Saturday': {},
  };

  FixedCalendar({
    required this.eventName,
  });

  void update(Map<String, List<String>> dayToTimeAvailabilities) {
    for (final day in dayToTimeAvailabilities.keys) {
      for (final time in dayToTimeAvailabilities[day]!) {
        allAvailability[day]![time] ??= 0;
        allAvailability[day]![time] = allAvailability[day]![time]! + 1;
      }
    }
  }
}

// testing
/*
void main() {
  FixedCalendar test = FixedCalendar(eventName: 'testing');

  FixedCalendar.update()

}

 */