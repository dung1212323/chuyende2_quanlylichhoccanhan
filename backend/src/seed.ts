import 'reflect-metadata';
import { DataSource } from 'typeorm';
import * as bcrypt from 'bcrypt';
import { User } from './users/entities/user.entity';
import { Course } from './courses/entities/course.entity';
import { Schedule, ScheduleType } from './schedules/entities/schedule.entity';
import { Attendance, AttendanceStatus } from './attendances/entities/attendance.entity';
import * as dotenv from 'dotenv';
dotenv.config();

const AppDataSource = new DataSource({
  type: 'mysql',
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT, 10) || 3306,
  username: process.env.DB_USERNAME || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'course_tracker',
  entities: [User, Course, Schedule, Attendance],
  synchronize: false,
});

async function seed() {
  await AppDataSource.initialize();
  console.log('Đã kết nối database...');

  // Xóa dữ liệu cũ theo thứ tự FK
  await AppDataSource.query('DELETE FROM attendances');
  await AppDataSource.query('DELETE FROM schedules');
  await AppDataSource.query('DELETE FROM courses');
  await AppDataSource.query('DELETE FROM users');
  console.log('Đã xóa dữ liệu cũ.');

  // ── Tạo user mẫu ─────────────────────────────────────────────
  const hashedPassword = await bcrypt.hash('password123', 10);
  const userRepo = AppDataSource.getRepository(User);

  const user = userRepo.create({
    email: 'sinhvien@eaut.edu.vn',
    password: hashedPassword,
  });
  await userRepo.save(user);
  console.log(`Đã tạo user: ${user.email}`);

  // ── Tạo môn học (Ngành CNTT - Học kỳ 2, năm 3) ──────────────
  // Trường ĐHCNĐA - Khoa Công nghệ Thông tin
  const courseRepo = AppDataSource.getRepository(Course);

  const coursesData = [
    {
      name: 'Lập trình Web',
      teacher: 'ThS. Nguyễn Văn Nam',
      room: 'A204',
      color: '#1E88E5',
      tag: 'CNTT',
    },
    {
      name: 'Cơ sở dữ liệu nâng cao',
      teacher: 'TS. Trần Thị Lan',
      room: 'B301',
      color: '#43A047',
      tag: 'CNTT',
    },
    {
      name: 'Mạng máy tính',
      teacher: 'ThS. Phạm Quốc Hùng',
      room: 'Lab C102',
      color: '#FB8C00',
      tag: 'CNTT',
    },
    {
      name: 'Trí tuệ nhân tạo',
      teacher: 'TS. Lê Minh Tuấn',
      room: 'A305',
      color: '#8E24AA',
      tag: 'CNTT',
    },
    {
      name: 'Công nghệ phần mềm',
      teacher: 'ThS. Đỗ Thị Hoa',
      room: 'B205',
      color: '#E53935',
      tag: 'CNTT',
    },
    {
      name: 'Kiến trúc máy tính',
      teacher: 'ThS. Hoàng Văn Đức',
      room: 'A101',
      color: '#00ACC1',
      tag: 'CNTT',
    },
  ];

  const courses: Course[] = [];
  for (const c of coursesData) {
    const course = courseRepo.create({ ...c, userId: user.id });
    await courseRepo.save(course);
    courses.push(course);
  }
  console.log(`Đã tạo ${courses.length} môn học.`);

  // ── Tạo lịch học (tkb cố định hàng tuần) ────────────────────
  // dayOfWeek: 1=Thứ 2, 2=Thứ 3, 3=Thứ 4, 4=Thứ 5, 5=Thứ 6
  const scheduleRepo = AppDataSource.getRepository(Schedule);

  const weeklySchedules = [
    // Lập trình Web - Thứ 2 & Thứ 4
    { courseIdx: 0, dayOfWeek: 1, startTime: '07:30', endTime: '09:10' },
    { courseIdx: 0, dayOfWeek: 3, startTime: '07:30', endTime: '09:10' },
    // Cơ sở dữ liệu nâng cao - Thứ 2 & Thứ 5
    { courseIdx: 1, dayOfWeek: 1, startTime: '09:20', endTime: '11:00' },
    { courseIdx: 1, dayOfWeek: 4, startTime: '13:00', endTime: '14:40' },
    // Mạng máy tính - Thứ 3 & Thứ 6
    { courseIdx: 2, dayOfWeek: 2, startTime: '07:30', endTime: '09:10' },
    { courseIdx: 2, dayOfWeek: 5, startTime: '07:30', endTime: '09:10' },
    // Trí tuệ nhân tạo - Thứ 3 & Thứ 5
    { courseIdx: 3, dayOfWeek: 2, startTime: '13:00', endTime: '14:40' },
    { courseIdx: 3, dayOfWeek: 4, startTime: '07:30', endTime: '09:10' },
    // Công nghệ phần mềm - Thứ 4 & Thứ 6
    { courseIdx: 4, dayOfWeek: 3, startTime: '13:00', endTime: '14:40' },
    { courseIdx: 4, dayOfWeek: 5, startTime: '13:00', endTime: '14:40' },
    // Kiến trúc máy tính - Thứ 2
    { courseIdx: 5, dayOfWeek: 1, startTime: '14:50', endTime: '16:30' },
    { courseIdx: 5, dayOfWeek: 3, startTime: '09:20', endTime: '11:00' },
  ];

  const schedules: Schedule[] = [];
  for (const s of weeklySchedules) {
    const schedule = scheduleRepo.create({
      courseId: courses[s.courseIdx].id,
      type: ScheduleType.CLASS,
      dayOfWeek: s.dayOfWeek,
      startTime: s.startTime,
      endTime: s.endTime,
      isRepeat: true,
    });
    await scheduleRepo.save(schedule);
    schedules.push(schedule);
  }

  // ── Lịch thi cuối kỳ ────────────────────────────────────────
  const exams = [
    { courseIdx: 0, date: '2026-06-10', startTime: '07:30', endTime: '09:10' },
    { courseIdx: 1, date: '2026-06-12', startTime: '09:30', endTime: '11:30' },
    { courseIdx: 2, date: '2026-06-15', startTime: '07:30', endTime: '09:10' },
    { courseIdx: 3, date: '2026-06-17', startTime: '13:00', endTime: '15:00' },
    { courseIdx: 4, date: '2026-06-19', startTime: '07:30', endTime: '09:10' },
    { courseIdx: 5, date: '2026-06-22', startTime: '09:30', endTime: '11:30' },
  ];
  for (const e of exams) {
    const exam = scheduleRepo.create({
      courseId: courses[e.courseIdx].id,
      type: ScheduleType.EXAM,
      date: e.date,
      startTime: e.startTime,
      endTime: e.endTime,
      isRepeat: false,
    });
    await scheduleRepo.save(exam);
    schedules.push(exam);
  }

  // ── Deadline nộp bài ────────────────────────────────────────
  const deadlines = [
    { courseIdx: 0, date: '2026-05-05', startTime: '23:59', endTime: '23:59' },
    { courseIdx: 1, date: '2026-05-10', startTime: '23:59', endTime: '23:59' },
    { courseIdx: 3, date: '2026-05-15', startTime: '23:59', endTime: '23:59' },
    { courseIdx: 4, date: '2026-05-20', startTime: '23:59', endTime: '23:59' },
  ];
  for (const d of deadlines) {
    const deadline = scheduleRepo.create({
      courseId: courses[d.courseIdx].id,
      type: ScheduleType.DEADLINE,
      date: d.date,
      startTime: d.startTime,
      endTime: d.endTime,
      isRepeat: false,
    });
    await scheduleRepo.save(deadline);
    schedules.push(deadline);
  }

  console.log(`Đã tạo ${schedules.length} lịch (học định kỳ + thi + deadline).`);

  // ── Tạo điểm danh mẫu (4 tuần gần đây) ─────────────────────
  const attendanceRepo = AppDataSource.getRepository(Attendance);
  // Chỉ tạo attendance cho các lịch học có isRepeat
  const repeatSchedules = schedules.filter((s) => s.isRepeat);

  const today = new Date('2026-04-11');
  let attCount = 0;
  for (const sched of repeatSchedules) {
    for (let weekOffset = 3; weekOffset >= 0; weekOffset--) {
      // Tìm ngày gần nhất trong 4 tuần qua khớp dayOfWeek
      const targetDow = sched.dayOfWeek === 0 ? 7 : sched.dayOfWeek; // convert: 0=Sun→7
      const todayDow = today.getDay() === 0 ? 7 : today.getDay();
      let diff = todayDow - targetDow - weekOffset * 7;
      if (diff < 0) continue;
      const classDate = new Date(today);
      classDate.setDate(today.getDate() - diff);
      const dateStr = classDate.toISOString().split('T')[0];

      // Mô phỏng: 80% có mặt, 10% muộn, 10% vắng
      const rand = Math.random();
      const status =
        rand < 0.8
          ? AttendanceStatus.PRESENT
          : rand < 0.9
            ? AttendanceStatus.LATE
            : AttendanceStatus.ABSENT;

      const note =
        status === AttendanceStatus.ABSENT
          ? 'Có việc bận'
          : status === AttendanceStatus.LATE
            ? 'Đến muộn 10 phút'
            : null;

      const att = attendanceRepo.create({
        scheduleId: sched.id,
        userId: user.id,
        date: dateStr,
        status,
        note,
      });
      await attendanceRepo.save(att);
      attCount++;
    }
  }
  console.log(`Đã tạo ${attCount} bản ghi điểm danh mẫu.`);

  await AppDataSource.destroy();
  console.log('\n=== SEED HOÀN TẤT ===');
  console.log('Tài khoản đăng nhập:');
  console.log('  Email   : sinhvien@eaut.edu.vn');
  console.log('  Password: password123');
}

seed().catch((err) => {
  console.error('Seed thất bại:', err);
  process.exit(1);
});
