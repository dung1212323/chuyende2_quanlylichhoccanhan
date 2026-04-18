import { Schedule } from '../../schedules/entities/schedule.entity';
import { User } from '../../users/entities/user.entity';
export declare enum AttendanceStatus {
    PRESENT = "present",
    ABSENT = "absent",
    LATE = "late"
}
export declare class Attendance {
    id: number;
    scheduleId: number;
    schedule: Schedule;
    userId: number;
    user: User;
    date: string;
    status: AttendanceStatus;
    note: string;
    createdAt: Date;
}
