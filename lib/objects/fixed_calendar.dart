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

  /// Map of day ID to a map of times to a list of user IDs.
  /// {'sunday': {'1-2': ['123', '456'], '2-3': ['123']}, 'monday': {'4-5': ['123', '456'], '5-6': ['123', '456', '789']} }
  Map<String, Map<String, Set<String>>> allAvailability = {
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

  void update(Map<String, List<String>> dayToTimeAvailabilities, String userId) {
    // Loop through all entries (all days)
    for (var entry in dayToTimeAvailabilities.entries) {
      final day = entry.key;
      // Loop through all times in each day
      for (var time in entry.value) {
        allAvailability[day]![time] ??= {};
        allAvailability[day]![time]!.add(userId);
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
