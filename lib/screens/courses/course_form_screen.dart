import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../models/course.dart';

class CourseFormScreen extends StatefulWidget {
  final Course? course;
  const CourseFormScreen({super.key, this.course});
  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _teacherCtrl;
  late TextEditingController _roomCtrl;
  late TextEditingController _tagCtrl;
  String? _selectedColor;
  bool _saving = false;

  bool get isEditing => widget.course != null;

  static const _colorOptions = [
    '#2196F3',
    '#4CAF50',
    '#FF9800',
    '#F44336',
    '#9C27B0',
    '#00BCD4',
    '#795548',
    '#607D8B',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.course?.name ?? '');
    _teacherCtrl =
        TextEditingController(text: widget.course?.teacher ?? '');
    _roomCtrl =
        TextEditingController(text: widget.course?.room ?? '');
    _tagCtrl =
        TextEditingController(text: widget.course?.tag ?? '');
    _selectedColor = widget.course?.color;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _teacherCtrl.dispose();
    _roomCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final course = Course(
      name: _nameCtrl.text.trim(),
      teacher: _teacherCtrl.text.trim().isEmpty
          ? null
          : _teacherCtrl.text.trim(),
      room: _roomCtrl.text.trim().isEmpty
          ? null
          : _roomCtrl.text.trim(),
      color: _selectedColor,
      tag: _tagCtrl.text.trim().isEmpty
          ? null
          : _tagCtrl.text.trim(),
    );
    final prov = context.read<CourseProvider>();
    bool success;
    if (isEditing) {
      success = await prov.updateCourse(widget.course!.id!, course);
    } else {
      success = await prov.addCourse(course);
    }
    setState(() => _saving = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isEditing
                ? 'Cập nhật môn học thành công'
                : 'Thêm môn học thành công')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(isEditing ? 'Sửa môn học' : 'Thêm môn học')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Tên môn học *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.book)),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Vui lòng nhập tên môn học'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teacherCtrl,
                decoration: const InputDecoration(
                    labelText: 'Giảng viên',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _roomCtrl,
                decoration: const InputDecoration(
                    labelText: 'Phòng học',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.room)),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tagCtrl,
                decoration: const InputDecoration(
                    labelText: 'Tag (ví dụ: Chuyên ngành)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label)),
              ),
              const SizedBox(height: 16),
              Text('Màu sắc',
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colorOptions.map((c) {
                  final color = Color(
                      int.parse(c.replaceFirst('#', '0xFF')));
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColor = c),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: _selectedColor == c
                            ? Border.all(
                                color: Colors.black, width: 3)
                            : null,
                      ),
                      child: _selectedColor == c
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
                      : Text(
                          isEditing ? 'Cập nhật' : 'Thêm môn học',
                          style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
