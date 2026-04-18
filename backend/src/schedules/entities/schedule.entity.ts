import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne, OneToMany, JoinColumn } from 'typeorm';
import { Course } from '../../courses/entities/course.entity';
import { Attendance } from '../../attendances/entities/attendance.entity';

export enum ScheduleType {
  CLASS = 'class',
  EXAM = 'exam',
  DEADLINE = 'deadline',
}

@Entity('schedules')
export class Schedule {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'course_id' })
  courseId: number;

  @ManyToOne(() => Course, (course) => course.schedules, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'course_id' })
  course: Course;

  @Column({ type: 'enum', enum: ScheduleType, default: ScheduleType.CLASS })
  type: ScheduleType;

  @Column({ type: 'date', nullable: true })
  date: string;

  @Column({ name: 'day_of_week', type: 'tinyint', nullable: true })
  dayOfWeek: number;

  @Column({ name: 'start_time', type: 'time' })
  startTime: string;

  @Column({ name: 'end_time', type: 'time' })
  endTime: string;

  @Column({ name: 'repeat', default: false })
  isRepeat: boolean;

  @OneToMany(() => Attendance, (attendance) => attendance.schedule)
  attendances: Attendance[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}
