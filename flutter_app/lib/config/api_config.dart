import 'package:flutter/foundation.dart';

class ApiConfig {
  // Web dùng localhost, Android emulator dùng 10.0.2.2
  static String get baseUrl =>
      kIsWeb ? 'http://localhost:3000/api' : 'http://10.0.2.2:3000/api';
}
// Lưu ý: Đảm bảo backend server của bạn đang chạy trên cổng 3000 và có endpoint /api
