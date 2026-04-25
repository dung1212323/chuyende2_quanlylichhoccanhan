import { IsOptional, IsString, IsInt } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CheckConflictDto {
  @ApiPropertyOptional({ example: '2024-03-25' })
  @IsOptional()
  @IsString()
  date?: string;

  @ApiPropertyOptional({ example: 2 })
  @IsOptional()
  @IsInt()
  day_of_week?: number;

  @ApiProperty({ example: '08:00' })
  @IsString()
  start_time: string;

  @ApiProperty({ example: '10:00' })
  @IsString()
  end_time: string;

  @ApiPropertyOptional({ description: 'Schedule ID to exclude (for update)' })
  @IsOptional()
  @IsInt()
  exclude_id?: number;
}
