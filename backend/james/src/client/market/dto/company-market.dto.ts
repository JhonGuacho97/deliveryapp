import { Type } from 'class-transformer';
import {
  IsLatitude,
  IsLongitude,
  IsNumber,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { PaginationDto } from 'src/common/dto/pagination.dto';

export class StoreMarketDto extends PaginationDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  query?: string;

  @IsLongitude()
  @Type(() => Number)
  longitude: number;

  @IsLatitude()
  @Type(() => Number)
  latitude: number;

  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  categoryId: number;
}
