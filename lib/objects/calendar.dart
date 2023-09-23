// Calendar stores information about an event and its responders.
class Calendar {
  // Name of event.
  String eventName;

  // DateTime should contain year, month, day, hour, minute fields.
  // startTime and endTime represent desired start and end time of the calendar.
  // temporarily assumed to be by the hour
  // startTime is eaten up (modified).. i think ?!
  DateTime startTime;
  DateTime endTime;

  // Total number of people who have responded.
  int totalResponses = 0;

  // 2D list to track number of people who are available in a given time slot.
  List<AvailabilityTime> availability = [];


  // Constructor for Calendar object.
  Calendar({
    required this.eventName,
    required this.startTime,
    required this.endTime,
  }) {
    
    DateTime indexTime = startTime;
    
    while (!indexTime.add(Duration(hours: 1)).isAfter(endTime)) {
      availability.add(
        AvailabilityTime(
          intervalStartTime: indexTime,
          intervalEndTime: indexTime.add(Duration(hours:1)),
        ));
      indexTime = indexTime.add(Duration(hours: 1));
    }
  }

  @override
  String toString() {
    return 'Calendar{eventName: $eventName, startTime: $startTime, endTime: $endTime, totalResponses: $totalResponses, availability: $availability}';
  }
}

// AvailabilityTime tracks how many participants are attending a certain time interval.
class AvailabilityTime {
  DateTime intervalStartTime;
  DateTime intervalEndTime;
  int participants = 0;
  
  AvailabilityTime({
    required this.intervalStartTime,
    required this.intervalEndTime,
  });

  @override
  String toString() {
    return 'Calendar{intervalStartTime: $intervalStartTime, intervalEndTime: $intervalEndTime, participants: $participants}';
  }
}

void main() {
  print(Calendar(eventName: 'namename', startTime: DateTime.now(), endTime: DateTime.utc(2023, 9, 24)));
}

// Duration elapsedTime = this.endTime.difference(this.startTime);
