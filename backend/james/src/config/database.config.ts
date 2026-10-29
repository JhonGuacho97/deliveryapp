import { ConfigService } from '@nestjs/config';
import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { join } from 'node:path';
import { PostgresConnectionOptions } from 'typeorm/driver/postgres/PostgresConnectionOptions';

export function postgresOptions(
  config: ConfigService,
): PostgresConnectionOptions {
  return {
    type: 'postgres',
    host: config.getOrThrow<string>('DB_HOST'),
    port: config.getOrThrow<number>('DB_PORT'),
    username: config.getOrThrow<string>('DB_USERNAME'),
    password: config.getOrThrow<string>('DB_PASSWORD'),
    database: config.getOrThrow<string>('DB_NAME'),
    synchronize: config.getOrThrow<boolean>('DB_SYNCHRONIZE'),
    migrationsRun: false,
    migrationsTableName: 'schema_migrations',
    migrationsTransactionMode: 'each',
    migrations: [
      join(__dirname, '../database/migrations/*{.js,.ts}').replace(/\\/g, '/'),
    ],
    // PostGIS is enabled explicitly by the initial migration.
    installExtensions: false,
  };
}

export function databaseOptions(config: ConfigService): TypeOrmModuleOptions {
  return { ...postgresOptions(config), autoLoadEntities: true };
}
