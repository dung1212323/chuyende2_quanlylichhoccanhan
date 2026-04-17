import 'api_service.dart';
import '../models/attendance.dart';

class AttendanceService {
  final ApiService _api = ApiService();

  Future<List<Attendance>> getAttendances(int scheduleId) async {
    final response = await _api.dio.get('/attendances', queryParameters: {
      'scheduleId': scheduleId,
    });
    return (response.data as List)
        .map((e) => Attendance.fromJson(e))
        .toList();
  }

  Future<Attendance> createOrUpdate(Attendance attendance) async {
    final response =
        await _api.dio.post('/attendances', data: attendance.toJson());
    return Attendance.fromJson(response.data);
  }

  Future<List<Map<String, dynamic>>> getStats() async {
    final response = await _api.dio.get('/attendances/stats');
    return List<Map<String, dynamic>>.from(response.data);
  }
}
