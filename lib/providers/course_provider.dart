import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/course_service.dart';

class CourseProvider extends ChangeNotifier {
  final CourseService _service = CourseService();
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _error;
  int _totalPages = 1;
  int _currentPage = 1;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;

  String? _token;
  void updateToken(String? token) {
    _token = token;
  }

  Future<void> fetchCourses({int page = 1}) async {
    if (_token == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _service.getCourses(page: page);
      _courses = result['data'] as List<Course>;
      _totalPages = result['totalPages'] as int;
      _currentPage = page;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Không thể tải danh sách môn học';
      notifyListeners();
    }
  }

  Future<bool> addCourse(Course course) async {
    try {
      await _service.createCourse(course);
      await fetchCourses();
      return true;
    } catch (e) {
      _error = 'Không thể thêm môn học';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse(int id, Course course) async {
    try {
      await _service.updateCourse(id, course);
      await fetchCourses(page: _currentPage);
      return true;
    } catch (e) {
      _error = 'Không thể cập nhật môn học';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(int id) async {
    try {
      await _service.deleteCourse(id);
      await fetchCourses(page: _currentPage);
      return true;
    } catch (e) {
      _error = 'Không thể xoá môn học';
      notifyListeners();
      return false;
    }
  }
}
