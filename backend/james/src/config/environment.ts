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
  if (environment.NODE_ENV === 'production' && environment.DB_SYNCHRONIZE) {
    errors.push('DB_SYNCHRONIZE must be false in production');
  }

  if (errors.length > 0) {
    throw new Error(`Invalid environment configuration: ${errors.join('; ')}`);
  }
  return environment;
}
