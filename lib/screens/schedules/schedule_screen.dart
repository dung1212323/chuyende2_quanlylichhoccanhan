import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../providers/schedule_provider.dart';
import 'schedule_form_screen.dart';
import '../attendance/attendance_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  String? _typeFilter;

  @override
  void initState() {
    super.initState();
    final prov = context.read<ScheduleProvider>();
    Future.microtask(
        () => prov.fetchSchedules());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch học'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Lọc theo loại',
            onSelected: (value) {
              setState(() =>
                  _typeFilter = value == 'all' ? null : value);
              context
                  .read<ScheduleProvider>()
                  .fetchSchedules(type: _typeFilter);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'all', child: Text('Tất cả')),
              const PopupMenuItem(
                  value: 'class', child: Text('Buổi học')),
              const PopupMenuItem(
                  value: 'exam', child: Text('Lịch thi')),
              const PopupMenuItem(
                  value: 'deadline', child: Text('Deadline')),
            ],
          ),
        ],
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final daySchedules =
              prov.getSchedulesForDay(_selectedDay);
          return Column(
            children: [
              TableCalendar(
                locale: 'vi_VN',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) =>
                    isSameDay(_selectedDay, day),
                calendarFormat: _calendarFormat,
                onFormatChanged: (format) =>
                    setState(() => _calendarFormat = format),
                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },
                eventLoader: (day) =>
                    prov.getSchedulesForDay(day),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle),
                ),
                headerStyle: const HeaderStyle(
                    formatButtonShowsNext: false),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ngày ${DateFormat('dd/MM/yyyy').format(_selectedDay)}',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(
                              fontWeight: FontWeight.bold),
                    ),
                    Text('${daySchedules.length} lịch',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall),
                  ],
                ),
              ),
              Expanded(
                child: daySchedules.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Icon(Icons.event_available,
                                size: 48,
                                color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text('Không có lịch',
                                style: TextStyle(
                                    color:
                                        Colors.grey.shade600)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
                        itemCount: daySchedules.length,
                        itemBuilder: (context, index) {
                          final s = daySchedules[index];
                          return Dismissible(
                            key: Key('schedule_${s.id}'),
                            direction:
                                DismissDirection.endToStart,
                            background: Container(
                              alignment:
                                  Alignment.centerRight,
                              padding:
                                  const EdgeInsets.only(
                                      right: 20),
                              color: Colors.red,
                              child: const Icon(
                                  Icons.delete,
                                  color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<
                                          bool>(
                                      context: context,
                                      builder: (ctx) =>
                                          AlertDialog(
                                            title: const Text(
                                                'Xác nhận xoá'),
                                            content:
                                                const Text(
                                                    'Bạn có chắc muốn xoá lịch này?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          ctx,
                                                          false),
                                                  child:
                                                      const Text(
                                                          'Huỷ')),
                                              TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          ctx,
                                                          true),
                                                  child: const Text(
                                                      'Xoá',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.red))),
                                            ],
                                          )) ??
                                  false;
                            },
                            onDismissed: (_) =>
                                prov.deleteSchedule(
                                    s.id!),
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: s
                                              .type ==
                                          'exam'
                                      ? Colors.red
                                      : s.type ==
                                              'deadline'
                                          ? Colors.orange
                                          : Colors.blue,
                                  child: Icon(
                                    s.type == 'exam'
                                        ? Icons.quiz
                                        : s.type ==
                                                'deadline'
                                            ? Icons.flag
                                            : Icons
                                                .class_,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                    s.course?.name ??
                                        'Môn học'),
                                subtitle: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                        '${s.startTime} - ${s.endTime}'),
                                    Row(
                                      children: [
                                        Chip(
                                            label: Text(
                                                s.typeLabel,
                                                style: const TextStyle(
                                                    fontSize:
                                                        11)),
                                            visualDensity:
                                                VisualDensity
                                                    .compact),
                                        if (s.isRepeat) ...[
                                          const SizedBox(
                                              width:
                                                  4),
                                          Chip(
                                              label: Text(
                                                  'Lặp ${s.dayOfWeekLabel}',
                                                  style: const TextStyle(
                                                      fontSize:
                                                          11)),
                                              visualDensity:
                                                  VisualDensity
                                                      .compact),
                                        ],
                                        if (s.course
                                                ?.room !=
                                            null) ...[
                                          const SizedBox(
                                              width:
                                                  4),
                                          Chip(
                                              label: Text(
                                                  s.course!
                                                      .room!,
                                                  style: const TextStyle(
                                                      fontSize:
                                                          11)),
                                              visualDensity:
                                                  VisualDensity
                                                      .compact),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                trailing:
                                    PopupMenuButton(
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                        value: 'edit',
                                        child:
                                            Text('Sửa')),
                                    const PopupMenuItem(
                                        value:
                                            'attendance',
                                        child: Text(
                                            'Điểm danh')),
                                  ],
                                  onSelected: (value) {
                                    if (value ==
                                        'edit') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  ScheduleFormScreen(
                                                      schedule:
                                                          s)));
                                    } else if (value ==
                                        'attendance') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  AttendanceScreen(
                                                      schedule:
                                                          s)));
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const ScheduleFormScreen())),
        tooltip: 'Thêm lịch học',
        child: const Icon(Icons.add),
      ),
    );
  }
}
