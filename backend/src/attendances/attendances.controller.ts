import { Controller, Get, Post, Body, Query, UseGuards, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { AttendancesService } from './attendances.service';
import { CreateAttendanceDto } from './dto/create-attendance.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GetUser } from '../common/decorators/get-user.decorator';

@ApiTags('Attendances')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('attendances')
export class AttendancesController {
  constructor(private attendancesService: AttendancesService) {}

  @Get()
  @ApiOperation({ summary: 'Lấy danh sách điểm danh theo lịch học' })
  @ApiQuery({ name: 'scheduleId', required: true })
  findBySchedule(
    @Query('scheduleId', ParseIntPipe) scheduleId: number,
    @GetUser('id') userId: number,
  ) {
    return this.attendancesService.findBySchedule(scheduleId, userId);
  }

  @Post()
  @ApiOperation({ summary: 'Thêm/cập nhật điểm danh' })
  createOrUpdate(@GetUser('id') userId: number, @Body() dto: CreateAttendanceDto) {
    return this.attendancesService.createOrUpdate(userId, dto);
  }

  @Get('stats')
  @ApiOperation({ summary: 'Thống kê tỷ lệ tham dự theo môn học' })
  getStats(@GetUser('id') userId: number) {
    return this.attendancesService.getStats(userId);
  }
}
