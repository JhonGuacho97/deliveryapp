import { IsInt, Max, Min } from 'class-validator';

export class AcceptRequestDto {
  @IsInt()
  @Min(5)
  @Max(120)
  preparationMinutes: number;
}
