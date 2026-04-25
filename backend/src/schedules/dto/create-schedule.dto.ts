import { IsInt, IsOptional, IsString, IsBoolean, IsEnum } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { ScheduleType } from '../entities/schedule.entity';

export class CreateScheduleDto {
  @ApiProperty({ example: 1 })
  @IsInt()
  course_id: number;

  @ApiPropertyOptional({ enum: ScheduleType, default: ScheduleType.CLASS })
  @IsOptional()
  @IsEnum(ScheduleType)
  type?: ScheduleType;

  @ApiPropertyOptional({ example: '2024-03-25' })
  @IsOptional()
  @IsString()
  date?: string;

  @ApiPropertyOptional({ example: 2, description: '0=CN, 1=T2, 2=T3...' })
  @IsOptional()
  @IsInt()
  day_of_week?: number;

  @ApiProperty({ example: '08:00' })
  @IsString()
  start_time: string;

  @ApiProperty({ example: '10:00' })
  @IsString()
  end_time: string;

  @ApiPropertyOptional({ default: false })
  @IsOptional()
  @IsBoolean()
  repeat?: boolean;
}
