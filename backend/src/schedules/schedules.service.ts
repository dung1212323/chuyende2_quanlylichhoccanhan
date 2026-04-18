import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Schedule, ScheduleType } from './entities/schedule.entity';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import { UpdateScheduleDto } from './dto/update-schedule.dto';
import { CheckConflictDto } from './dto/check-conflict.dto';
import { CoursesService } from '../courses/courses.service';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import * as ical from 'ical-generator';

@Injectable()
export class SchedulesService {
  constructor(
    @InjectRepository(Schedule)
    private schedulesRepository: Repository<Schedule>,
    private coursesService: CoursesService,
  ) {}

  async findAll(userId: number, query: PaginationQueryDto & { type?: ScheduleType }) {
    const { page, limit, type } = query;
    const qb = this.schedulesRepository
      .createQueryBuilder('schedule')
      .leftJoinAndSelect('schedule.course', 'course')
      .where('course.user_id = :userId', { userId })
      .orderBy('schedule.id', 'DESC');

    if (type) {
      qb.andWhere('schedule.type = :type', { type });
    }

    const total = await qb.getCount();
    const data = await qb.skip((page - 1) * limit).take(limit).getMany();

    return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async findOne(id: number, userId: number) {
    const schedule = await this.schedulesRepository
      .createQueryBuilder('schedule')
      .leftJoinAndSelect('schedule.course', 'course')
      .where('schedule.id = :id', { id })
      .andWhere('course.user_id = :userId', { userId })
      .getOne();
    if (!schedule) throw new NotFoundException('Không tìm thấy lịch học');
    return schedule;
  }

  async create(userId: number, dto: CreateScheduleDto) {
    // Verify course ownership
    await this.coursesService.findOne(dto.course_id, userId);

    // Check conflict
    const conflicts = await this.checkConflictInternal(userId, {
      date: dto.date,
      day_of_week: dto.day_of_week,
      start_time: dto.start_time,
      end_time: dto.end_time,
    });
    if (conflicts.length > 0) {
      throw new ConflictException({
        message: 'Lịch bị trùng giờ với lịch đã có',
        conflicts,
      });
    }

    const schedule = this.schedulesRepository.create({
      courseId: dto.course_id,
      type: dto.type || ScheduleType.CLASS,
      date: dto.date,
      dayOfWeek: dto.day_of_week,
      startTime: dto.start_time,
      endTime: dto.end_time,
      isRepeat: dto.repeat || false,
    });
    const saved = await this.schedulesRepository.save(schedule);
    return this.findOne(saved.id, userId);
  }

  async update(id: number, userId: number, dto: UpdateScheduleDto) {
    const schedule = await this.findOne(id, userId);

    if (dto.course_id) {
      await this.coursesService.findOne(dto.course_id, userId);
    }

    // Check conflict excluding current schedule
    const conflicts = await this.checkConflictInternal(userId, {
      date: dto.date || schedule.date,
      day_of_week: dto.day_of_week !== undefined ? dto.day_of_week : schedule.dayOfWeek,
      start_time: dto.start_time || schedule.startTime,
      end_time: dto.end_time || schedule.endTime,
      exclude_id: id,
    });
    if (conflicts.length > 0) {
      throw new ConflictException({
        message: 'Lịch bị trùng giờ với lịch đã có',
        conflicts,
      });
    }

    if (dto.course_id !== undefined) schedule.courseId = dto.course_id;
    if (dto.type !== undefined) schedule.type = dto.type;
    if (dto.date !== undefined) schedule.date = dto.date;
    if (dto.day_of_week !== undefined) schedule.dayOfWeek = dto.day_of_week;
    if (dto.start_time !== undefined) schedule.startTime = dto.start_time;
    if (dto.end_time !== undefined) schedule.endTime = dto.end_time;
    if (dto.repeat !== undefined) schedule.isRepeat = dto.repeat;

    await this.schedulesRepository.save(schedule);
    return this.findOne(id, userId);
  }

  async remove(id: number, userId: number) {
    const schedule = await this.findOne(id, userId);
    await this.schedulesRepository.remove(schedule);
    return { message: 'Xoá lịch học thành công' };
  }

  async checkConflict(userId: number, dto: CheckConflictDto) {
    const conflicts = await this.checkConflictInternal(userId, dto);
    return {
      hasConflict: conflicts.length > 0,
      conflicts,
    };
  }

  private async checkConflictInternal(userId: number, dto: CheckConflictDto): Promise<Schedule[]> {
    const qb = this.schedulesRepository
      .createQueryBuilder('schedule')
      .leftJoinAndSelect('schedule.course', 'course')
      .where('course.user_id = :userId', { userId })
      .andWhere('schedule.start_time < :endTime', { endTime: dto.end_time })
      .andWhere('schedule.end_time > :startTime', { startTime: dto.start_time });

    if (dto.date) {
      qb.andWhere('(schedule.date = :date OR (schedule.repeat = true AND schedule.day_of_week = DAYOFWEEK(:date) - 1))', { date: dto.date });
    } else if (dto.day_of_week !== undefined) {
      qb.andWhere('(schedule.day_of_week = :dow OR (schedule.date IS NOT NULL AND DAYOFWEEK(schedule.date) - 1 = :dow))', { dow: dto.day_of_week });
    }

    if (dto.exclude_id) {
      qb.andWhere('schedule.id != :excludeId', { excludeId: dto.exclude_id });
    }

    return qb.getMany();
  }

  async exportIcs(userId: number) {
    const schedules = await this.schedulesRepository
      .createQueryBuilder('schedule')
      .leftJoinAndSelect('schedule.course', 'course')
      .where('course.user_id = :userId', { userId })
      .getMany();

    const calendar = ical.default({ name: 'Course Tracker - Lịch học' });

    for (const s of schedules) {
      const startDate = s.date ? new Date(s.date) : new Date();
      const [startH, startM] = s.startTime.split(':').map(Number);
      const [endH, endM] = s.endTime.split(':').map(Number);

      const start = new Date(startDate);
      start.setHours(startH, startM, 0);
      const end = new Date(startDate);
      end.setHours(endH, endM, 0);

      const typeLabel = s.type === 'exam' ? '[Thi]' : s.type === 'deadline' ? '[Deadline]' : '';
      const summary = `${typeLabel} ${s.course?.name || 'Môn học'}`.trim();

      const event = calendar.createEvent({
        start,
        end,
        summary,
        location: s.course?.room,
        description: `Giảng viên: ${s.course?.teacher || 'N/A'}`,
      });

      if (s.isRepeat && s.dayOfWeek !== null) {
        const days = ['SU', 'MO', 'TU', 'WE', 'TH', 'FR', 'SA'];
        event.repeating({
          freq: 'WEEKLY' as any,
          byDay: [days[s.dayOfWeek]] as any,
          count: 18,
        });
      }
    }

    return calendar.toString();
  }
}
