import { Course } from '../../courses/entities/course.entity';
import { Attendance } from '../../attendances/entities/attendance.entity';
export declare enum ScheduleType {
    CLASS = "class",
    EXAM = "exam",
    DEADLINE = "deadline"
}
export declare class Schedule {
    id: number;
    courseId: number;
    course: Course;
    type: ScheduleType;
    date: string;
    dayOfWeek: number;
    startTime: string;
    endTime: string;
    isRepeat: boolean;
    attendances: Attendance[];
    createdAt: Date;
}
