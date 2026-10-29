import { IsString, Matches } from 'class-validator';

export class UpdateHoursOperationDto {
  @IsString()
  @Matches(/^(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$/)
  open: string;

  @IsString()
  @Matches(/^(?:[01]\d|2[0-3]):[0-5]\d:[0-5]\d$/)
  close: string;
}
