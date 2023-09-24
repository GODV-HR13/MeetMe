import 'package:json_annotation/json_annotation.dart';
import 'package:mongo_dart/mongo_dart.dart';

part 'fixed_calendar.g.dart';

@JsonSerializable()
class FixedCalendar {
  /// Mongo ID of the object
  @JsonKey(name: '_id', fromJson: idFromJson)
  ObjectId? id;
  
  /// Name of event.
  String eventName;

  /// Message ID of the event's main message
  String messageId;

  /// Total number of people who have responded.
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
    required this.eventName,
    required this.messageId,
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

  factory FixedCalendar.fromJson(Map<String, dynamic> json) =>
      _$FixedCalendarFromJson(json);

  Map<String, dynamic> toJson() => _$FixedCalendarToJson(this);
}

ObjectId? idFromJson(ObjectId? id) {
  return id;
}

// testing
/*
void main() {
  FixedCalendar test = FixedCalendar(eventName: 'testing');

  FixedCalendar.update()

}

 */
