import { Course } from '../../courses/entities/course.entity';
import { Attendance } from '../../attendances/entities/attendance.entity';
export declare class User {
    id: number;
    email: string;
    password: string;
    refreshToken: string;
    createdAt: Date;
    courses: Course[];
    attendances: Attendance[];
}
