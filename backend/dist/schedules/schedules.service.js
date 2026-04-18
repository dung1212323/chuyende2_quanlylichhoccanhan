"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.SchedulesService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const schedule_entity_1 = require("./entities/schedule.entity");
const courses_service_1 = require("../courses/courses.service");
const ical = require("ical-generator");
let SchedulesService = class SchedulesService {
    constructor(schedulesRepository, coursesService) {
        this.schedulesRepository = schedulesRepository;
        this.coursesService = coursesService;
    }
    async findAll(userId, query) {
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
    async findOne(id, userId) {
        const schedule = await this.schedulesRepository
            .createQueryBuilder('schedule')
            .leftJoinAndSelect('schedule.course', 'course')
            .where('schedule.id = :id', { id })
            .andWhere('course.user_id = :userId', { userId })
            .getOne();
        if (!schedule)
            throw new common_1.NotFoundException('Không tìm thấy lịch học');
        return schedule;
    }
    async create(userId, dto) {
        await this.coursesService.findOne(dto.course_id, userId);
        const conflicts = await this.checkConflictInternal(userId, {
            date: dto.date,
            day_of_week: dto.day_of_week,
            start_time: dto.start_time,
            end_time: dto.end_time,
        });
        if (conflicts.length > 0) {
            throw new common_1.ConflictException({
                message: 'Lịch bị trùng giờ với lịch đã có',
                conflicts,
            });
        }
        const schedule = this.schedulesRepository.create({
            courseId: dto.course_id,
            type: dto.type || schedule_entity_1.ScheduleType.CLASS,
            date: dto.date,
            dayOfWeek: dto.day_of_week,
            startTime: dto.start_time,
            endTime: dto.end_time,
            isRepeat: dto.repeat || false,
        });
        const saved = await this.schedulesRepository.save(schedule);
        return this.findOne(saved.id, userId);
    }
    async update(id, userId, dto) {
        const schedule = await this.findOne(id, userId);
        if (dto.course_id) {
            await this.coursesService.findOne(dto.course_id, userId);
        }
        const conflicts = await this.checkConflictInternal(userId, {
            date: dto.date || schedule.date,
            day_of_week: dto.day_of_week !== undefined ? dto.day_of_week : schedule.dayOfWeek,
            start_time: dto.start_time || schedule.startTime,
            end_time: dto.end_time || schedule.endTime,
            exclude_id: id,
        });
        if (conflicts.length > 0) {
            throw new common_1.ConflictException({
                message: 'Lịch bị trùng giờ với lịch đã có',
                conflicts,
            });
        }
        if (dto.course_id !== undefined)
            schedule.courseId = dto.course_id;
        if (dto.type !== undefined)
            schedule.type = dto.type;
        if (dto.date !== undefined)
            schedule.date = dto.date;
        if (dto.day_of_week !== undefined)
            schedule.dayOfWeek = dto.day_of_week;
        if (dto.start_time !== undefined)
            schedule.startTime = dto.start_time;
        if (dto.end_time !== undefined)
            schedule.endTime = dto.end_time;
        if (dto.repeat !== undefined)
            schedule.isRepeat = dto.repeat;
        await this.schedulesRepository.save(schedule);
        return this.findOne(id, userId);
    }
    async remove(id, userId) {
        const schedule = await this.findOne(id, userId);
        await this.schedulesRepository.remove(schedule);
        return { message: 'Xoá lịch học thành công' };
    }
    async checkConflict(userId, dto) {
        const conflicts = await this.checkConflictInternal(userId, dto);
        return {
            hasConflict: conflicts.length > 0,
            conflicts,
        };
    }
    async checkConflictInternal(userId, dto) {
        const qb = this.schedulesRepository
            .createQueryBuilder('schedule')
            .leftJoinAndSelect('schedule.course', 'course')
            .where('course.user_id = :userId', { userId })
            .andWhere('schedule.start_time < :endTime', { endTime: dto.end_time })
            .andWhere('schedule.end_time > :startTime', { startTime: dto.start_time });
        if (dto.date) {
            qb.andWhere('(schedule.date = :date OR (schedule.repeat = true AND schedule.day_of_week = DAYOFWEEK(:date) - 1))', { date: dto.date });
        }
        else if (dto.day_of_week !== undefined) {
            qb.andWhere('(schedule.day_of_week = :dow OR (schedule.date IS NOT NULL AND DAYOFWEEK(schedule.date) - 1 = :dow))', { dow: dto.day_of_week });
        }
        if (dto.exclude_id) {
            qb.andWhere('schedule.id != :excludeId', { excludeId: dto.exclude_id });
        }
        return qb.getMany();
    }
    async exportIcs(userId) {
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
                    freq: 'WEEKLY',
                    byDay: [days[s.dayOfWeek]],
                    count: 18,
                });
            }
        }
        return calendar.toString();
    }
};
exports.SchedulesService = SchedulesService;
exports.SchedulesService = SchedulesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(schedule_entity_1.Schedule)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        courses_service_1.CoursesService])
], SchedulesService);
//# sourceMappingURL=schedules.service.js.map