import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Course } from './entities/course.entity';
import { CreateCourseDto } from './dto/create-course.dto';
import { UpdateCourseDto } from './dto/update-course.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';

@Injectable()
export class CoursesService {
  constructor(
    @InjectRepository(Course)
    private coursesRepository: Repository<Course>,
  ) {}

  async findAll(userId: number, query: PaginationQueryDto) {
    const { page, limit } = query;
    const [data, total] = await this.coursesRepository.findAndCount({
      where: { userId },
      order: { createdAt: 'DESC' },
      skip: (page - 1) * limit,
      take: limit,
    });
    return {
      data,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async findOne(id: number, userId: number) {
    const course = await this.coursesRepository.findOne({ where: { id, userId } });
    if (!course) throw new NotFoundException('Không tìm thấy môn học');
    return course;
  }

  async create(userId: number, dto: CreateCourseDto) {
    const course = this.coursesRepository.create({ ...dto, userId });
    return this.coursesRepository.save(course);
  }

  async update(id: number, userId: number, dto: UpdateCourseDto) {
    const course = await this.findOne(id, userId);
    Object.assign(course, dto);
    return this.coursesRepository.save(course);
  }

  async remove(id: number, userId: number) {
    const course = await this.findOne(id, userId);
    await this.coursesRepository.remove(course);
    return { message: 'Xoá môn học thành công' };
  }
}
