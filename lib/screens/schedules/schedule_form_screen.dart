import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/course_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule.dart';

class ScheduleFormScreen extends StatefulWidget {
  final Schedule? schedule;
  const ScheduleFormScreen({super.key, this.schedule});
  @override
  State<ScheduleFormScreen> createState() =>
      _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _courseId;
  String _type = 'class';
  DateTime? _date;
  int? _dayOfWeek;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isRepeat = false;
  bool _saving = false;

  bool get isEditing => widget.schedule != null;

  final _typeOptions = [
    {'value': 'class', 'label': 'Buổi học'},
    {'value': 'exam', 'label': 'Lịch thi'},
    {'value': 'deadline', 'label': 'Deadline'},
  ];

  final _dayOptions = [
    {'value': 1, 'label': 'Thứ 2'},
    {'value': 2, 'label': 'Thứ 3'},
    {'value': 3, 'label': 'Thứ 4'},
    {'value': 4, 'label': 'Thứ 5'},
    {'value': 5, 'label': 'Thứ 6'},
    {'value': 6, 'label': 'Thứ 7'},
    {'value': 0, 'label': 'Chủ nhật'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      final s = widget.schedule!;
      _courseId = s.courseId;
      _type = s.type;
      if (s.date != null) _date = DateTime.tryParse(s.date!);
      _dayOfWeek = s.dayOfWeek;
      _startTime = _parseTime(s.startTime);
      _endTime = _parseTime(s.endTime);
      _isRepeat = s.isRepeat;
    }
    final courseProv = context.read<CourseProvider>();
    Future.microtask(
        () => courseProv.fetchCourses());
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
        hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_courseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn môn học')));
      return;
    }
    setState(() => _saving = true);
    final schedule = Schedule(
      courseId: _courseId!,
      type: _type,
      date: _isRepeat
          ? null
          : (_date != null
              ? DateFormat('yyyy-MM-dd').format(_date!)
              : null),
      dayOfWeek: _isRepeat ? _dayOfWeek : null,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      isRepeat: _isRepeat,
    );
    final prov = context.read<ScheduleProvider>();
    bool success;
    if (isEditing) {
      success = await prov.updateSchedule(
          widget.schedule!.id!, schedule);
    } else {
      success = await prov.addSchedule(schedule);
    }
    setState(() => _saving = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isEditing
                ? 'Cập nhật lịch thành công'
                : 'Thêm lịch học thành công')),
      );
      Navigator.pop(context);
    } else if (prov.error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(prov.error!),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text(isEditing ? 'Sửa lịch học' : 'Thêm lịch học')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course dropdown
              Consumer<CourseProvider>(
                builder: (context, prov, _) {
                  return DropdownButtonFormField<int>(
                    value: _courseId,
                    decoration: const InputDecoration(
                        labelText: 'Môn học *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.book)),
                    items: prov.courses
                        .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _courseId = v),
                    validator: (v) => v == null
                        ? 'Vui lòng chọn môn học'
                        : null,
                  );
                },
              ),
              const SizedBox(height: 16),
              // Type selector
              Text('Loại sự kiện',
                  style:
                      Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: _typeOptions
                    .map((t) => ButtonSegment(
                        value: t['value'] as String,
                        label: Text(t['label'] as String)))
                    .toList(),
                selected: {_type},
                onSelectionChanged: (v) =>
                    setState(() => _type = v.first),
              ),
              const SizedBox(height: 16),
              // Repeat toggle
              SwitchListTile(
                title: const Text('Lặp lại hàng tuần'),
                subtitle: const Text(
                    'Lịch sẽ tự động lặp mỗi tuần'),
                value: _isRepeat,
                onChanged: (v) =>
                    setState(() => _isRepeat = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 8),
              if (_isRepeat)
                DropdownButtonFormField<int>(
                  value: _dayOfWeek,
                  decoration: const InputDecoration(
                      labelText: 'Ngày trong tuần *',
                      border: OutlineInputBorder()),
                  items: _dayOptions
                      .map((d) => DropdownMenuItem(
                          value: d['value'] as int,
                          child:
                              Text(d['label'] as String)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _dayOfWeek = v),
                  validator: (v) =>
                      _isRepeat && v == null
                          ? 'Vui lòng chọn ngày'
                          : null,
                )
              else
                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                        labelText: 'Ngày học',
                        border: OutlineInputBorder(),
                        prefixIcon:
                            Icon(Icons.calendar_today)),
                    child: Text(_date != null
                        ? DateFormat('dd/MM/yyyy')
                            .format(_date!)
                        : 'Chọn ngày'),
                  ),
                ),
              const SizedBox(height: 16),
              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Giờ bắt đầu',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.access_time)),
                        child: Text(
                            _formatTime(_startTime)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                            labelText: 'Giờ kết thúc',
                            border: OutlineInputBorder(),
                            prefixIcon:
                                Icon(Icons.access_time)),
                        child:
                            Text(_formatTime(_endTime)),
                      ),
                    ),
                  ),
                ],
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
                          child:
                              CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                      : Text(
                          isEditing
                              ? 'Cập nhật'
                              : 'Thêm lịch học',
                          style: const TextStyle(
                              fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
