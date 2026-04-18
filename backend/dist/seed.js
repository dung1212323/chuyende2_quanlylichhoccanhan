"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("reflect-metadata");
const typeorm_1 = require("typeorm");
const bcrypt = require("bcrypt");
const user_entity_1 = require("./users/entities/user.entity");
const course_entity_1 = require("./courses/entities/course.entity");
const schedule_entity_1 = require("./schedules/entities/schedule.entity");
const attendance_entity_1 = require("./attendances/entities/attendance.entity");
const dotenv = require("dotenv");
dotenv.config();
const AppDataSource = new typeorm_1.DataSource({
    type: 'mysql',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 3306,
    username: process.env.DB_USERNAME || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_DATABASE || 'course_tracker',
    entities: [user_entity_1.User, course_entity_1.Course, schedule_entity_1.Schedule, attendance_entity_1.Attendance],
    synchronize: false,
});
async function seed() {
    await AppDataSource.initialize();
    console.log('Đã kết nối database...');
    await AppDataSource.query('DELETE FROM attendances');
    await AppDataSource.query('DELETE FROM schedules');
    await AppDataSource.query('DELETE FROM courses');
    await AppDataSource.query('DELETE FROM users');
    console.log('Đã xóa dữ liệu cũ.');
    const hashedPassword = await bcrypt.hash('password123', 10);
    const userRepo = AppDataSource.getRepository(user_entity_1.User);
    const user = userRepo.create({
        email: 'sinhvien@eaut.edu.vn',
        password: hashedPassword,
    });
    await userRepo.save(user);
    console.log(`Đã tạo user: ${user.email}`);
    const courseRepo = AppDataSource.getRepository(course_entity_1.Course);
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
    const courses = [];
    for (const c of coursesData) {
        const course = courseRepo.create({ ...c, userId: user.id });
        await courseRepo.save(course);
        courses.push(course);
    }
    console.log(`Đã tạo ${courses.length} môn học.`);
    const scheduleRepo = AppDataSource.getRepository(schedule_entity_1.Schedule);
    const weeklySchedules = [
        { courseIdx: 0, dayOfWeek: 1, startTime: '07:30', endTime: '09:10' },
        { courseIdx: 0, dayOfWeek: 3, startTime: '07:30', endTime: '09:10' },
        { courseIdx: 1, dayOfWeek: 1, startTime: '09:20', endTime: '11:00' },
        { courseIdx: 1, dayOfWeek: 4, startTime: '13:00', endTime: '14:40' },
        { courseIdx: 2, dayOfWeek: 2, startTime: '07:30', endTime: '09:10' },
        { courseIdx: 2, dayOfWeek: 5, startTime: '07:30', endTime: '09:10' },
        { courseIdx: 3, dayOfWeek: 2, startTime: '13:00', endTime: '14:40' },
        { courseIdx: 3, dayOfWeek: 4, startTime: '07:30', endTime: '09:10' },
        { courseIdx: 4, dayOfWeek: 3, startTime: '13:00', endTime: '14:40' },
        { courseIdx: 4, dayOfWeek: 5, startTime: '13:00', endTime: '14:40' },
        { courseIdx: 5, dayOfWeek: 1, startTime: '14:50', endTime: '16:30' },
        { courseIdx: 5, dayOfWeek: 3, startTime: '09:20', endTime: '11:00' },
    ];
    const schedules = [];
    for (const s of weeklySchedules) {
        const schedule = scheduleRepo.create({
            courseId: courses[s.courseIdx].id,
            type: schedule_entity_1.ScheduleType.CLASS,
            dayOfWeek: s.dayOfWeek,
            startTime: s.startTime,
            endTime: s.endTime,
            isRepeat: true,
        });
        await scheduleRepo.save(schedule);
        schedules.push(schedule);
    }
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
            type: schedule_entity_1.ScheduleType.EXAM,
            date: e.date,
            startTime: e.startTime,
            endTime: e.endTime,
            isRepeat: false,
        });
        await scheduleRepo.save(exam);
        schedules.push(exam);
    }
    const deadlines = [
        { courseIdx: 0, date: '2026-05-05', startTime: '23:59', endTime: '23:59' },
        { courseIdx: 1, date: '2026-05-10', startTime: '23:59', endTime: '23:59' },
        { courseIdx: 3, date: '2026-05-15', startTime: '23:59', endTime: '23:59' },
        { courseIdx: 4, date: '2026-05-20', startTime: '23:59', endTime: '23:59' },
    ];
    for (const d of deadlines) {
        const deadline = scheduleRepo.create({
            courseId: courses[d.courseIdx].id,
            type: schedule_entity_1.ScheduleType.DEADLINE,
            date: d.date,
            startTime: d.startTime,
            endTime: d.endTime,
            isRepeat: false,
        });
        await scheduleRepo.save(deadline);
        schedules.push(deadline);
    }
    console.log(`Đã tạo ${schedules.length} lịch (học định kỳ + thi + deadline).`);
    const attendanceRepo = AppDataSource.getRepository(attendance_entity_1.Attendance);
    const repeatSchedules = schedules.filter((s) => s.isRepeat);
    const today = new Date('2026-04-11');
    let attCount = 0;
    for (const sched of repeatSchedules) {
        for (let weekOffset = 3; weekOffset >= 0; weekOffset--) {
            const targetDow = sched.dayOfWeek === 0 ? 7 : sched.dayOfWeek;
            const todayDow = today.getDay() === 0 ? 7 : today.getDay();
            let diff = todayDow - targetDow - weekOffset * 7;
            if (diff < 0)
                continue;
            const classDate = new Date(today);
            classDate.setDate(today.getDate() - diff);
            const dateStr = classDate.toISOString().split('T')[0];
            const rand = Math.random();
            const status = rand < 0.8
                ? attendance_entity_1.AttendanceStatus.PRESENT
                : rand < 0.9
                    ? attendance_entity_1.AttendanceStatus.LATE
                    : attendance_entity_1.AttendanceStatus.ABSENT;
            const note = status === attendance_entity_1.AttendanceStatus.ABSENT
                ? 'Có việc bận'
                : status === attendance_entity_1.AttendanceStatus.LATE
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
//# sourceMappingURL=seed.js.map