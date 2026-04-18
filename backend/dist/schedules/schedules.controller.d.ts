import { Response } from 'express';
import { SchedulesService } from './schedules.service';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import { UpdateScheduleDto } from './dto/update-schedule.dto';
import { CheckConflictDto } from './dto/check-conflict.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { ScheduleType } from './entities/schedule.entity';
export declare class SchedulesController {
    private schedulesService;
    constructor(schedulesService: SchedulesService);
    findAll(userId: number, query: PaginationQueryDto & {
        type?: ScheduleType;
    }): Promise<{
        data: import("./entities/schedule.entity").Schedule[];
        total: number;
        page: number;
        limit: number;
        totalPages: number;
    }>;
    exportIcs(userId: number, res: Response): Promise<void>;
    findOne(id: number, userId: number): Promise<import("./entities/schedule.entity").Schedule>;
    create(userId: number, dto: CreateScheduleDto): Promise<import("./entities/schedule.entity").Schedule>;
    checkConflict(userId: number, dto: CheckConflictDto): Promise<{
        hasConflict: boolean;
        conflicts: import("./entities/schedule.entity").Schedule[];
    }>;
    update(id: number, userId: number, dto: UpdateScheduleDto): Promise<import("./entities/schedule.entity").Schedule>;
    remove(id: number, userId: number): Promise<{
        message: string;
    }>;
}
