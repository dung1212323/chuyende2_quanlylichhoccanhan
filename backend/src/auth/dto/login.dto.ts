import { IsEmail, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ example: 'sinhvien@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'matkhau123' })
  @IsString()
  password: string;
}
