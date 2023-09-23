class FixedCalendar {
  // Name of event.
  String eventName;

  // Total number of people who have responded.
  int totalResponses = 0;

  /// EG
  /// {'Sunday': {'1-2': 4, '2-3': 1}, 'Monday': {'4-5': 2, '5-6': 4} }
  Map<String, Map<String, int>> allAvailability = {
    'sunday': {},
    'monday': {},
    'tuesday': {},
    'wednesday': {},
    'thursday': {},
    'friday': {},
    'saturday': {},
  };

  FixedCalendar({
    required this.eventName
  });

  void update(Map<String, List<String>> dayToTimeAvailabilities) {
    totalResponses++;
    // Loop through all entries (all days)
    for (var entry in dayToTimeAvailabilities.entries) {
      final day = entry.key;
      // Loop through all times in each day
      for (var time in entry.value) {
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
