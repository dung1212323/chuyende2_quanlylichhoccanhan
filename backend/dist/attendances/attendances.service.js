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
exports.AttendancesService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const attendance_entity_1 = require("./entities/attendance.entity");
let AttendancesService = class AttendancesService {
    constructor(attendancesRepository) {
        this.attendancesRepository = attendancesRepository;
    }
    async findBySchedule(scheduleId, userId) {
        return this.attendancesRepository.find({
            where: { scheduleId, userId },
            order: { date: 'DESC' },
        });
    }
    async createOrUpdate(userId, dto) {
        let attendance = await this.attendancesRepository.findOne({
            where: { scheduleId: dto.schedule_id, userId, date: dto.date },
        });
        if (attendance) {
            attendance.status = dto.status;
            attendance.note = dto.note || null;
        }
        else {
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
    async getStats(userId) {
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
};
exports.AttendancesService = AttendancesService;
exports.AttendancesService = AttendancesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(attendance_entity_1.Attendance)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], AttendancesService);
//# sourceMappingURL=attendances.service.js.map