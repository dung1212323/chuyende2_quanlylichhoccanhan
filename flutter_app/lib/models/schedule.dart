import 'course.dart';

class Schedule {
  final int? id;
  final int courseId;
  final String type; // class, exam, deadline
  final String? date;
  final int? dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isRepeat;
  final Course? course; // nested

  Schedule({
    this.id,
    required this.courseId,
    this.type = 'class',
    this.date,
    this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.isRepeat = false,
    this.course,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      courseId: json['courseId'] ?? json['course_id'],
      type: json['type'] ?? 'class',
      date: json['date'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'] ?? json['start_time'] ?? '',
      endTime: json['endTime'] ?? json['end_time'] ?? '',
      isRepeat: json['isRepeat'] ?? json['repeat'] ?? false,
      course: json['course'] != null ? Course.fromJson(json['course']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'course_id': courseId,
      'type': type,
      if (date != null) 'date': date,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'repeat': isRepeat,
    };
  }

  String get typeLabel {
    switch (type) {
      case 'exam':
        return 'Thi';
      case 'deadline':
        return 'Deadline';
      default:
        return 'Học';
    }
  }

  String get dayOfWeekLabel {
    if (dayOfWeek == null) return '';
    const days = [
      'Chủ nhật',
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7'
    ];
    return days[dayOfWeek!];
  }
}
