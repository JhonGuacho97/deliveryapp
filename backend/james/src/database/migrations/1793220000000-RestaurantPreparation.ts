import { MigrationInterface, QueryRunner } from 'typeorm';

export class RestaurantPreparation1793220000000 implements MigrationInterface {
  name = 'RestaurantPreparation1793220000000';

  async up(queryRunner: QueryRunner): Promise<void> {
    // Preserve NULL for legacy orders; new orders must be accepted by the kitchen.
    await queryRunner.query(
      `ALTER TABLE "order" ADD "preparationStatus" character varying(16), ADD "preparationMinutes" smallint, ADD "acceptedAt" TIMESTAMP WITH TIME ZONE, ADD "readyAt" TIMESTAMP WITH TIME ZONE`,
    );
    await queryRunner.query(
      `ALTER TABLE "order" ALTER COLUMN "preparationStatus" SET DEFAULT 'pending'`,
    );
  }

  async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "order" DROP COLUMN "readyAt", DROP COLUMN "acceptedAt", DROP COLUMN "preparationMinutes", DROP COLUMN "preparationStatus"`,
    );
  }
}
