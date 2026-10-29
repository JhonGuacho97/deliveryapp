import { Injectable, ServiceUnavailableException } from '@nestjs/common';
import axios from 'axios';
import * as qs from 'qs';
import { Payment } from './entities/payment.entity';
import { requirePayments } from './payment-policy';

export interface GatewaySession {
  response: Record<string, unknown>;
  transactionId?: string;
}

export interface GatewayVerification {
  state: 'approved' | 'canceled' | 'pending';
  transactionId: string;
  clientTransactionId: string;
  amountCents: number;
  currency: string;
}

export function isPayphoneCheckout(value: unknown): value is string {
  if (typeof value !== 'string') return false;
  try {
    const url = new URL(value);
    return (
      url.protocol === 'https:' &&
      url.hostname === 'pay.payphonetodoesposible.com' &&
      !url.username &&
      !url.password &&
      !url.port &&
      ['/Anonymous/Index', '/PayPhone/Index'].includes(url.pathname) &&
      Boolean(url.searchParams.get('paymentId'))
    );
  } catch {
    return false;
  }
}

@Injectable()
export class PayphoneGateway {
  private headers() {
    return {
      Authorization: `Bearer ${process.env.PAYPHONE_TOKEN}`,
      'Content-Type': 'application/json',
    };
  }

  async create(payment: Payment): Promise<GatewaySession> {
    requirePayments('payphone');
    try {
      const { data } = await axios.post(
        'https://pay.payphonetodoesposible.com/api/button/Prepare',
        {
          amount: payment.amountCents,
          amountWithoutTax: payment.amountCents,
          currency: 'USD',
          clientTransactionId: payment.clientTransactionId,
          storeId: process.env.PAYPHONE_STORE_ID,
          reference: `Saldo para pedido ${payment.id}`,
          responseUrl: process.env.PAYPHONE_RESPONSE_URL,
        },
        { headers: this.headers(), timeout: 10000, maxRedirects: 0 },
      );
      if (
        !data ||
        typeof data.paymentId !== 'string' ||
        !isPayphoneCheckout(data.payWithCard) ||
        !isPayphoneCheckout(data.payWithPayPhone)
      )
        throw new Error('Invalid checkout response');
      return {
        response: {
          paymentId: data.paymentId,
          payWithCard: data.payWithCard,
          payWithPayPhone: data.payWithPayPhone,
        },
      };
    } catch {
      // Never forward Axios errors: their configuration contains the token.
      throw new ServiceUnavailableException(
        'PayPhone checkout is unavailable.',
      );
    }
  }

  async verify(
    payment: Payment,
    transactionId: string,
  ): Promise<GatewayVerification> {
    requirePayments('payphone');
    try {
      const { data } = await axios.post(
        'https://pay.payphonetodoesposible.com/api/button/V2/Confirm',
        {
          id: Number(transactionId),
          clientTxId: payment.clientTransactionId,
        },
        { headers: this.headers(), timeout: 10000, maxRedirects: 0 },
      );
      if (!data || ![1, 2, 3].includes(data.statusCode))
        throw new Error('Unknown payment status');
      return {
        state:
          data.statusCode === 3
            ? 'approved'
            : data.statusCode === 2
              ? 'canceled'
              : 'pending',
        transactionId: String(data.transactionId),
        clientTransactionId: data.clientTransactionId,
        amountCents: data.amount,
        currency:
          typeof data.currency === 'string' ? data.currency.toUpperCase() : '',
      };
    } catch {
      throw new ServiceUnavailableException(
        'PayPhone verification is temporarily unavailable.',
      );
    }
  }
}

@Injectable()
export class StripeGateway {
  private config() {
    return {
      headers: { Authorization: `Bearer ${process.env.STRIPE_SECRET_KEY}` },
      timeout: 10000,
      maxRedirects: 0,
    };
  }

  async create(payment: Payment): Promise<GatewaySession> {
    requirePayments('stripe');
    try {
      const { data } = await axios.post(
        'https://api.stripe.com/v1/payment_intents',
        qs.stringify({
          amount: payment.amountCents,
          currency: payment.currency.toLowerCase(),
          'payment_method_types[]': 'card',
          'metadata[client_transaction_id]': payment.clientTransactionId,
        }),
        {
          ...this.config(),
          headers: {
            ...this.config().headers,
            'Content-Type': 'application/x-www-form-urlencoded',
            'Idempotency-Key': payment.clientTransactionId,
          },
        },
      );
      if (
        !/^pi_[a-zA-Z0-9]+$/.test(data?.id) ||
        typeof data.client_secret !== 'string'
      )
        throw new Error('Invalid intent');
      return {
        transactionId: data.id,
        response: { id: data.id, client_secret: data.client_secret },
      };
    } catch {
      throw new ServiceUnavailableException('Stripe checkout is unavailable.');
    }
  }

  async verify(payment: Payment): Promise<GatewayVerification> {
    requirePayments('stripe');
    const id =
      payment.providerTransactionId ||
      (payment.response as Record<string, unknown>)?.id;
    if (typeof id !== 'string' || !/^pi_[a-zA-Z0-9]+$/.test(id))
      throw new ServiceUnavailableException(
        'Invalid Stripe payment reference.',
      );
    try {
      const { data } = await axios.get(
        `https://api.stripe.com/v1/payment_intents/${id}`,
        this.config(),
      );
      return {
        state:
          data.status === 'succeeded' &&
          data.amount_received === payment.amountCents
            ? 'approved'
            : data.status === 'canceled'
              ? 'canceled'
              : 'pending',
        transactionId: data.id,
        clientTransactionId: data.metadata?.client_transaction_id || '',
        amountCents: data.amount,
        currency:
          typeof data.currency === 'string' ? data.currency.toUpperCase() : '',
      };
    } catch {
      throw new ServiceUnavailableException(
        'Stripe verification is temporarily unavailable.',
      );
    }
  }

  async cancel(payment: Payment) {
    requirePayments('stripe');
    if (!/^pi_[a-zA-Z0-9]+$/.test(payment.providerTransactionId || ''))
      return false;
    try {
      const { data } = await axios.post(
        `https://api.stripe.com/v1/payment_intents/${payment.providerTransactionId}/cancel`,
        '',
        {
          ...this.config(),
          headers: {
            ...this.config().headers,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        },
      );
      return data.status === 'canceled';
    } catch {
      return false;
    }
  }
}
