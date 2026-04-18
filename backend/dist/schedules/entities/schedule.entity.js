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
Object.defineProperty(exports, "__esModule", { value: true });
exports.Schedule = exports.ScheduleType = void 0;
const typeorm_1 = require("typeorm");
const course_entity_1 = require("../../courses/entities/course.entity");
const attendance_entity_1 = require("../../attendances/entities/attendance.entity");
var ScheduleType;
(function (ScheduleType) {
    ScheduleType["CLASS"] = "class";
    ScheduleType["EXAM"] = "exam";
    ScheduleType["DEADLINE"] = "deadline";
})(ScheduleType || (exports.ScheduleType = ScheduleType = {}));
let Schedule = class Schedule {
};
exports.Schedule = Schedule;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)(),
    __metadata("design:type", Number)
], Schedule.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'course_id' }),
    __metadata("design:type", Number)
], Schedule.prototype, "courseId", void 0);
__decorate([
    (0, typeorm_1.ManyToOne)(() => course_entity_1.Course, (course) => course.schedules, { onDelete: 'CASCADE' }),
    (0, typeorm_1.JoinColumn)({ name: 'course_id' }),
    __metadata("design:type", course_entity_1.Course)
], Schedule.prototype, "course", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'enum', enum: ScheduleType, default: ScheduleType.CLASS }),
    __metadata("design:type", String)
], Schedule.prototype, "type", void 0);
__decorate([
    (0, typeorm_1.Column)({ type: 'date', nullable: true }),
    __metadata("design:type", String)
], Schedule.prototype, "date", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'day_of_week', type: 'tinyint', nullable: true }),
    __metadata("design:type", Number)
], Schedule.prototype, "dayOfWeek", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'start_time', type: 'time' }),
    __metadata("design:type", String)
], Schedule.prototype, "startTime", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'end_time', type: 'time' }),
    __metadata("design:type", String)
], Schedule.prototype, "endTime", void 0);
__decorate([
    (0, typeorm_1.Column)({ name: 'repeat', default: false }),
    __metadata("design:type", Boolean)
], Schedule.prototype, "isRepeat", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => attendance_entity_1.Attendance, (attendance) => attendance.schedule),
    __metadata("design:type", Array)
], Schedule.prototype, "attendances", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)({ name: 'created_at' }),
    __metadata("design:type", Date)
], Schedule.prototype, "createdAt", void 0);
exports.Schedule = Schedule = __decorate([
    (0, typeorm_1.Entity)('schedules')
], Schedule);
//# sourceMappingURL=schedule.entity.js.map