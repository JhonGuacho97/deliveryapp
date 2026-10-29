import 'reflect-metadata';
import { existsSync } from 'node:fs';
import { join, resolve } from 'node:path';
import { ConfigService } from '@nestjs/config';
import { DataSource } from 'typeorm';
import { postgresOptions } from '../config/database.config';
import { validateEnvironment } from '../config/environment';

const envPath = resolve(process.cwd(), '.env');
if (existsSync(envPath)) process.loadEnvFile(envPath);

const configuration = new ConfigService(validateEnvironment(process.env));

export default new DataSource({
  ...postgresOptions(configuration),
  synchronize: false,
  entities: [join(__dirname, '../**/*.entity{.js,.ts}').replace(/\\/g, '/')],
});
