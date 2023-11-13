import 'dart:collection';

import 'package:table_calendar/table_calendar.dart';

class Event {
  final String title;
  final String description;
  final Duration duration;
  final DateTime start;
  const Event(this.title, this.description, this.start, this.duration);
  // Event(this.title, this.description, this.start, this.end);

  @override
  String toString() => title;

  DateTime get end => start.add(duration);

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
