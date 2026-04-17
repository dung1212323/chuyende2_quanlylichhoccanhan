import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/auth_provider.dart';
import 'providers/course_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/courses/course_list_screen.dart';
import 'screens/schedules/schedule_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CourseProvider>(
          create: (_) => CourseProvider(),
          update: (_, auth, prev) => prev!..updateToken(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ScheduleProvider>(
          create: (_) => ScheduleProvider(),
          update: (_, auth, prev) => prev!..updateToken(auth.token),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AttendanceProvider>(
          create: (_) => AttendanceProvider(),
          update: (_, auth, prev) => prev!..updateToken(auth.token),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Course Tracker',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorSchemeSeed: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              colorSchemeSeed: Colors.blue,
              useMaterial3: true,
              brightness: Brightness.dark,
            ),
            home: const SplashScreen(),
            routes: {
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/home': (_) => const HomeScreen(),
              '/courses': (_) => const CourseListScreen(),
              '/schedules': (_) => const ScheduleScreen(),
            },
          );
        },
      ),
    );
  }
}
