import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _service = AttendanceService();
  List<Attendance> _attendances = [];
  List<Map<String, dynamic>> _stats = [];
  bool _isLoading = false;

  List<Attendance> get attendances => _attendances;
  List<Map<String, dynamic>> get stats => _stats;
  bool get isLoading => _isLoading;

  String? _token;
  void updateToken(String? token) {
    _token = token;
  }

  Future<void> fetchAttendances(int scheduleId) async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _attendances = await _service.getAttendances(scheduleId);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markAttendance(Attendance attendance) async {
    try {
      await _service.createOrUpdate(attendance);
      await fetchAttendances(attendance.scheduleId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> fetchStats() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _stats = await _service.getStats();
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }
}
