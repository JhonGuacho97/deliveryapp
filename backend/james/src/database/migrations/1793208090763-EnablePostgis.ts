import { MigrationInterface, QueryRunner } from 'typeorm';

export class EnablePostgis1793208090763 implements MigrationInterface {
  name = 'EnablePostgis1793208090763';

  async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query('CREATE EXTENSION IF NOT EXISTS postgis');
  }

  async down(_queryRunner: QueryRunner): Promise<void> {
    // PostGIS is infrastructure and can have data/dependents outside this app.
    // Reverting an application migration must not remove a shared extension.
  }
}
