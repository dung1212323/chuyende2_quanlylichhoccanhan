import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/attendance_provider.dart';
import '../../models/schedule.dart';
import '../../models/attendance.dart';

class AttendanceScreen extends StatefulWidget {
  final Schedule schedule;
  const AttendanceScreen({super.key, required this.schedule});
  @override
  State<AttendanceScreen> createState() =>
      _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    final prov = context.read<AttendanceProvider>();
    Future.microtask(() => prov.fetchAttendances(widget.schedule.id!));
  }

  Future<void> _markAttendance(String status) async {
    final today =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final attendance = Attendance(
      scheduleId: widget.schedule.id!,
      date: today,
      status: status,
    );
    final success = await context
        .read<AttendanceProvider>()
        .markAttendance(attendance);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Đã điểm danh: ${_statusLabel(status)}')),
      );
    }
  }

  String _statusLabel(String status) {
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

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.watch_later;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Điểm danh - ${widget.schedule.course?.name ?? ""}'),
      ),
      body: Column(
        children: [
          // Schedule info card
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.class_,
                          color: Theme.of(context)
                              .colorScheme
                              .primary),
                      const SizedBox(width: 8),
                      Text(
                          widget.schedule.course?.name ?? '',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                          '${widget.schedule.startTime} - ${widget.schedule.endTime}'),
                      const SizedBox(width: 16),
                      if (widget.schedule.course?.room !=
                          null) ...[
                        const Icon(Icons.room,
                            size: 16,
                            color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(widget
                            .schedule.course!.room!),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Mark attendance buttons
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        _markAttendance('present'),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Có mặt'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        _markAttendance('late'),
                    icon: const Icon(Icons.watch_later),
                    label: const Text('Đi trễ'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        _markAttendance('absent'),
                    icon: const Icon(Icons.cancel),
                    label: const Text('Vắng'),
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Lịch sử điểm danh',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(
                          fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Consumer<AttendanceProvider>(
              builder: (context, prov, _) {
                if (prov.isLoading) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                if (prov.attendances.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history,
                            size: 48,
                            color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                            'Chưa có lịch sử điểm danh',
                            style: TextStyle(
                                color: Colors
                                    .grey.shade600)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12),
                  itemCount: prov.attendances.length,
                  itemBuilder: (context, index) {
                    final a = prov.attendances[index];
                    return Card(
                      child: ListTile(
                        leading: Icon(
                            _statusIcon(a.status),
                            color:
                                _statusColor(a.status)),
                        title:
                            Text(_statusLabel(a.status)),
                        subtitle: Text(a.date),
                        trailing: a.note != null
                            ? Tooltip(
                                message: a.note!,
                                child: const Icon(
                                    Icons.note,
                                    size: 18))
                            : null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
