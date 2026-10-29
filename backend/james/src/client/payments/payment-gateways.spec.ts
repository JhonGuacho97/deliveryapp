import axios from 'axios';
import {
  PayphoneGateway,
  StripeGateway,
  isPayphoneCheckout,
} from './payment-gateways';
import { paymentConfiguration, requirePayments } from './payment-policy';
import { Payment } from './entities/payment.entity';
import { validateEnvironment } from '../../config/environment';

describe('Payment provider boundaries', () => {
  const original = { ...process.env };
  const payment = {
    id: 12,
    amountCents: 325,
    currency: 'USD',
    clientTransactionId: 'a'.repeat(24),
  } as Payment;
  const local = {
    DB_HOST: 'localhost',
    DB_USERNAME: 'test',
    DB_PASSWORD: 'fixture',
    DB_NAME: 'test',
    JWT_SECRET: 'fixture',
    PAYMENTS_ENABLED: 'true',
    PAYMENT_PROVIDER: 'payphone',
    PAYPHONE_MODE: 'test',
    PAYPHONE_TOKEN: 'fixture-private-token',
    PAYPHONE_STORE_ID: 'fixture-store',
    PAYPHONE_RESPONSE_URL:
      'http://localhost:3000/api/client/payments/payphone/return',
    STRIPE_ENABLED: 'false',
    EXTERNAL_SERVICES_ENABLED: 'false',
  };
  beforeEach(() => Object.assign(process.env, local));
  afterEach(() => {
    process.env = { ...original };
    jest.restoreAllMocks();
  });

  it('allows local HTTP test payments independently of Firebase', () => {
    expect(validateEnvironment(local).PAYMENTS_ENABLED).toBe(true);
    expect(paymentConfiguration()).toMatchObject({
      provider: 'payphone',
      enabled: true,
      stripeEnabled: false,
    });
    expect(requirePayments()).toBe('payphone');
    expect(JSON.stringify(paymentConfiguration())).not.toContain(
      local.PAYPHONE_TOKEN,
    );
  });
  it.each(['http://example.test', 'http://192.168.1.5', 'ftp://localhost'])(
    'rejects nonlocal or non-HTTP test callbacks: %s',
    (origin) => {
      expect(() =>
        validateEnvironment({
          ...local,
          PAYPHONE_RESPONSE_URL:
            origin + '/api/client/payments/payphone/return',
        }),
      ).toThrow('HTTPS');
    },
  );
  it('requires production mode and HTTPS on production servers', () => {
    expect(() =>
      validateEnvironment({ ...local, NODE_ENV: 'production' }),
    ).toThrow('HTTPS');
    expect(() =>
      validateEnvironment({ ...local, PAYPHONE_MODE: 'production' }),
    ).toThrow('HTTPS');
    expect(
      validateEnvironment({
        ...local,
        NODE_ENV: 'production',
        PAYPHONE_MODE: 'production',
        PAYPHONE_RESPONSE_URL:
          'https://pay.example.test/api/client/payments/payphone/return',
      }).PAYMENTS_ENABLED,
    ).toBe(true);
  });
  it('does not print secrets in configuration errors', () => {
    expect(() =>
      validateEnvironment({ ...local, PAYPHONE_STORE_ID: '' }),
    ).toThrow('PAYPHONE_STORE_ID is required');
    try {
      validateEnvironment({ ...local, PAYPHONE_STORE_ID: '' });
    } catch (error) {
      expect(String(error)).not.toContain(local.PAYPHONE_TOKEN);
    }
  });
  it.each([
    'javascript:alert(1)',
    'http://pay.payphonetodoesposible.com/Anonymous/Index?paymentId=x',
    'https://evil.test/Anonymous/Index?paymentId=x',
    'https://pay.payphonetodoesposible.com.evil.test/Anonymous/Index?paymentId=x',
    'https://pay.payphonetodoesposible.com/other?paymentId=x',
  ])('rejects untrusted checkout links: %s', (link) =>
    expect(isPayphoneCheckout(link)).toBe(false),
  );
  it('uses integer cents and sanitizes hosted checkout data', async () => {
    const links = {
      paymentId: 'opaque',
      payWithCard:
        'https://pay.payphonetodoesposible.com/Anonymous/Index?paymentId=opaque',
      payWithPayPhone:
        'https://pay.payphonetodoesposible.com/PayPhone/Index?paymentId=opaque',
    };
    const post = jest
      .spyOn(axios, 'post')
      .mockResolvedValue({ data: { ...links, cardNumber: 'private-fixture' } });
    expect(await new PayphoneGateway().create(payment)).toEqual({
      response: links,
    });
    expect(post).toHaveBeenCalledWith(
      'https://pay.payphonetodoesposible.com/api/button/Prepare',
      expect.objectContaining({
        amount: 325,
        amountWithoutTax: 325,
        currency: 'USD',
        clientTransactionId: payment.clientTransactionId,
        responseUrl: local.PAYPHONE_RESPONSE_URL,
      }),
      expect.objectContaining({
        headers: expect.objectContaining({
          Authorization: 'Bearer ' + local.PAYPHONE_TOKEN,
        }),
        maxRedirects: 0,
      }),
    );
  });
  it.each([
    [1, 'pending'],
    [2, 'canceled'],
    [3, 'approved'],
  ])(
    'maps provider status %s without returning card data',
    async (code, state) => {
      const post = jest
        .spyOn(axios, 'post')
        .mockResolvedValue({
          data: {
            statusCode: code,
            transactionId: 123,
            clientTransactionId: payment.clientTransactionId,
            amount: 325,
            currency: 'usd',
            cardNumber: 'private-fixture',
          },
        });
      expect(await new PayphoneGateway().verify(payment, '123')).toEqual({
        state,
        transactionId: '123',
        clientTransactionId: payment.clientTransactionId,
        amountCents: 325,
        currency: 'USD',
      });
      expect(post).toHaveBeenCalledWith(
        'https://pay.payphonetodoesposible.com/api/button/V2/Confirm',
        { id: 123, clientTxId: payment.clientTransactionId },
        expect.anything(),
      );
    },
  );
  it('masks transport failures and rejects unknown payment statuses', async () => {
    const post = jest
      .spyOn(axios, 'post')
      .mockRejectedValue(new Error(local.PAYPHONE_TOKEN));
    await expect(new PayphoneGateway().create(payment)).rejects.toThrow(
      'PayPhone checkout is unavailable',
    );
    post.mockResolvedValue({ data: { statusCode: 100 } });
    await expect(new PayphoneGateway().verify(payment, '123')).rejects.toThrow(
      'temporarily unavailable',
    );
  });
  it('never sends requests to disabled Stripe', async () => {
    const post = jest.spyOn(axios, 'post');
    const get = jest.spyOn(axios, 'get');
    const stripe = new StripeGateway();
    await expect(stripe.create(payment)).rejects.toThrow('Stripe is disabled');
    await expect(stripe.verify(payment)).rejects.toThrow('Stripe is disabled');
    await expect(stripe.cancel(payment)).rejects.toThrow('Stripe is disabled');
    expect(post).not.toHaveBeenCalled();
    expect(get).not.toHaveBeenCalled();
  });
  it('retains the Stripe gateway for explicit future activation', async () => {
    process.env.STRIPE_ENABLED = 'true';
    process.env.STRIPE_SECRET_KEY = 'fixture-stripe';
    jest
      .spyOn(axios, 'post')
      .mockResolvedValue({
        data: { id: 'pi_fixture', client_secret: 'pi_fixture_secret' },
      });
    const session = await new StripeGateway().create(payment);
    expect(session.transactionId).toBe('pi_fixture');
    jest
      .spyOn(axios, 'get')
      .mockResolvedValue({
        data: {
          id: 'pi_fixture',
          status: 'succeeded',
          amount: 325,
          amount_received: 325,
          currency: 'usd',
          metadata: { client_transaction_id: payment.clientTransactionId },
        },
      });
    expect(
      (
        await new StripeGateway().verify({
          ...payment,
          providerTransactionId: 'pi_fixture',
        })
      ).state,
    ).toBe('approved');
  });
});
