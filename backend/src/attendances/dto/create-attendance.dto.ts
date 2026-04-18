import { IsInt, IsString, IsOptional, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { AttendanceStatus } from '../entities/attendance.entity';

export class CreateAttendanceDto {
  @ApiProperty({ example: 1 })
  @IsInt()
  schedule_id: number;

  @ApiProperty({ example: '2024-03-25' })
  @IsString()
  date: string;

  @ApiProperty({ enum: AttendanceStatus, example: AttendanceStatus.PRESENT })
  @IsEnum(AttendanceStatus)
  status: AttendanceStatus;

  @ApiPropertyOptional({ example: 'Đi muộn 5 phút' })
  @IsOptional()
  @IsString()
  note?: string;
}
