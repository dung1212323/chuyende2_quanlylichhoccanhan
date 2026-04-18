import { AttendancesService } from './attendances.service';
import { CreateAttendanceDto } from './dto/create-attendance.dto';
export declare class AttendancesController {
    private attendancesService;
    constructor(attendancesService: AttendancesService);
    findBySchedule(scheduleId: number, userId: number): Promise<import("./entities/attendance.entity").Attendance[]>;
    createOrUpdate(userId: number, dto: CreateAttendanceDto): Promise<import("./entities/attendance.entity").Attendance>;
    getStats(userId: number): Promise<{
        courseId: number;
        courseName: any;
        total: number;
        present: number;
        absent: number;
        late: number;
        attendanceRate: number;
    }[]>;
}
