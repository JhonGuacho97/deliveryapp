import { INestApplication, ValidationPipe } from '@nestjs/common';

export function configureApp(app: INestApplication): void {
  // Express 5 defaults to a different parser; preserve the existing query contract.
  app.getHttpAdapter().getInstance().set('query parser', 'extended');
  app.setGlobalPrefix('api');
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
    }),
  );
}
