class Course {
  final int? id;
  final String name;
  final String? teacher;
  final String? room;
  final String? color;
  final String? tag;
  final int? userId;

  Course({
    this.id,
    required this.name,
    this.teacher,
    this.room,
    this.color,
    this.tag,
    this.userId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'] ?? '',
      teacher: json['teacher'],
      room: json['room'],
      color: json['color'],
      tag: json['tag'],
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (teacher != null) 'teacher': teacher,
      if (room != null) 'room': room,
      if (color != null) 'color': color,
      if (tag != null) 'tag': tag,
    };
  }
}
