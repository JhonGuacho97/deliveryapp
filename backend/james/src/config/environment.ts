export function validateEnvironment(
  input: Record<string, unknown>,
): Record<string, unknown> {
  const environment = { ...input };
  environment.NODE_ENV = input.NODE_ENV ?? 'development';
  environment.JWT_SECRET = input.JWT_SECRET || input.JWT_SECREAT;

  const errors: string[] = [];
  for (const name of [
    'DB_HOST',
    'DB_USERNAME',
    'DB_PASSWORD',
    'DB_NAME',
    'JWT_SECRET',
  ]) {
    if (
      typeof environment[name] !== 'string' ||
      !(environment[name] as string).trim()
    ) {
      errors.push(`${name} is required`);
    }
  }

  for (const [name, fallback] of [
    ['PORT', 3000],
    ['DB_PORT', 5432],
  ] as const) {
    const port = Number(input[name] ?? fallback);
    if (!Number.isInteger(port) || port < 1 || port > 65535) {
      errors.push(`${name} must be an integer between 1 and 65535`);
    }
    environment[name] = port;
  }

  const synchronize = input.DB_SYNCHRONIZE ?? 'false';
  if (
    !['true', 'false', true, false].includes(synchronize as string | boolean)
  ) {
    errors.push('DB_SYNCHRONIZE must be true or false');
  }
  environment.DB_SYNCHRONIZE = synchronize === 'true' || synchronize === true;
  const external = input.EXTERNAL_SERVICES_ENABLED ?? 'true';
  if (!['true', 'false', true, false].includes(external as string | boolean)) {
    errors.push('EXTERNAL_SERVICES_ENABLED must be true or false');
  }
  environment.EXTERNAL_SERVICES_ENABLED =
    external === 'true' || external === true;

  for (const name of ['PAYMENTS_ENABLED', 'STRIPE_ENABLED']) {
    const value = input[name] ?? 'false';
    if (!['true', 'false', true, false].includes(value as string | boolean))
      errors.push(`${name} must be true or false`);
    environment[name] = value === 'true' || value === true;
  }
  const provider = input.PAYMENT_PROVIDER ?? 'payphone';
  environment.PAYMENT_PROVIDER = provider;
  if (!['payphone', 'stripe'].includes(provider as string))
    errors.push('PAYMENT_PROVIDER must be payphone or stripe');
  const mode = input.PAYPHONE_MODE ?? 'test';
  environment.PAYPHONE_MODE = mode;
  if (!['test', 'production'].includes(mode as string))
    errors.push('PAYPHONE_MODE must be test or production');
  if (environment.PAYMENTS_ENABLED) {
    if (provider === 'stripe') {
      if (!environment.STRIPE_ENABLED)
        errors.push('Stripe must be explicitly enabled');
      if (!input.STRIPE_SECRET_KEY)
        errors.push('STRIPE_SECRET_KEY is required');
    } else {
      for (const name of [
        'PAYPHONE_TOKEN',
        'PAYPHONE_STORE_ID',
        'PAYPHONE_RESPONSE_URL',
      ]) {
        if (typeof input[name] !== 'string' || !(input[name] as string).trim())
          errors.push(`${name} is required`);
      }
      if (input.PAYPHONE_RESPONSE_URL) {
        try {
          const url = new URL(input.PAYPHONE_RESPONSE_URL as string);
          const local = [
            'localhost',
            '127.0.0.1',
            '[::1]',
            '10.0.2.2',
          ].includes(url.hostname);
          const localTest =
            mode === 'test' && environment.NODE_ENV !== 'production' && local;
          if (
            url.protocol !== 'https:' &&
            !(localTest && url.protocol === 'http:')
          )
            errors.push(
              'PAYPHONE_RESPONSE_URL requires HTTPS, except local HTTP in test mode',
            );
          if (
            url.username ||
            url.password ||
            url.search ||
            url.hash ||
            url.pathname !== '/api/client/payments/payphone/return'
          )
            errors.push(
              'PAYPHONE_RESPONSE_URL must point to /api/client/payments/payphone/return without extra parameters',
            );
        } catch {
          errors.push('PAYPHONE_RESPONSE_URL is invalid');
        }
      }
      if (environment.NODE_ENV === 'production' && mode !== 'production')
        errors.push('PAYPHONE_MODE must be production on a production server');
    }
  }
  if (environment.NODE_ENV === 'production' && environment.DB_SYNCHRONIZE) {
    errors.push('DB_SYNCHRONIZE must be false in production');
  }

  if (errors.length > 0) {
    throw new Error(`Invalid environment configuration: ${errors.join('; ')}`);
  }
  return environment;
}
