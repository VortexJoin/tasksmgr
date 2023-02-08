import 'dart:async';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class CalendarEvent {
  String summary;
  String description;
  DateTime? start;
  DateTime? end;

  CalendarEvent({
    required this.summary,
    required this.description,
    this.start,
    this.end,
  });
}

class CalendarService {
  late CalendarApi calendarApi;

  bool _isStarted = false;
  String _error = '';

  CalendarService() {
    _init();
  }

  _init() async {
    print('CalendarService-Starting');
    try {
      // http.Client client = http.Client();
      http.Client httpClient = await clientViaApplicationDefaultCredentials(
        scopes: [
          CalendarApi.calendarEventsScope,
        ],
      );

      calendarApi = CalendarApi(httpClient);
      _isStarted = true;
      print('CalendarService-Starting-Okay');
    } catch (e) {
      print('CalendarService-Starting-Error-$e');
      _isStarted = false;
      _error = e.toString();
    }
  }

  Future<List<CalendarEvent>> getEvents({
    required DateTime start,
    required DateTime end,
  }) async {
    const calendarId = "primary";

    final events = await calendarApi.events.list(
      calendarId,
      timeMin: start,
      timeMax: end,
    );

    return events.items!
        .map((event) => CalendarEvent(
              summary: event.summary ?? '',
              description: event.description ?? '',
              start: event.start!.dateTime!,
              end: event.end!.dateTime,
            ))
        .toList();
  }
}
