import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class Event {
  final String title;
  final String description;
  final Duration duration;
  final DateTime start;
  final DateTime end;
  final String userEmail = 'test@example.com';
  final DateTime dateStamp = DateTime.now();

  Event(this.title, this.description, this.start, this.duration)
      : end = start.add(duration);

  Event.fromEnd(this.title, this.description, this.start, this.end)
      : duration = end.difference(start);
  // Event(this.title, this.description, this.start, this.end);

  @override
  String toString() => title;

  bool isWithin(DateTime start, DateTime end) {
    return this.start.isAfter(start) && this.end.isBefore(end);
  }

  String get durationString {
    String hours = duration.inHours.toString();
    String minutes = (duration.inMinutes % 60).toString();
    return '$hours:$minutes';
  }

  String get formattedDuration {
    String startHour = start.hour.toString();
    String startMinute = start.minute.toString();
    String endHour = end.hour.toString();
    String endMinute = end.minute.toString();
    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  String toICSEvent() {
    DateFormat icsFormat = DateFormat('yyyyMMdd\'T\'HHmmss\'Z\'');
    String icsString = 'BEGIN:VEVENT\n'
'UID:$userEmail\n'
        'DTSTAMP:${icsFormat.format(dateStamp.toUtc())}\n'
        'SUMMARY:$title\n'
        'DTSTART:${icsFormat.format(start.toUtc())}\n'
        'DTEND:${icsFormat.format(end.toUtc())}\n'
        'DESCRIPTION:$description\n'
        'END:VEVENT\n';
    // print(icsString);
    return icsString;
  }
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

//example events
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

const Duration _kEventDuration = Duration(hours: 1);

final _kEventSource = {
  for (var item in List.generate(50, (index) => index))
    DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5): List.generate(
        item % 4 + 1,
        (index) => Event(
            'Event $item | ${index + 1}',
            'Test Desc',
            DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
            _kEventDuration))
}..addAll({
    kToday: [
      Event('Today\'s Event 1', 'Test Desc', kToday, _kEventDuration),
      Event('Today\'s Event 2', 'Test Desc', kToday, _kEventDuration),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

void createEvent(
    DateTime date, String title, String description, Duration duration) {
  kEvents.update(
      date, (value) => value..add(Event(title, description, date, duration)),
      ifAbsent: () => [Event(title, description, date, duration)]);
}

double timeToDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

String getICSString() {
String icsString = 'BEGIN:VCALENDAR\n'
      'VERSION:2.0\n'
      'PRODID:-//Flutter//Event Calendar//EN\n';

  for (var event in kEvents.values) {
    for (var item in event) {
      icsString += item.toICSEvent();
      break;
      // print(item.toICSEvent());
    }
  break;
  }
  icsString += 'END:VCALENDAR';
  return icsString;
}

void shareICS() {
  String icsString = getICSString();
  Uint8List bytes = Uint8List.fromList(utf8.encode(icsString));
  if (kIsWeb){

  }else{
  XFile icsFile =
      XFile.fromData(bytes, name: 'example.ics', mimeType: 'text/calendar');
  Share.shareXFiles([icsFile], text: 'Here is your calendar file!');
  }
  // final bytes = File('example.ics').writeAsStringSync(icsString);
}
