import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'api_service.dart';
import '../models/schedule.dart';

class ScheduleService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getSchedules(
      {int page = 1, int limit = 50, String? type}) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (type != null) params['type'] = type;
    final response =
        await _api.dio.get('/schedules', queryParameters: params);
    return {
      'data': (response.data['data'] as List)
          .map((e) => Schedule.fromJson(e))
          .toList(),
      'total': response.data['total'],
      'totalPages': response.data['totalPages'],
    };
  }

  Future<Schedule> createSchedule(Schedule schedule) async {
    final response =
        await _api.dio.post('/schedules', data: schedule.toJson());
    return Schedule.fromJson(response.data);
  }

  Future<Schedule> updateSchedule(int id, Schedule schedule) async {
    final response =
        await _api.dio.put('/schedules/$id', data: schedule.toJson());
    return Schedule.fromJson(response.data);
  }

  Future<void> deleteSchedule(int id) async {
    await _api.dio.delete('/schedules/$id');
  }

  Future<Map<String, dynamic>> checkConflict({
    String? date,
    int? dayOfWeek,
    required String startTime,
    required String endTime,
    int? excludeId,
  }) async {
    final response =
        await _api.dio.post('/schedules/check-conflict', data: {
      if (date != null) 'date': date,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      if (excludeId != null) 'exclude_id': excludeId,
    });
    return response.data;
  }

  Future<String> exportIcs() async {
    final response = await _api.dio.get(
      '/schedules/export',
      options: Options(responseType: ResponseType.plain),
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/course-tracker.ics');
    await file.writeAsString(response.data);
    return file.path;
  }
}
