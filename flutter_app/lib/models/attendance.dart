class Attendance {
  final int? id;
  final int scheduleId;
  final int? userId;
  final String date;
  final String status; // present, absent, late
  final String? note;

  Attendance({
    this.id,
    required this.scheduleId,
    this.userId,
    required this.date,
    required this.status,
    this.note,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      scheduleId: json['scheduleId'] ?? json['schedule_id'],
      userId: json['userId'] ?? json['user_id'],
      date: json['date'] ?? '',
      status: json['status'] ?? 'present',
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schedule_id': scheduleId,
      'date': date,
      'status': status,
      if (note != null) 'note': note,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'present':
        return 'Có mặt';
      case 'absent':
        return 'Vắng';
      case 'late':
        return 'Đi trễ';
      default:
        return status;
    }
  }
}
