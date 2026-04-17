import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../models/schedule.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb) return;
    if (_initialized) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
        android: androidSettings, iOS: iosSettings);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (kIsWeb) return;
    final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    if (tzDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'course_tracker_channel',
          'Nhắc nhở lịch học',
          channelDescription: 'Thông báo nhắc nhở trước giờ học',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Schedule reminders 30 minutes before each upcoming class
  Future<void> scheduleClassReminders(List<Schedule> schedules) async {
    if (kIsWeb) return;
    await cancelAll();
    final now = DateTime.now();
    for (final s in schedules) {
      if (s.id == null) continue;
      final reminderTime = _getNextReminderTime(s, now);
      if (reminderTime == null) continue;
      await scheduleNotification(
        id: s.id!,
        title: 'Sắp đến giờ: ${s.course?.name ?? "Lịch học"}',
        body:
            '${s.typeLabel} bắt đầu lúc ${s.startTime}${s.course?.room != null ? " - Phòng ${s.course!.room}" : ""}',
        scheduledDate: reminderTime,
      );
    }
  }

  DateTime? _getNextReminderTime(Schedule s, DateTime now) {
    final parts = s.startTime.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    DateTime classTime;
    if (s.isRepeat && s.dayOfWeek != null) {
      // Find next occurrence of this weekday
      // dayOfWeek: 0=Sunday, 1=Monday... (same as DateTime.weekday % 7)
      final currentDow = now.weekday % 7;
      var daysUntil = (s.dayOfWeek! - currentDow + 7) % 7;
      if (daysUntil == 0) {
        final todayClass =
            DateTime(now.year, now.month, now.day, hour, minute);
        if (todayClass
            .subtract(const Duration(minutes: 30))
            .isBefore(now)) {
          daysUntil = 7;
        }
      }
      final nextDate = now.add(Duration(days: daysUntil));
      classTime =
          DateTime(nextDate.year, nextDate.month, nextDate.day, hour, minute);
    } else if (s.date != null) {
      final dateParts = s.date!.split('-');
      if (dateParts.length < 3) return null;
      classTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        hour,
        minute,
      );
    } else {
      return null;
    }

    final reminderTime = classTime.subtract(const Duration(minutes: 30));
    if (reminderTime.isBefore(now)) return null;
    return reminderTime;
  }

  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
