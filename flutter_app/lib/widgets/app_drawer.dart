import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/schedule_provider.dart';
import 'package:share_plus/share_plus.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.school, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text('Course Tracker',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.white)),
                Text('Quản lý lịch học',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Trang chủ'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Môn học'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/courses');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Lịch học'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/schedules');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Xuất lịch (ICS)'),
            onTap: () async {
              Navigator.pop(context);
              final path =
                  await context.read<ScheduleProvider>().exportIcs();
              if (path != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Đã lưu file tại: $path'),
                  action: SnackBarAction(
                    label: 'Chia sẻ',
                    onPressed: () =>
                        Share.shareXFiles([XFile(path)]),
                  ),
                ));
              }
            },
          ),
          Consumer<ThemeProvider>(
            builder: (context, theme, _) => SwitchListTile(
              secondary: Icon(
                  theme.isDark ? Icons.dark_mode : Icons.light_mode),
              title: const Text('Chế độ tối'),
              value: theme.isDark,
              onChanged: (_) => theme.toggleTheme(),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất',
                style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
