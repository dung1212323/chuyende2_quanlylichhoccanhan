import { CoursesService } from './courses.service';
import { CreateCourseDto } from './dto/create-course.dto';
import { UpdateCourseDto } from './dto/update-course.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
export declare class CoursesController {
    private coursesService;
    constructor(coursesService: CoursesService);
    findAll(userId: number, query: PaginationQueryDto): Promise<{
        data: import("./entities/course.entity").Course[];
        total: number;
        page: number;
        limit: number;
        totalPages: number;
    }>;
    findOne(id: number, userId: number): Promise<import("./entities/course.entity").Course>;
    create(userId: number, dto: CreateCourseDto): Promise<import("./entities/course.entity").Course>;
    update(id: number, userId: number, dto: UpdateCourseDto): Promise<import("./entities/course.entity").Course>;
    remove(id: number, userId: number): Promise<{
        message: string;
    }>;
}
