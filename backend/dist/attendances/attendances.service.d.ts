import { Repository } from 'typeorm';
import { Attendance } from './entities/attendance.entity';
import { CreateAttendanceDto } from './dto/create-attendance.dto';
export declare class AttendancesService {
    private attendancesRepository;
    constructor(attendancesRepository: Repository<Attendance>);
    findBySchedule(scheduleId: number, userId: number): Promise<Attendance[]>;
    createOrUpdate(userId: number, dto: CreateAttendanceDto): Promise<Attendance>;
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
