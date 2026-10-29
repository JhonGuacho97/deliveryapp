import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { randomBytes } from 'node:crypto';
import { DataSource, Repository } from 'typeorm';
import { User } from '../../auth/entities/user.entity';
import { StatusPayment } from '../../common/glob/status';
import { Balance } from '../balance/entities/balance.entity';
import { Payment } from './entities/payment.entity';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { PayphoneGateway, StripeGateway } from './payment-gateways';
import {
  paymentConfiguration,
  payphoneOrigin,
  requirePayments,
} from './payment-policy';

@Injectable()
export class PaymentsService {
  constructor(
    @InjectRepository(Payment) private readonly payments: Repository<Payment>,
    @InjectRepository(Balance) private readonly balances: Repository<Balance>,
    private readonly database: DataSource,
    private readonly payphone: PayphoneGateway,
    private readonly stripe: StripeGateway,
  ) {}

  configuration() {
    return paymentConfiguration();
  }

  private view(payment: Payment) {
    let checkoutUrl: string | null = null;
    const response = payment.response as Record<string, unknown>;
    if (
      payment.provider === 'payphone' &&
      response?.payWithCard &&
      process.env.PAYPHONE_RESPONSE_URL &&
      payment.clientTransactionId
    ) {
      checkoutUrl = new URL(
        `/api/client/payments/payphone/start/${payment.clientTransactionId}`,
        payphoneOrigin(),
      ).toString();
    }
    return {
      id: payment.id,
      provider: payment.provider,
      status: payment.status,
      money: payment.money,
      currency: payment.currency,
      creditedAt: payment.creditedAt,
      response:
        payment.provider === 'payphone'
          ? { checkoutUrl }
          : { client_secret: response?.client_secret },
    };
  }

  async create(user: User, dto: CreatePaymentDto) {
    const provider = requirePayments();
    const amountCents = Math.round((dto.money + Number.EPSILON) * 100);
    const currency =
      typeof dto.currency === 'string' ? dto.currency.toUpperCase() : '';
    if (
      !Number.isFinite(dto.money) ||
      !Number.isSafeInteger(amountCents) ||
      amountCents < 100 ||
      amountCents > 1000000 ||
      Math.abs(dto.money * 100 - amountCents) > 0.000001 ||
      currency !== 'USD'
    )
      throw new BadRequestException('Invalid payment amount or currency.');
    const pending = {
      userId: user.id,
      provider,
      amountCents,
      status: StatusPayment.STARTED,
    };
    let payment =
      provider === 'payphone' ? await this.payments.findOneBy(pending) : null;
    if (!payment) {
      try {
        payment = await this.payments.save(
          this.payments.create({
            ...dto,
            ...pending,
            money: amountCents / 100,
            currency,
            clientTransactionId: randomBytes(12).toString('hex'),
            response: {},
            user,
          }),
        );
      } catch (error) {
        const code =
          typeof error === 'object' && error !== null && 'code' in error
            ? error.code
            : undefined;
        if (provider !== 'payphone' || code !== '23505') throw error;
        payment = await this.payments.findOneBy(pending);
        if (!payment) throw new ConflictException('Payment creation conflict.');
      }
    }
    try {
      return await this.database.transaction(async (manager) => {
        const repository = manager.getRepository(Payment);
        const locked = await repository.findOne({
          where: { id: payment.id, userId: user.id },
          lock: { mode: 'pessimistic_write' },
        });
        if (!locked || locked.status !== StatusPayment.STARTED)
          throw new ConflictException('Payment is no longer pending.');
        const response = locked.response as Record<string, unknown>;
        if (!(response?.payWithCard || response?.client_secret)) {
          const session = await (
            provider === 'payphone' ? this.payphone : this.stripe
          ).create(locked);
          locked.response = session.response;
          locked.providerTransactionId = session.transactionId || null;
          await repository.save(locked);
        }
        return this.view(locked);
      });
    } catch (error) {
      // A failed Prepare never exposed a usable checkout to the caller. Do not
      // cancel a concurrent successful initialization after its lock releases.
      await this.payments
        .createQueryBuilder()
        .update()
        .set({ status: StatusPayment.CANCELLED })
        .where(
          "id = :id AND status = :status AND response::jsonb = '{}'::jsonb",
          { id: payment.id, status: StatusPayment.STARTED },
        )
        .execute();
      throw error;
    }
  }

  async checkout(clientTransactionId: string) {
    if (!/^[a-f0-9]{24}$/.test(clientTransactionId))
      throw new NotFoundException();
    const payment = await this.payments.findOneBy({
      clientTransactionId,
      provider: 'payphone',
    });
    if (!payment) throw new NotFoundException();
    if (payment.status !== StatusPayment.STARTED)
      return { ...this.view(payment), links: null };
    requirePayments('payphone');
    const response = payment.response as Record<string, unknown>;
    return {
      ...this.view(payment),
      links: {
        card: response?.payWithCard,
        payphone: response?.payWithPayPhone,
      },
    };
  }

