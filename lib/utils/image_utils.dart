import 'dart:io';

import 'package:discord_when2meet/objects/fixed_calendar.dart';
import 'package:image/image.dart';

Future<void> main() async {
  var calendar = FixedCalendar(eventName: 'Event');
  calendar.update({
    'sunday': ['13-14', '12-13'],
    'tuesday': ['10-11', '9-10', '11-12'],
    'friday': ['15-16'],
  });
  calendar.update({
    'sunday': ['13-14'],
    'tuesday': ['15-16', '16-17'],
    'thursday': ['13-14', '12-13'],
  });
  print(calendar.totalResponses);
  ImageUtils().createCalendar(calendar);
}

class ImageUtils {
  void createCalendar(FixedCalendar calendar) async {
    final opacity = getOpacity(calendar.totalResponses);

    // Decode the image file at the given path
    var command =
    await (Command()..decodeImageFile('assets/schedule.png')).execute();
    var command2 = await (Command()
      ..decodeImageFile('assets/overlay.png')
      ..colorOffset(alpha: (opacity - 1) * 255))
        .execute();

    final schedule = command.outputImage!;
    final overlay = command2.outputImage!;

    var img = schedule;
    
    // 69 and 36 are the offsets before the first 9 AM square on Monday.
    int currentX = 69;
    for (var entry in calendar.allAvailability.entries) {
      final day = entry.key;
      for (var entry2 in entry.value.entries) {
        final time = entry2.key;
        final participants = entry2.value;
        
        List<String> split = time.split('-');
        int startHour = int.parse(split[0]);
        int offset = ((startHour - 9) * 38) + 36;
        
        // Stack image "participants" times
        for (int i = 0; i < participants; i++) {
          img = compositeImage(img, overlay, dstX: currentX, dstY: offset);
        }
      }
      currentX += 45;
    }

    // Encode the resulting image to the PNG image format.
    final png = encodePng(img);
    // Write the PNG formatted data to a file.
    await File('image.png').writeAsBytes(png);
  }
  
  /// Given a total number of people, fetch the opacity needed for each
  /// blurple sheet.
  double getOpacity(int total) {
    return 1 / total;
  }
}