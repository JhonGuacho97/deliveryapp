import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { CreateChatDto } from '../../chat/dto/create-chat.dto';
import { MarkAllChatDto } from '../../chat/dto/mark-all-chat.dto';
import { OrderMarketDto } from '../../client/market/dto/order-market.dto';
import { CreatePaymentDto } from '../../client/payments/dto/create-payment.dto';
import { CreateProductDto } from '../../admin/product/dto/create-product.dto';

const options = { whitelist: true, forbidNonWhitelisted: true };
const product = {
  id: 7,
  name: 'Producto',
  description: 'Descripción del producto',
  image: '',
  note: '',
  total: 6.5,
  number: 2,
  price: 3.25,
};

describe('nested Flutter request contracts', () => {
  it('validates entity references containing only their id', async () => {
    expect(
      await validate(
        plainToInstance(CreateChatDto, {
          message: 'Hola',
          type: 1,
          to: { id: 8 },
          order: { id: 9 },
          rol: 'client',
        }),
        options,
      ),
    ).toEqual([]);
    expect(
      await validate(
        plainToInstance(MarkAllChatDto, {
          order: { id: 9 },
          rol: 'client',
        }),
        options,
      ),
    ).toEqual([]);
    expect(
      await validate(
        plainToInstance(CreateProductDto, {
          name: 'Producto',
          description: 'Descripción del producto',
          image: '',
          type: 1,
          price: 3.25,
          company: { id: 2 },
        }),
        options,
      ),
    ).toEqual([]);
  });

  it('validates product snapshots in orders and payments', async () => {
    expect(
      await validate(
        plainToInstance(CreatePaymentDto, {
          money: 8,
          currency: 'usd',
          products: [product],
        }),
        options,
      ),
    ).toEqual([]);
    expect(
      await validate(
        plainToInstance(OrderMarketDto, {
          store: { id: 5 },
          note: '',
          deliveryFee: 1.5,
          total: 8,
          address: 'Calle 1',
          products: [product],
          location: { x: -0.3, y: -78.6 },
          orderedAt: '2026-10-28',
          payment: 5001,
        }),
        options,
      ),
    ).toEqual([]);
  });

  it('continues to reject fields outside the reference contract', async () => {
    const errors = await validate(
      plainToInstance(CreateChatDto, {
        message: 'Hola',
        type: 1,
        to: { id: 8, roles: ['admin'] },
        order: { id: 9 },
        rol: 'client',
      }),
      options,
    );
    expect(errors).not.toEqual([]);
    expect(JSON.stringify(errors)).toContain('whitelistValidation');
  });
});
