import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation } from '@nestjs/swagger';
import { CoursesService } from './courses.service';
import { CreateCourseDto } from './dto/create-course.dto';
import { UpdateCourseDto } from './dto/update-course.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../common/decorators/get-user.decorator';

@ApiTags('Courses')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('courses')
export class CoursesController {
  constructor(private coursesService: CoursesService) {}

  @Get()
  @ApiOperation({ summary: 'Lấy danh sách môn học (phân trang)' })
  findAll(@GetUser('id') userId: number, @Query() query: PaginationQueryDto) {
    return this.coursesService.findAll(userId, query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Lấy chi tiết môn học' })
  findOne(@Param('id', ParseIntPipe) id: number, @GetUser('id') userId: number) {
    return this.coursesService.findOne(id, userId);
  }

  @Post()
  @ApiOperation({ summary: 'Thêm môn học mới' })
  create(@GetUser('id') userId: number, @Body() dto: CreateCourseDto) {
    return this.coursesService.create(userId, dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Cập nhật môn học' })
  update(@Param('id', ParseIntPipe) id: number, @GetUser('id') userId: number, @Body() dto: UpdateCourseDto) {
    return this.coursesService.update(id, userId, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Xoá môn học' })
  remove(@Param('id', ParseIntPipe) id: number, @GetUser('id') userId: number) {
    return this.coursesService.remove(id, userId);
  }
}
