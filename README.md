HEAD
course_tracker A new Flutter project.
HEAD
# course_tracker
A new Flutter project.
# Course Tracker – Ứng dụng Quản lý Lịch học Cá nhân
 **Personal Course Tracker Application**
## Mục lục
1. [Giới thiệu](#giới-thiệu)
2. [Mục tiêu hệ thống](#mục-tiêu-hệ-thống)
3. [Chức năng hệ thống](#chức-năng-hệ-thống)
4. [Kiến trúc hệ thống](#kiến-trúc-hệ-thống)
5. [Cấu trúc dự án](#cấu-trúc-dự-án)
6. [Công nghệ sử dụng](#công-nghệ-sử-dụng)
7. [Thiết kế Database](#thiết-kế-database)
8. [API Endpoints](#api-endpoints)
9. [Hướng dẫn cài đặt & chạy dự án](#hướng-dẫn-cài-đặt--chạy-dự-án)
10. [Tiến độ thực hiện](#tiến-độ-thực-hiện)
11. [Phân công nhóm](#phân-công-nhóm)


## Giới thiệu

**Course Tracker** là ứng dụng di động (Flutter) kết hợp backend (NestJS) giúp sinh viên quản lý lịch học cá nhân một cách hiệu quả. Ứng dụng hỗ trợ quản lý môn học, lịch học theo ngày/tuần, nhắc nhở trước giờ học và nhiều tính năng tiện ích khác.

---

## Mục tiêu hệ thống

- Giúp sinh viên theo dõi và quản lý lịch học một cách có tổ chức
- Quản lý danh sách môn học (tên môn, giảng viên, phòng học)
- Xem lịch học theo ngày hoặc theo tuần
- Nhắc nhở trước giờ học, tránh bỏ lỡ buổi học

---

## Chức năng hệ thống

### Chức năng cơ bản (Base)

| STT | Chức năng | Mô tả |
|-----|-----------|-------|
| 1 | Đăng ký / Đăng nhập | Xác thực bằng Email + Password, sử dụng JWT |
| 2 | Đăng xuất (Logout) | Xoá token khỏi thiết bị, kết thúc phiên làm việc |
| 3 | Splash Screen + Token Check | Kiểm tra JWT còn hạn khi mở app, tự điều hướng Login / Home |
| 4 | Quản lý môn học | Thêm / Sửa / Xóa môn học (tên môn, giảng viên, phòng học) |
| 5 | Quản lý lịch học | Thêm lịch theo ngày hoặc theo thứ (lặp lại hàng tuần) |
| 6 | Phát hiện trùng lịch (Conflict Detection) | Cảnh báo khi thêm/sửa lịch bị chồng giờ với lịch đã có |
| 7 | Xem lịch học | Hiển thị dạng danh sách (ListView) và dạng lịch (Calendar) |
| 8 | Phân trang (Pagination) | Danh sách môn học và lịch học hỗ trợ `page` / `limit` |

### Chức năng nâng cao (Core)

| STT | Chức năng | Mô tả |
|-----|-----------|-------|
| 1 | Nhắc nhở (Notification) | Nhắc trước giờ học 15–30 phút |
| 2 | Phân loại môn học | Phân loại theo màu sắc và tag |
| 3 | Tìm kiếm / Lọc | Lọc theo môn học hoặc theo ngày |
| 4 | Thống kê đơn giản | Số buổi học trong tuần |
| 5 | Dark mode | Tùy chọn giao diện sáng / tối |
| 6 | Lịch thi / Deadline | Hỗ trợ 3 loại sự kiện: buổi học / thi / deadline |
| 7 | Điểm danh (Attendance Tracking) | Đánh dấu có mặt / vắng / trễ từng buổi, xem thống kê tỷ lệ |
| 8 | Refresh Token | Tự động làm mới access token khi hết hạn, không bắt đăng nhập lại |
| 9 | Export lịch (ICS) | Xuất lịch học ra file `.ics`, nhập vào Google Calendar / Apple Calendar |
| 10 | Swagger API Docs | Tài liệu API tự động sinh, hỗ trợ test trực tiếp tại `/api/docs` |

---

## Kiến trúc hệ thống

```
Flutter App  →  REST API (NestJS)  →  Database (MySQL / PostgreSQL)
```

```
┌─────────────────┐        ┌──────────────────────┐        ┌─────────────────┐
│   Flutter App   │  HTTP  │   NestJS Backend      │  ORM   │   Database      │
│                 │ ──────▶│                        │ ──────▶│  MySQL/Postgres │
│  - UI/UX        │        │  - REST API            │        │                 │
│  - State Mgmt   │        │  - JWT Auth            │        │  - users        │
│  - Local Notif  │        │  - Business Logic      │        │  - courses      │
└─────────────────┘        └──────────────────────┘        │  - schedules    │
                                                            └─────────────────┘
```

---

## Cấu trúc dự án

```
CourseTracker/
├── app/                          # Flutter Frontend
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/              # Các màn hình
│   │   │   ├── splash_screen.dart
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── home/
│   │   │   │   └── home_screen.dart
│   │   │   ├── courses/
│   │   │   │   ├── course_list_screen.dart
│   │   │   │   └── course_form_screen.dart
│   │   │   ├── schedules/
│   │   │   │   ├── schedule_screen.dart
│   │   │   │   └── schedule_form_screen.dart
│   │   │   └── attendance/
│   │   │       └── attendance_screen.dart
│   │   ├── models/               # Data models
│   │   │   ├── user.dart
│   │   │   ├── course.dart
│   │   │   ├── schedule.dart
│   │   │   └── attendance.dart
│   │   ├── services/             # API services
│   │   │   ├── api_service.dart
│   │   │   ├── auth_service.dart
│   │   │   ├── course_service.dart
│   │   │   ├── schedule_service.dart
│   │   │   └── attendance_service.dart
│   │   ├── providers/            # State management
│   │   └── widgets/              # Reusable widgets
│   ├── pubspec.yaml
│   └── README.md
│
├── backend/                      # NestJS Backend
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── auth/                 # Module Auth
│   │   │   ├── auth.module.ts
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   └── strategies/
│   │   │       └── jwt.strategy.ts
│   │   ├── courses/              # Module Course
│   │   │   ├── courses.module.ts
│   │   │   ├── courses.controller.ts
│   │   │   ├── courses.service.ts
│   │   │   └── entities/
│   │   │       └── course.entity.ts
│   │   ├── schedules/            # Module Schedule
│   │   │   ├── schedules.module.ts
│   │   │   ├── schedules.controller.ts
│   │   │   ├── schedules.service.ts
│   │   │   └── entities/
│   │   │       └── schedule.entity.ts
│   │   ├── attendances/          # Module Attendance
│   │   │   ├── attendances.module.ts
│   │   │   ├── attendances.controller.ts
│   │   │   ├── attendances.service.ts
│   │   │   └── entities/
│   │   │       └── attendance.entity.ts
│   │   └── users/                # Module User
│   │       ├── users.module.ts
│   │       ├── users.service.ts
│   │       └── entities/
│   │           └── user.entity.ts
│   ├── .env
│   ├── .env.example
│   ├── package.json
│   └── README.md
│
└── README.md                     # File này
```

---

## Công nghệ sử dụng

### Frontend – Flutter

| Package | Mục đích |
|---------|----------|
| `flutter` | Framework UI đa nền tảng |
| `dio` | HTTP client gọi REST API |
| `flutter_secure_storage` | Lưu JWT / Refresh token an toàn |
| `table_calendar` | Hiển thị lịch dạng Calendar |
| `flutter_local_notifications` | Nhắc nhở thông báo cục bộ |
| `provider` / `riverpod` | Quản lý trạng thái (state management) |
| `open_file` + `path_provider` | Mở file `.ics` sau khi export lịch |

### Backend – NestJS

| Package | Mục đích |
|---------|----------|
| `@nestjs/core` | Framework backend Node.js |
| `@nestjs/jwt` | Tạo và xác thực JWT token |
| `@nestjs/passport` | Middleware xác thực |
| `@nestjs/swagger` | Tự động sinh Swagger API docs |
| `@nestjs/throttler` | Rate limiting, chống brute-force login |
| `typeorm` / `prisma` | ORM kết nối database |
| `bcrypt` | Mã hoá mật khẩu |
| `class-validator` | Validate dữ liệu đầu vào |
| `ical-generator` | Tạo file `.ics` để export lịch |

### Database

- **MySQL** hoặc **PostgreSQL**

---

## Thiết kế Database

### Bảng `users`

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT (PK) | Khoá chính, tự tăng |
| `email` | VARCHAR(255) | Unique, không null |
| `password` | VARCHAR(255) | Đã được mã hoá (bcrypt) || `refresh_token` | VARCHAR(512) | Lưu refresh token hiện tại (nullable) || `created_at` | TIMESTAMP | Thời gian tạo |

### Bảng `courses`

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT (PK) | Khoá chính, tự tăng |
| `name` | VARCHAR(255) | Tên môn học |
| `teacher` | VARCHAR(255) | Tên giảng viên |
| `room` | VARCHAR(100) | Phòng học |
| `color` | VARCHAR(20) | Màu phân loại (nâng cao) |
| `tag` | VARCHAR(100) | Tag phân loại (nâng cao) |
| `user_id` | INT (FK) | Khoá ngoại → `users.id` |
| `created_at` | TIMESTAMP | Thời gian tạo |

### Bảng `schedules`

| Cột | Kiểu | Ghi chú |
|-----|------|---------|
| `id` | INT (PK) | Khoá chính, tự tăng |
| `course_id` | INT (FK) | Khoá ngoại → `courses.id` |
| `type` | ENUM | `class` / `exam` / `deadline` |
| `date` | DATE | Ngày học cụ thể (nếu không lặp) |
| `day_of_week` | TINYINT | Thứ trong tuần (0=CN, 1=T2…) |
| `start_time` | TIME | Giờ bắt đầu |
| `end_time` | TIME | Giờ kết thúc |
| `repeat` | BOOLEAN | Lịch lặp hàng tuần hay không |
| `created_at` | TIMESTAMP | Thời gian tạo |

### Bảng `attendances`

| Cột | Kiểu | Ghi chú |
|-----|------|--------|
| `id` | INT (PK) | Khoá chính, tự tăng |
| `schedule_id` | INT (FK) | Khoá ngoại → `schedules.id` |
| `user_id` | INT (FK) | Khoá ngoại → `users.id` |
| `date` | DATE | Ngày điểm danh cụ thể |
| `status` | ENUM | `present` / `absent` / `late` |
| `note` | TEXT | Ghi chú (nullable) |
| `created_at` | TIMESTAMP | Thời gian tạo |

### Quan hệ

```
users (1) ──── (N) courses (1) ──── (N) schedules
                                          │
users (1) ──────────────────────── (N) attendances
schedules (1) ────────────────── (N) attendances
```

---

## API Endpoints

Base URL: `http://localhost:3000/api`  
Swagger UI: `http://localhost:3000/api/docs`

### Auth

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| POST | `/auth/register` | Đăng ký tài khoản | Không |
| POST | `/auth/login` | Đăng nhập, trả về access token + refresh token | Không |
| POST | `/auth/logout` | Đăng xuất, xoá refresh token | JWT |
| POST | `/auth/refresh` | Làm mới access token bằng refresh token | Không |

### Courses

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/courses?page=1&limit=10` | Lấy danh sách môn học (phân trang) | JWT |
| POST | `/courses` | Thêm môn học mới | JWT |
| PUT | `/courses/:id` | Cập nhật môn học | JWT |
| DELETE | `/courses/:id` | Xoá môn học | JWT |

### Schedules

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/schedules?page=1&limit=10` | Lấy danh sách lịch học (phân trang) | JWT |
| GET | `/schedules?type=exam` | Lọc theo loại: `class` / `exam` / `deadline` | JWT |
| POST | `/schedules` | Thêm lịch học mới | JWT |
| POST | `/schedules/check-conflict` | Kiểm tra trùng lịch trước khi thêm/sửa | JWT |
| PUT | `/schedules/:id` | Cập nhật lịch học | JWT |
| DELETE | `/schedules/:id` | Xoá lịch học | JWT |
| GET | `/schedules/export` | Xuất toàn bộ lịch ra file `.ics` | JWT |

### Attendances

| Method | Endpoint | Mô tả | Auth |
|--------|----------|-------|------|
| GET | `/attendances?scheduleId=1` | Lấy danh sách điểm danh theo lịch | JWT |
| POST | `/attendances` | Thêm / cập nhật điểm danh một buổi | JWT |
| GET | `/attendances/stats` | Thống kê tỷ lệ tham dự theo môn học | JWT |

### Ví dụ Request/Response

**POST /auth/login**
```json
// Request
{
  "email": "sinhvien@example.com",
  "password": "matkhau123"
}

// Response 200
{
  "access_token": "eyJhbGci...",
  "refresh_token": "eyJhbGci..."
}
```

**POST /courses**
```json
// Request (Header: Authorization: Bearer <token>)
{
  "name": "Lập trình Web",
  "teacher": "Nguyễn Văn A",
  "room": "B201"
}

// Response 201
{
  "id": 1,
  "name": "Lập trình Web",
  "teacher": "Nguyễn Văn A",
  "room": "B201",
  "user_id": 5
}
```

---

## Hướng dẫn cài đặt & chạy dự án

### Yêu cầu môi trường

- **Flutter SDK** >= 3.0
- **Node.js** >= 18.x
- **MySQL** hoặc **PostgreSQL**
- **Android Studio** / **VS Code** với Flutter extension

### 1. Clone dự án

```bash
git clone <repository-url>
cd CourseTracker
```

### 2. Cài đặt Backend

```bash
cd backend

# Cài đặt dependencies
npm install

# Tạo file .env từ mẫu
cp .env.example .env
# Chỉnh sửa .env: DB_HOST, DB_PORT, DB_USER, DB_PASS, DB_NAME, JWT_SECRET

# Chạy migration database
npm run migration:run

# Khởi động server (development)
npm run start:dev
```

Backend sẽ chạy tại: `http://localhost:3000`

### 3. Cài đặt Flutter App

```bash
cd app

# Cài đặt packages
flutter pub get

# Chạy ứng dụng (kết nối thiết bị/giả lập trước)
flutter run
```

> **Lưu ý:** Mở file `lib/services/api_service.dart` và cập nhật `baseUrl` nếu cần. Khi chạy trên Android Emulator, dùng `http://10.0.2.2:3000/api` thay vì `localhost`.

---

## Tiến độ thực hiện

| Tuần | Nội dung | Trạng thái |
|------|----------|------------|
| Tuần 1 | Phân tích yêu cầu, thiết kế database, mock UI | Chưa bắt đầu |
| Tuần 2 | Setup NestJS, Auth (login/register), CRUD môn học | Chưa bắt đầu |
| Tuần 3 | Flutter UI login, gọi API, hiển thị môn học | Chưa bắt đầu |
| Tuần 4 | CRUD lịch học, Calendar UI | Chưa bắt đầu |
| Tuần 5 | Notification, tìm kiếm / lọc | Chưa bắt đầu |
| Tuần 6 | Test, fix bug, viết báo cáo | Chưa bắt đầu |

---

## Phân công nhóm

| Thành viên | Vai trò | Nhiệm vụ |
|------------|---------|----------|
| Thành viên 1 | Frontend Flutter | UI đăng nhập, UI lịch học, Calendar UI, gọi API |
| Thành viên 2 | Backend NestJS | Xây dựng API, Authentication (JWT), CRUD môn học & lịch học |
| Thành viên 3 | Database + API Integration | Thiết kế database, test API (Postman), kết nối frontend-backend |
| Thành viên 4 | UI/UX + Notification | Thiết kế UI (Figma), push notification, tối ưu UX |

---

> Dự án được thực hiện nhằm mục đích học tập môn **Lập trình Di động** / **Phát triển Ứng dụng**.
>>>>>>> 3b49d81 (init)
>>>>>>> 4134430 (init)
