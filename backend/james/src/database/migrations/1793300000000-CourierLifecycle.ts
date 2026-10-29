import { MigrationInterface, QueryRunner } from 'typeorm';

export class CourierLifecycle1793300000000 implements MigrationInterface {
  name = 'CourierLifecycle1793300000000';
  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "order" ADD "assignedAt" TIMESTAMP WITH TIME ZONE, ADD "collectedAt" TIMESTAMP WITH TIME ZONE, ADD "deliveredAt" TIMESTAMP WITH TIME ZONE, ADD "cancelledAt" TIMESTAMP WITH TIME ZONE`,
    );
  }
  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "order" DROP COLUMN "cancelledAt", DROP COLUMN "deliveredAt", DROP COLUMN "collectedAt", DROP COLUMN "assignedAt"`,
    );
  }
}
