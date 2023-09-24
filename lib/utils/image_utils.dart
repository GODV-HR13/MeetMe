import 'dart:io';

import 'package:image/image.dart';
import 'package:meetme/objects/fixed_calendar.dart';

Future<void> main() async {
  var calendar = FixedCalendar(eventName: 'Event', messageId: '0');
  calendar.update({
    'sunday': ['13-14', '12-13'],
    'tuesday': ['10-11', '9-10', '11-12'],
    'friday': ['15-16'],
  }, '0');
  calendar.update({
    'sunday': ['13-14'],
    'tuesday': ['15-16', '16-17'],
    'thursday': ['13-14', '12-13'],
  }, '0');
  ImageUtils.createCalendar(calendar, '0');
}

class ImageUtils {
  static Future<void> createCalendar(
      FixedCalendar calendar, String messageId) async {
    List<Set<String>> sets = [];
    for (var o in calendar.allAvailability.values) {
      for (var p in o.values) {
        sets.add(p);
      }
    }
    Set<String> merged = {};
    for (var set in sets) {
      merged.addAll(set);
    }

    final opacity = getOpacity(merged.length);

    // Decode the image file at the given path
    var command =
        await (Command()..decodeImageFile('assets/schedule.png')).execute();
    var command2 = await (Command()
          ..decodeImageFile('assets/overlay.png')
          ..colorOffset(alpha: (opacity - 1) * 150))
        .execute();

    final schedule = command.outputImage!;
    final overlay = command2.outputImage!;

    var img = schedule;

    // 69 and 36 are the offsets before the first 9 AM square on Monday.
    int currentX = 69;
    for (var entry in calendar.allAvailability.entries) {
      // final day = entry.key;
      for (var entry2 in entry.value.entries) {
        final time = entry2.key;
        final participants = entry2.value;

        List<String> split = time.split('-');
        int startHour = int.parse(split[0]);
        int offset = ((startHour - 9) * 38) + 36;

        // Stack image "participants" times
        for (String _ in participants) {
          // final coloredOverlay = (await (Command()
          //           ..decodeImageFile('assets/overlay.png')
          //           ..colorOffset(
          //               alpha: (opacity - 1) * 150,
          //               red: int.parse(participant) % 150,
          //               green: int.parse(participant) ~/ 20 % 150,
          //               blue: int.parse(participant) ~/ 30 % 150))
          //         .execute())
          //     .outputImage;
          img = compositeImage(img, overlay, dstX: currentX, dstY: offset);
        }
      }
      currentX += 45;
    }

    // Encode the resulting image to the PNG image format.
    final png = encodePng(img);
    // Write the PNG formatted data to a file.
    await Directory('generated').create();
    await File('generated/cal_$messageId.png').writeAsBytes(png);
  }

  /// Given a total number of people, fetch the opacity needed for each
  /// blurple sheet.
  static double getOpacity(int total) {
    return 1 / total;
  }
}
