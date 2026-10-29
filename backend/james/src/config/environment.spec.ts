import { ConfigService } from '@nestjs/config';
import { databaseOptions } from './database.config';
import { validateEnvironment } from './environment';

describe('Environment and database safeguards', () => {
  const valid = {
    DB_HOST: '127.0.0.1',
    DB_USERNAME: 'delivery_test',
    DB_PASSWORD: 'isolated-password',
    DB_NAME: 'delivery_test',
    JWT_SECRET: 'isolated-secret',
  };

  it('disables schema changes and automatic migrations by default', () => {
    const options = databaseOptions(
      new ConfigService(validateEnvironment(valid)),
    );
    expect(options).toMatchObject({
      type: 'postgres',
      port: 5432,
      synchronize: false,
      migrationsRun: false,
    });
  });

  it('accepts the legacy JWT_SECREAT without changing the signing key', () => {
    const environment = validateEnvironment({
      ...valid,
      JWT_SECRET: undefined,
      JWT_SECREAT: 'existing-key',
    });
    expect(environment.JWT_SECRET).toBe('existing-key');
  });

  it('prefers JWT_SECRET when both names are present', () => {
    expect(
      validateEnvironment({ ...valid, JWT_SECREAT: 'old-key' }).JWT_SECRET,
    ).toBe(valid.JWT_SECRET);
  });

  it('forbids schema synchronization in production', () => {
    expect(() =>
      validateEnvironment({
        ...valid,
        NODE_ENV: 'production',
        DB_SYNCHRONIZE: 'true',
      }),
    ).toThrow('DB_SYNCHRONIZE must be false in production');
  });

  it('allows explicit synchronization for a disposable development database', () => {
    expect(
      validateEnvironment({
        ...valid,
        NODE_ENV: 'development',
        DB_SYNCHRONIZE: 'true',
      }).DB_SYNCHRONIZE,
    ).toBe(true);
  });

  it.each(['0', '65536', 'not-a-port', '3000.5'])(
    'rejects invalid server ports: %s',
    (port) => {
      expect(() => validateEnvironment({ ...valid, PORT: port })).toThrow(
        'PORT must be an integer',
      );
    },
  );

  it('rejects invalid database ports', () => {
    expect(() => validateEnvironment({ ...valid, DB_PORT: 'invalid' })).toThrow(
      'DB_PORT must be an integer',
    );
  });

  it('rejects ambiguous boolean values', () => {
    expect(() =>
      validateEnvironment({ ...valid, DB_SYNCHRONIZE: 'yes' }),
    ).toThrow('DB_SYNCHRONIZE must be true or false');
  });

  it('accepts offline local integrations without changing the default', () => {
    expect(validateEnvironment(valid).EXTERNAL_SERVICES_ENABLED).toBe(true);
    expect(
      validateEnvironment({ ...valid, EXTERNAL_SERVICES_ENABLED: 'false' })
        .EXTERNAL_SERVICES_ENABLED,
    ).toBe(false);
  });

  it('rejects ambiguous integration settings', () => {
    expect(() =>
      validateEnvironment({ ...valid, EXTERNAL_SERVICES_ENABLED: 'sometimes' }),
    ).toThrow('EXTERNAL_SERVICES_ENABLED must be true or false');
  });

  it('reports missing configuration without including credentials in errors', () => {
    expect(() =>
      validateEnvironment({ ...valid, DB_HOST: '', JWT_SECRET: '' }),
    ).toThrow('DB_HOST is required; JWT_SECRET is required');
  });
});
