import { User } from '../../users/entities/user.entity';
import { Schedule } from '../../schedules/entities/schedule.entity';
export declare class Course {
    id: number;
    name: string;
    teacher: string;
    room: string;
    color: string;
    tag: string;
    userId: number;
    user: User;
    schedules: Schedule[];
    createdAt: Date;
}
