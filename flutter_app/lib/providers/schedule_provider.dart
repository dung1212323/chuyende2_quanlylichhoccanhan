import 'package:flutter/material.dart';
import '../models/schedule.dart';
import '../services/schedule_service.dart';
import '../services/notification_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleService _service = ScheduleService();
  final NotificationService _notificationService = NotificationService();
  List<Schedule> _schedules = [];
  bool _isLoading = false;
  String? _error;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? _token;
  void updateToken(String? token) {
    _token = token;
  }

  Future<void> fetchSchedules({String? type}) async {
    if (_token == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result =
          await _service.getSchedules(page: 1, limit: 100, type: type);
      _schedules = result['data'] as List<Schedule>;
      _isLoading = false;
      notifyListeners();
      // Schedule notification reminders for upcoming classes
      _notificationService.scheduleClassReminders(_schedules);
    } catch (e) {
      _isLoading = false;
      _error = 'Không thể tải danh sách lịch học';
      notifyListeners();
    }
  }

  Future<bool> addSchedule(Schedule schedule) async {
    try {
      await _service.createSchedule(schedule);
      await fetchSchedules();
      return true;
    } catch (e) {
      if (e.toString().contains('409') || e.toString().contains('Conflict')) {
        _error = 'Lịch bị trùng giờ với lịch đã có';
      } else {
        _error = 'Không thể thêm lịch học';
      }
      notifyListeners();
      return false;
    }
  }

//flut
  Future<bool> updateSchedule(int id, Schedule schedule) async {
    try {
      await _service.updateSchedule(id, schedule);
      await fetchSchedules();
      return true;
    } catch (e) {
      if (e.toString().contains('409') || e.toString().contains('Conflict')) {
        _error = 'Lịch bị trùng giờ với lịch đã có';
      } else {
        _error = 'Không thể cập nhật lịch học';
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteSchedule(int id) async {
    try {
      await _service.deleteSchedule(id);
      await fetchSchedules();
      return true;
    } catch (e) {
      _error = 'Không thể xoá lịch học';
      notifyListeners();
      return false;
    }
  }

  Future<String?> exportIcs() async {
    try {
      return await _service.exportIcs();
    } catch (e) {
      _error = 'Không thể xuất file lịch';
      notifyListeners();
      return null;
    }
  }

  List<Schedule> getSchedulesForDay(DateTime day) {
    final dateStr =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    return _schedules.where((s) {
      if (s.date == dateStr) return true;
      if (s.isRepeat && s.dayOfWeek == day.weekday % 7) return true;
      return false;
    }).toList();
  }

  int getWeeklyCount() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;
    for (int i = 0; i < 7; i++) {
      count += getSchedulesForDay(weekStart.add(Duration(days: i))).length;
    }
    return count;
  }
}
