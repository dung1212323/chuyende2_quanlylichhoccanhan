import 'api_service.dart';
import '../models/course.dart';

class CourseService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getCourses(
      {int page = 1, int limit = 20}) async {
    final response = await _api.dio.get('/courses', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return {
      'data': (response.data['data'] as List)
          .map((e) => Course.fromJson(e))
          .toList(),
      'total': response.data['total'],
      'totalPages': response.data['totalPages'],
    };
  }

  Future<Course> createCourse(Course course) async {
    final response = await _api.dio.post('/courses', data: course.toJson());
    return Course.fromJson(response.data);
  }

  Future<Course> updateCourse(int id, Course course) async {
    final response =
        await _api.dio.put('/courses/$id', data: course.toJson());
    return Course.fromJson(response.data);
  }

  Future<void> deleteCourse(int id) async {
    await _api.dio.delete('/courses/$id');
  }
}
