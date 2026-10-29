import { IsNumber, IsOptional, IsPositive, Max, Min } from 'class-validator';
import { PaginationDto } from 'src/common/dto/pagination.dto';

export class CollectPetitonDto extends PaginationDto {
  @IsOptional()
  @IsPositive()
  @IsNumber()
  @Min(0)
  @Max(5)
  scoreDeliveryman?: number;
}
