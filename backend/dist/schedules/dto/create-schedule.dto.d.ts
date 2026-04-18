import { ScheduleType } from '../entities/schedule.entity';
export declare class CreateScheduleDto {
    course_id: number;
    type?: ScheduleType;
    date?: string;
    day_of_week?: number;
    start_time: string;
    end_time: string;
    repeat?: boolean;
}
