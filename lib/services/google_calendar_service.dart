// ignore_for_file: avoid_print
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart';

// Replace this with the path to your service account JSON file
const String serviceAccountJson = 'android/app/google-services.json';

Future<calendar.CalendarApi> getCalendarService() async {
  // final auth.ServiceAccountCredentials credentials =
  //     auth.ServiceAccountCredentials();

  // auth.ServiceAccountCredentials.fromJson(
  //   await rootBundle.loadString(serviceAccountJson),
  // );

  final client = await auth.clientViaApplicationDefaultCredentials(
    scopes: [calendar.CalendarApi.calendarScope],
    baseClient: Client(),
  );

  return calendar.CalendarApi(client);
}

insertEvent() async {
  final calendarService = await getCalendarService();

  // Read a list of calendars
  calendar.CalendarList calendarList =
      await calendarService.calendarList.list();
  print('Calendars:');
  if (calendarList.items != null) {
    for (final calendarListEntry in calendarList.items!) {
      print('- ${calendarListEntry.summary}');
    }
  } else {
    print('No calendars found.');
  }

  // Create a new event
  final newEvent = calendar.Event()
    ..summary = 'Test Event'
    ..description = 'This is a test event created from the API'
    ..start = calendar.EventDateTime();
  newEvent.end = calendar.EventDateTime()
    ..dateTime = (DateTime.now().add(const Duration(hours: 1))).toUtc()
    ..timeZone = 'UTC';

  // Replace 'primary' with the calendar ID you want to create the event in
  final createdEvent = await calendarService.events.insert(newEvent, 'primary');
  print('Event created:');
  print('- Summary: ${createdEvent.summary}');
  print('- Description: ${createdEvent.description}');
  print('- Start: ${createdEvent.start}');
  print('- End: ${createdEvent.end}');
}
