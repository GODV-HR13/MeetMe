// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_calendar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FixedCalendar _$FixedCalendarFromJson(Map<String, dynamic> json) =>
    FixedCalendar(
      eventName: json['eventName'] as String,
      messageId: json['messageId'] as String,
    )
      ..id = idFromJson(json['_id'] as ObjectId?)
      ..allAvailability = (json['allAvailability'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k,
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(
                  k, (e as List<dynamic>).map((e) => e as String).toSet()),
            )),
      );

Map<String, dynamic> _$FixedCalendarToJson(FixedCalendar instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'eventName': instance.eventName,
      'messageId': instance.messageId,
      'allAvailability': instance.allAvailability
          .map((k, e) => MapEntry(k, e.map((k, e) => MapEntry(k, e.toList())))),
    };
