import { IsString, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateCourseDto {
  @ApiProperty({ example: 'Lập trình Web' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ example: 'Nguyễn Văn A' })
  @IsOptional()
  @IsString()
  teacher?: string;

  @ApiPropertyOptional({ example: 'B201' })
  @IsOptional()
  @IsString()
  room?: string;

  @ApiPropertyOptional({ example: '#4CAF50' })
  @IsOptional()
  @IsString()
  color?: string;

  @ApiPropertyOptional({ example: 'Chuyên ngành' })
  @IsOptional()
  @IsString()
  tag?: string;
}