  async payphoneReturn(transactionId: string, clientTransactionId: string) {
    if (
      !/^\d{1,16}$/.test(transactionId || '') ||
      !Number.isSafeInteger(Number(transactionId)) ||
      Number(transactionId) <= 0 ||
      !/^[a-f0-9]{24}$/.test(clientTransactionId || '')
    )
      throw new BadRequestException('Invalid PayPhone callback.');
    const payment = await this.payments.findOneBy({
      clientTransactionId,
      provider: 'payphone',
    });
    if (!payment) throw new NotFoundException();
    if (payment.status !== StatusPayment.STARTED) return this.view(payment);
    requirePayments('payphone');
    await this.payments.update(
      { id: payment.id, status: StatusPayment.STARTED },
      {
        response: {
          ...(payment.response as object),
          callbackId: String(Number(transactionId)),
        },
      },
    );
    return this.verifyAndSettle(payment.id, payment.userId);
  }

  async status(user: User, id: number) {
    const payment = await this.payments.findOneBy({ id, userId: user.id });
    if (!payment) throw new NotFoundException();
    if (
      payment.status === StatusPayment.STARTED &&
      paymentConfiguration().enabled &&
      ((payment.provider === 'stripe' &&
        paymentConfiguration().stripeEnabled) ||
        (payment.response as Record<string, unknown>)?.callbackId)
    ) {
      return this.verifyAndSettle(id, user.id);
    }
    return this.view(payment);
  }

  async confirm(user: User, id: number) {
    requirePayments();
    const payment = await this.verifyAndSettle(id, user.id);
    return payment.status === StatusPayment.CONFIRMED;
  }

  private async verifyAndSettle(id: number, userId: number) {
    return this.database.transaction(async (manager) => {
      const repository = manager.getRepository(Payment);
      const payment = await repository.findOne({
        where: { id, userId },
        lock: { mode: 'pessimistic_write' },
      });
      if (!payment || !payment.userId) throw new NotFoundException();
      if (payment.status !== StatusPayment.STARTED) return this.view(payment);
      requirePayments(payment.provider);
      const hint = (payment.response as Record<string, unknown>)?.callbackId;
      if (payment.provider === 'payphone' && typeof hint !== 'string')
        return this.view(payment);
      const verified =
        payment.provider === 'payphone'
          ? await this.payphone.verify(payment, hint as string)
          : await this.stripe.verify(payment);
      const expectedId =
        payment.provider === 'payphone'
          ? hint
          : payment.providerTransactionId ||
            (payment.response as Record<string, unknown>)?.id;
      if (
        verified.transactionId !== expectedId ||
        verified.clientTransactionId !== (payment.clientTransactionId || '') ||
        !Number.isSafeInteger(verified.amountCents) ||
        verified.amountCents !== payment.amountCents ||
        verified.currency !== payment.currency.toUpperCase()
      )
        throw new ConflictException(
          'The provider payment does not match this transaction.',
        );
      if (verified.state === 'pending') return this.view(payment);
      payment.providerTransactionId = verified.transactionId;
      if (verified.state === 'canceled') {
        payment.status = StatusPayment.CANCELLED;
      } else {
        // Payment lock + atomic balance increment make simultaneous returns,
        // status checks and retries credit the wallet exactly once.
        await manager
          .getRepository(Balance)
          .createQueryBuilder()
          .insert()
          .values({ userId, money: 0 })
          .orIgnore()
          .execute();
        await manager
          .getRepository(Balance)
          .createQueryBuilder()
          .update()
          .set({
            money: () =>
              'ROUND(("money"::numeric + :credit), 2)::double precision',
          })
          .where('"userId" = :userId', { userId })
          .setParameter('credit', (payment.amountCents / 100).toFixed(2))
          .execute();
        payment.status = StatusPayment.CONFIRMED;
        payment.creditedAt = new Date();
      }
      await repository.save(payment);
      return this.view(payment);
    });
  }

  async cancel(user: User, id: number) {
    requirePayments();
    const payment = await this.payments.findOneBy({ id, userId: user.id });
    if (!payment) throw new NotFoundException();
    if (payment.status !== StatusPayment.STARTED)
      return payment.status === StatusPayment.CANCELLED;
    if (payment.provider === 'payphone')
      throw new ConflictException(
        'A PayPhone checkout remains pending until the provider confirms its result. You can resume it.',
      );
    requirePayments('stripe');
    if (!(await this.stripe.cancel(payment))) {
      await this.verifyAndSettle(id, user.id);
      return false;
    }
    await this.verifyAndSettle(id, user.id);
    return true;
  }
}
