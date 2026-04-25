import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Attendance } from './entities/attendance.entity';
import { CreateAttendanceDto } from './dto/create-attendance.dto';

@Injectable()
export class AttendancesService {
  constructor(
    @InjectRepository(Attendance)
    private attendancesRepository: Repository<Attendance>,
  ) {}

  async findBySchedule(scheduleId: number, userId: number) {
    return this.attendancesRepository.find({
      where: { scheduleId, userId },
      order: { date: 'DESC' },
    });
  }

  async createOrUpdate(userId: number, dto: CreateAttendanceDto) {
    // Check if attendance already exists for this schedule+date+user
    let attendance = await this.attendancesRepository.findOne({
      where: { scheduleId: dto.schedule_id, userId, date: dto.date },
    });

    if (attendance) {
      attendance.status = dto.status;
      attendance.note = dto.note || null;
    } else {
      attendance = this.attendancesRepository.create({
        scheduleId: dto.schedule_id,
        userId,
        date: dto.date,
        status: dto.status,
        note: dto.note || null,
      });
    }

    return this.attendancesRepository.save(attendance);
  }

  async getStats(userId: number) {
    const results = await this.attendancesRepository
      .createQueryBuilder('attendance')
      .leftJoin('attendance.schedule', 'schedule')
      .leftJoin('schedule.course', 'course')
      .select('course.id', 'courseId')
      .addSelect('course.name', 'courseName')
      .addSelect('COUNT(*)', 'total')
      .addSelect("SUM(CASE WHEN attendance.status = 'present' THEN 1 ELSE 0 END)", 'present')
      .addSelect("SUM(CASE WHEN attendance.status = 'absent' THEN 1 ELSE 0 END)", 'absent')
      .addSelect("SUM(CASE WHEN attendance.status = 'late' THEN 1 ELSE 0 END)", 'late')
      .where('attendance.user_id = :userId', { userId })
      .groupBy('course.id')
      .addGroupBy('course.name')
      .getRawMany();

    return results.map((r) => ({
      courseId: parseInt(r.courseId),
      courseName: r.courseName,
      total: parseInt(r.total),
      present: parseInt(r.present),
      absent: parseInt(r.absent),
      late: parseInt(r.late),
      attendanceRate: r.total > 0 ? Math.round(((parseInt(r.present) + parseInt(r.late)) / parseInt(r.total)) * 100) : 0,
    }));
  }
}
