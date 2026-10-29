import { MigrationInterface, QueryRunner } from 'typeorm';

export class PaymentProviders1793320000000 implements MigrationInterface {
  name = 'PaymentProviders1793320000000';
  async up(runner: QueryRunner): Promise<void> {
    await runner.query(`ALTER TABLE "payment"
      ADD "provider" character varying(16) NOT NULL DEFAULT 'stripe',
      ADD "amountCents" integer,
      ADD "clientTransactionId" character varying(64),
      ADD "providerTransactionId" character varying(128),
      ADD "creditedAt" TIMESTAMP WITH TIME ZONE`);
    await runner.query(
      `UPDATE "payment" SET "amountCents" = ROUND("money"::numeric * 100)::integer WHERE "money" > 0 AND "money" <= 10000000`,
    );
    await runner.query(
      `CREATE UNIQUE INDEX "IDX_payment_client_transaction" ON "payment" ("clientTransactionId")`,
    );
    await runner.query(
      `CREATE UNIQUE INDEX "IDX_payment_provider_transaction" ON "payment" ("provider", "providerTransactionId")`,
    );
    await runner.query(
      `CREATE UNIQUE INDEX "IDX_payment_pending_amount" ON "payment" ("userId", "provider", "amountCents") WHERE "status" = 1 AND "provider" = 'payphone'`,
    );
  }
  async down(runner: QueryRunner): Promise<void> {
    await runner.query(`DROP INDEX "IDX_payment_pending_amount"`);
    await runner.query(`DROP INDEX "IDX_payment_provider_transaction"`);
    await runner.query(`DROP INDEX "IDX_payment_client_transaction"`);
    await runner.query(
      `ALTER TABLE "payment" DROP COLUMN "creditedAt", DROP COLUMN "providerTransactionId", DROP COLUMN "clientTransactionId", DROP COLUMN "amountCents", DROP COLUMN "provider"`,
    );
  }
}
