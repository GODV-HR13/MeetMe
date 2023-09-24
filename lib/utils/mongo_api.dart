import 'dart:io';

import 'package:discord_when2meet/objects/fixed_calendar.dart';
import 'package:mongo_dart/mongo_dart.dart';

class MongoApi {
  static late final Db _db;

  static connectToDb() async {
    print('Connecting to MongoDB...');
    _db = await Db.create(Platform.environment['MONGO_URI']!);
    await _db.open();
    print('Connected to MongoDB.');
  }

  /// Run this before every database attempt.
  static Future<void> _ensureConnection() async {
    if (!_db.isConnected) {
      print('MongoDB disconnected—reconnecting...');
      await _db.close();
      await _db.open();
      print('MongoDB reconnected');
    }
  }

  // region Calendars
  static Future<WriteResult> insertCalendar(FixedCalendar calendar) async {
    await _ensureConnection();
    final collection = _db.collection('Calendars');
    return await collection.insertOne(calendar.toJson());
  }

  static Future<WriteResult> updateCalendar(FixedCalendar calendar) async {
    await _ensureConnection();
    final collection = _db.collection('Calendars');
    // TODO
    return await collection.replaceOne(
        where.eq('_id', calendar.id), calendar.toJson());
  }

  static Future<FixedCalendar?> fetchCalendar(String messageId) async {
    await _ensureConnection();
    final collection = _db.collection('Calendars');
    final bson = await collection.modernFindOne(
        selector: where.eq('messageId', messageId));
    // Return null or FixedCalendar
    return (bson == null) ? null : FixedCalendar.fromJson(bson);
  }
// endregion
}
