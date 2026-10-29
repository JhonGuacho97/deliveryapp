import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  ArrayMaxSize,
  IsArray,
  IsNumber,
  IsString,
  Max,
  Min,
  Matches,
  ValidateNested,
} from 'class-validator';
import { Product } from '../../../admin/product/entities/product.entity';

export class CreatePaymentDto {
  @IsNumber({ maxDecimalPlaces: 2 })
  @Min(1)
  @Max(10000)
  money: number;

  @IsString()
  @Matches(/^[a-zA-Z]{3}$/)
  currency: string;

  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(100)
  @ValidateNested()
  @Type(() => Product)
  products: JSON;
}
