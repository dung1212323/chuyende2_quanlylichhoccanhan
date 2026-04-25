import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, ParseIntPipe, Res, Header } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { Response } from 'express';
import { SchedulesService } from './schedules.service';
import { CreateScheduleDto } from './dto/create-schedule.dto';
import { UpdateScheduleDto } from './dto/update-schedule.dto';
import { CheckConflictDto } from './dto/check-conflict.dto';
import { PaginationQueryDto } from '../common/dto/pagination-query.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../common/decorators/get-user.decorator';
import { ScheduleType } from './entities/schedule.entity';

@ApiTags('Schedules')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('schedules')
export class SchedulesController {
  constructor(private schedulesService: SchedulesService) {}

  @Get()
  @ApiOperation({ summary: 'Lấy danh sách lịch học (phân trang, lọc theo loại)' })
  @ApiQuery({ name: 'type', required: false, enum: ScheduleType })
  findAll(
    @GetUser('id') userId: number,
    @Query() query: PaginationQueryDto & { type?: ScheduleType },
  ) {
    return this.schedulesService.findAll(userId, query);
  }

  @Get('export')
  @ApiOperation({ summary: 'Xuất lịch ra file ICS' })
  async exportIcs(@GetUser('id') userId: number, @Res() res: Response) {
    const icsContent = await this.schedulesService.exportIcs(userId);
    res.set({
      'Content-Type': 'text/calendar; charset=utf-8',
      'Content-Disposition': 'attachment; filename="course-tracker.ics"',
    });
    res.send(icsContent);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Lấy chi tiết lịch học' })
  findOne(@Param('id', ParseIntPipe) id: number, @GetUser('id') userId: number) {
    return this.schedulesService.findOne(id, userId);
  }

  @Post()
  @ApiOperation({ summary: 'Thêm lịch học mới' })
  create(@GetUser('id') userId: number, @Body() dto: CreateScheduleDto) {
    return this.schedulesService.create(userId, dto);
  }

  @Post('check-conflict')
  @ApiOperation({ summary: 'Kiểm tra trùng lịch' })
  checkConflict(@GetUser('id') userId: number, @Body() dto: CheckConflictDto) {
    return this.schedulesService.checkConflict(userId, dto);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Cập nhật lịch học' })
  update(@Param('id', ParseIntPipe) id: number, @GetUser('id') userId: number, @Body() dto: UpdateScheduleDto) {
    return this.schedulesService.update(id, userId, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Xoá lịch học' })
  remove(@Param('id', ParseIntPipe) id: number, @GetUser('id') userId: number) {
    return this.schedulesService.remove(id, userId);
  }
}
