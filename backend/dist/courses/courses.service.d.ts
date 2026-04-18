import { Repository } from 'typeorm';
import { Course } from './entities/course.entity';
import { CreateCourseDto } from './dto/create-course.dto';
import { UpdateCourseDto } from './dto/update-course.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
export declare class CoursesService {
    private coursesRepository;
    constructor(coursesRepository: Repository<Course>);
    findAll(userId: number, query: PaginationQueryDto): Promise<{
        data: Course[];
        total: number;
        page: number;
        limit: number;
        totalPages: number;
    }>;
    findOne(id: number, userId: number): Promise<Course>;
    create(userId: number, dto: CreateCourseDto): Promise<Course>;
    update(id: number, userId: number, dto: UpdateCourseDto): Promise<Course>;
    remove(id: number, userId: number): Promise<{
        message: string;
    }>;
}
