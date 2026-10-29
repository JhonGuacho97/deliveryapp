import {
  BadRequestException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { Repository } from 'typeorm';
import { InjectRepository } from '@nestjs/typeorm';
import { User } from 'src/auth/entities/user.entity';
import { Product } from 'src/admin/product/entities/product.entity';
import { CreateProductDto } from 'src/admin/product/dto/create-product.dto';
import { UpdateProductDto } from 'src/admin/product/dto/update-product.dto';
import { HoursOperation } from 'src/admin/hours-peration/entities/hours-peration.entity';
import { Store } from 'src/admin/store/entities/store.entity';
import { UpdateHoursOperationDto } from 'src/admin/hours-peration/dto/update-hours-peration.dto';
import handleDbExceptions from 'src/common/exceptions/error.db.exception';

@Injectable()
export class StoreManagerService {
  private readonly logger = new Logger(StoreManagerService.name);
  constructor(
    @InjectRepository(Store) private readonly stores: Repository<Store>,
    @InjectRepository(Product)
    private readonly productsRepository: Repository<Product>,
    @InjectRepository(HoursOperation)
    private readonly hoursRepository: Repository<HoursOperation>,
  ) {}

  async companies(user: User) {
    return {
      stores: await this.stores.find({
        where: { user: { id: user.id } },
        order: { id: 'DESC' },
        relations: { company: { categories: { category: true } } },
      }),
    };
  }

  private async ownCompany(user: User, companyId: number) {
    if (
      !(await this.stores.existsBy({
        user: { id: user.id },
        company: { id: companyId },
      }))
    )
      throw new NotFoundException('Business not found');
  }

  async products(user: User, companyId: number) {
    await this.ownCompany(user, companyId);
    return {
      products: await this.productsRepository.find({
        where: { company: { id: companyId } },
        order: { id: 'DESC' },
      }),
    };
  }

  async createProduct(user: User, dto: CreateProductDto) {
    await this.ownCompany(user, dto.company.id);
    return {
      product: await this.saveProduct(this.productsRepository.create(dto)),
    };
  }

  async updateProduct(user: User, id: number, dto: UpdateProductDto) {
    if (dto.company) throw new BadRequestException('Company cannot be changed');
    const product = await this.productsRepository.findOne({
      where: { id },
      relations: { company: true },
    });
    if (!product) throw new NotFoundException('Product not found');
    await this.ownCompany(user, product.company.id);
    Object.assign(product, dto);
    return { product: await this.saveProduct(product) };
  }

  private async saveProduct(product: Product) {
    try {
      return await this.productsRepository.save(product);
    } catch (error) {
      handleDbExceptions(error, this.logger);
    }
  }

  async hours(user: User, storeId: number) {
    if (!(await this.stores.existsBy({ id: storeId, user: { id: user.id } })))
      throw new NotFoundException('Store not found');
    return {
      hours: await this.hoursRepository.find({
        where: { store: { id: storeId } },
        order: { day: 'ASC' },
      }),
    };
  }

  async updateHour(user: User, id: number, dto: UpdateHoursOperationDto) {
    const hour = await this.hoursRepository.findOne({
      where: { id, store: { user: { id: user.id } } },
    });
    if (!hour) throw new NotFoundException('Schedule not found');
    Object.assign(hour, dto);
    return { hour: await this.hoursRepository.save(hour) };
  }
}
