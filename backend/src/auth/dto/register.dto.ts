import { IsEmail, IsString, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'sinhvien@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'matkhau123', minLength: 6 })
  @IsString()
  @MinLength(6)
  password: string;
}
