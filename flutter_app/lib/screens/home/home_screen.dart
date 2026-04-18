import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/app_drawer.dart';
import '../schedules/schedule_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final courseProv = context.read<CourseProvider>();
    final scheduleProv = context.read<ScheduleProvider>();
    final attendanceProv = context.read<AttendanceProvider>();
    Future.microtask(() {
      courseProv.fetchCourses();
      scheduleProv.fetchSchedules();
      attendanceProv.fetchStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ'),
        actions: [
          IconButton(
            icon: Icon(context.watch<ThemeProvider>().isDark
                ? Icons.light_mode
                : Icons.dark_mode),
            tooltip: 'Chế độ sáng/tối',
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              final authProv = Provider.of<AuthProvider>(context, listen: false);
              final nav = Navigator.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Đăng xuất'),
                  content: const Text('Bạn có chắc muốn đăng xuất?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Huỷ')),
                    FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Đăng xuất')),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await authProv.logout();
                if (mounted) {
                  nav.pushReplacementNamed('/login');
                }
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          final cp = context.read<CourseProvider>();
          final sp = context.read<ScheduleProvider>();
          final ap = context.read<AttendanceProvider>();
          await cp.fetchCourses();
          await sp.fetchSchedules();
          await ap.fetchStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats cards
              Consumer2<CourseProvider, ScheduleProvider>(
                builder: (context, courseProv, scheduleProv, _) {
                  final todaySchedules =
                      scheduleProv.getSchedulesForDay(DateTime.now());
                  final weeklyCount = scheduleProv.getWeeklyCount();
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: _StatCard(
                                  icon: Icons.book,
                                  label: 'Môn học',
                                  value:
                                      '${courseProv.courses.length}',
                                  color: Colors.blue)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _StatCard(
                                  icon: Icons.calendar_today,
                                  label: 'Lịch hôm nay',
                                  value:
                                      '${todaySchedules.length}',
                                  color: Colors.orange)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                              child: _StatCard(
                                  icon: Icons.date_range,
                                  label: 'Lịch tuần này',
                                  value: '$weeklyCount',
                                  color: Colors.green)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _StatCard(
                                  icon: Icons.schedule,
                                  label: 'Tổng lịch',
                                  value:
                                      '${scheduleProv.schedules.length}',
                                  color: Colors.purple)),
                        ],
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Quick actions
              Text('Truy cập nhanh',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/courses'),
                      icon: const Icon(Icons.book),
                      label: const Text('Môn học'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/schedules'),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Lịch học'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Today's schedule
              Text('Lịch học hôm nay',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Consumer<ScheduleProvider>(
                builder: (context, prov, _) {
                  final today =
                      prov.getSchedulesForDay(DateTime.now());
                  if (prov.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (today.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.event_available,
                                  size: 48,
                                  color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text('Hôm nay không có lịch học',
                                  style: TextStyle(
                                      color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: today
                        .map((s) => Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: s.type == 'exam'
                                      ? Colors.red
                                      : s.type == 'deadline'
                                          ? Colors.orange
                                          : Colors.blue,
                                  child: Icon(
                                    s.type == 'exam'
                                        ? Icons.quiz
                                        : s.type == 'deadline'
                                            ? Icons.flag
                                            : Icons.class_,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                title:
                                    Text(s.course?.name ?? 'Môn học'),
                                subtitle: Text(
                                    '${s.startTime} - ${s.endTime} | ${s.typeLabel}'),
                                trailing: s.course?.room != null
                                    ? Chip(
                                        label:
                                            Text(s.course!.room!))
                                    : null,
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Attendance stats
              Text('Thống kê điểm danh',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Consumer<AttendanceProvider>(
                builder: (context, prov, _) {
                  if (prov.isLoading) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (prov.stats.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text('Chưa có dữ liệu điểm danh',
                              style: TextStyle(
                                  color: Colors.grey.shade600)),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: prov.stats
                        .map((stat) => Card(
                              child: ListTile(
                                title:
                                    Text(stat['courseName'] ?? ''),
                                subtitle: Text(
                                    'Có mặt: ${stat['present']} | Vắng: ${stat['absent']} | Trễ: ${stat['late']}'),
                                trailing: CircleAvatar(
                                  backgroundColor:
                                      (stat['attendanceRate'] ??
                                                  0) >=
                                              80
                                          ? Colors.green
                                          : Colors.red,
                                  child: Text(
                                      '${stat['attendanceRate']}%',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12)),
                                ),
                              ),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ScheduleFormScreen())),
        tooltip: 'Thêm lịch học',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
