import { ServiceUnavailableException } from '@nestjs/common';

export type PaymentProvider = 'payphone' | 'stripe';

export function paymentConfiguration() {
  const provider = (process.env.PAYMENT_PROVIDER ||
    'payphone') as PaymentProvider;
  const enabled = process.env.PAYMENTS_ENABLED === 'true';
  const stripeEnabled = process.env.STRIPE_ENABLED === 'true';
  const configured =
    provider === 'payphone'
      ? Boolean(
          process.env.PAYPHONE_TOKEN?.trim() &&
          process.env.PAYPHONE_STORE_ID?.trim() &&
          process.env.PAYPHONE_RESPONSE_URL?.trim(),
        )
      : stripeEnabled && Boolean(process.env.STRIPE_SECRET_KEY?.trim());
  return {
    provider,
    enabled: enabled && configured,
    configured,
    stripeEnabled,
    testMode: process.env.PAYPHONE_MODE !== 'production',
  };
}

export function requirePayments(provider?: PaymentProvider) {
  if (process.env.PAYMENTS_ENABLED !== 'true')
    throw new ServiceUnavailableException('Electronic payments are disabled.');
  const selected = provider || paymentConfiguration().provider;
  if (selected === 'stripe' && process.env.STRIPE_ENABLED !== 'true')
    throw new ServiceUnavailableException('Stripe is disabled.');
  if (
    selected === 'payphone' &&
    (!process.env.PAYPHONE_TOKEN?.trim() ||
      !process.env.PAYPHONE_STORE_ID?.trim() ||
      !process.env.PAYPHONE_RESPONSE_URL?.trim())
  )
    throw new ServiceUnavailableException('PayPhone is not configured.');
  if (selected === 'stripe' && !process.env.STRIPE_SECRET_KEY?.trim())
    throw new ServiceUnavailableException('Stripe is not configured.');
  if (!['payphone', 'stripe'].includes(selected))
    throw new ServiceUnavailableException('Unsupported payment provider.');
  return selected;
}

export function payphoneOrigin(): URL {
  const url = new URL(process.env.PAYPHONE_RESPONSE_URL);
  return url;
}
