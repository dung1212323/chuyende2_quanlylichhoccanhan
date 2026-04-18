import { Repository } from 'typeorm';
import { Schedule, ScheduleType } from './entities/schedule.entity';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import { UpdateScheduleDto } from './dto/update-schedule.dto';
import { CheckConflictDto } from './dto/check-conflict.dto';
import { CoursesService } from '../courses/courses.service';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
export declare class SchedulesService {
    private schedulesRepository;
    private coursesService;
    constructor(schedulesRepository: Repository<Schedule>, coursesService: CoursesService);
    findAll(userId: number, query: PaginationQueryDto & {
        type?: ScheduleType;
    }): Promise<{
        data: Schedule[];
        total: number;
        page: number;
        limit: number;
        totalPages: number;
    }>;
    findOne(id: number, userId: number): Promise<Schedule>;
    create(userId: number, dto: CreateScheduleDto): Promise<Schedule>;
    update(id: number, userId: number, dto: UpdateScheduleDto): Promise<Schedule>;
    remove(id: number, userId: number): Promise<{
        message: string;
    }>;
    checkConflict(userId: number, dto: CheckConflictDto): Promise<{
        hasConflict: boolean;
        conflicts: Schedule[];
    }>;
    private checkConflictInternal;
    exportIcs(userId: number): Promise<string>;
}
