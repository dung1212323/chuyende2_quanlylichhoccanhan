import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import 'course_form_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});
  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final prov = context.read<CourseProvider>();
    Future.microtask(() => prov.fetchCourses());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách môn học')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm môn học...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) =>
                  setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: Consumer<CourseProvider>(
              builder: (context, prov, _) {
                if (prov.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final filtered = prov.courses
                    .where((c) =>
                        _searchQuery.isEmpty ||
                        c.name.toLowerCase().contains(_searchQuery) ||
                        (c.teacher
                                ?.toLowerCase()
                                .contains(_searchQuery) ??
                            false) ||
                        (c.tag?.toLowerCase().contains(_searchQuery) ??
                            false))
                    .toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.book_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                            _searchQuery.isEmpty
                                ? 'Chưa có môn học nào'
                                : 'Không tìm thấy môn học',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16)),
                        if (_searchQuery.isEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Nhấn nút + để thêm môn mới',
                              style: TextStyle(
                                  color: Colors.grey.shade400)),
                        ],
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => prov.fetchCourses(),
                  child: ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final course = filtered[index];
                      return Dismissible(
                        key: Key('course_${course.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red,
                          child: const Icon(Icons.delete,
                              color: Colors.white),
                        ),
                        confirmDismiss: (_) async {
                          return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xác nhận xoá'),
                                  content: Text(
                                      'Bạn có chắc muốn xoá môn "${course.name}"?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(
                                                ctx, false),
                                        child: const Text('Huỷ')),
                                    TextButton(
                                        onPressed: () =>
                                            Navigator.pop(
                                                ctx, true),
                                        child: const Text('Xoá',
                                            style: TextStyle(
                                                color:
                                                    Colors.red))),
                                  ],
                                ),
                              ) ??
                              false;
                        },
                        onDismissed: (_) =>
                            prov.deleteCourse(course.id!),
                        child: Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  _parseColor(course.color) ??
                                      Theme.of(context)
                                          .colorScheme
                                          .primary,
                              child: Text(
                                  course.name[0].toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.bold)),
                            ),
                            title: Text(course.name),
                            subtitle: Text([
                              if (course.teacher != null)
                                'GV: ${course.teacher}',
                              if (course.room != null)
                                'Phòng: ${course.room}',
                            ].join(' | ')),
                            trailing: course.tag != null
                                ? Chip(
                                    label: Text(course.tag!,
                                        style: const TextStyle(
                                            fontSize: 11)))
                                : null,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        CourseFormScreen(
                                            course: course))),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CourseFormScreen())),
        tooltip: 'Thêm môn học',
        child: const Icon(Icons.add),
      ),
    );
  }

  Color? _parseColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return null;
    try {
      return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
    } catch (_) {
      return null;
    }
  }
}
