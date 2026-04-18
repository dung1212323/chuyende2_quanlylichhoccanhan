import { AttendanceStatus } from '../entities/attendance.entity';
export declare class CreateAttendanceDto {
    schedule_id: number;
    date: string;
    status: AttendanceStatus;
    note?: string;
}
