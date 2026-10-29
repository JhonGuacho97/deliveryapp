import { MigrationInterface, QueryRunner } from 'typeorm';

export class CatalogVisibility1793310000000 implements MigrationInterface {
  name = 'CatalogVisibility1793310000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DELETE FROM "typeorm_metadata" WHERE "type" = $1 AND "name" = $2 AND "schema" = $3`,
      ['VIEW', 'vw_category', 'public'],
    );
    await queryRunner.query(`DROP VIEW "vw_category"`);
    await queryRunner.query(
      `DELETE FROM "typeorm_metadata" WHERE "type" = $1 AND "name" = $2 AND "schema" = $3`,
      ['VIEW', 'vw_product', 'public'],
    );
    await queryRunner.query(`DROP VIEW "vw_product"`);
    await queryRunner.query(
      `DELETE FROM "typeorm_metadata" WHERE "type" = $1 AND "name" = $2 AND "schema" = $3`,
      ['VIEW', 'vw_company', 'public'],
    );
    await queryRunner.query(`DROP VIEW "vw_company"`);
    await queryRunner.query(`CREATE VIEW "vw_product" AS SELECT p.id, p."companyId", cc.name AS "companyName", p.name, p.image, p.description, p.type, p.price
FROM public.product p INNER JOIN public.company cc ON cc.id = p."companyId"
WHERE p."deletedAt" IS NULL`);
    await queryRunner.query(
      `INSERT INTO "typeorm_metadata"("database", "schema", "table", "type", "name", "value") VALUES (DEFAULT, $1, DEFAULT, $2, $3, $4)`,
      [
        'public',
        'VIEW',
        'vw_product',
        'SELECT p.id, p."companyId", cc.name AS "companyName", p.name, p.image, p.description, p.type, p.price\nFROM public.product p INNER JOIN public.company cc ON cc.id = p."companyId"\nWHERE p."deletedAt" IS NULL',
      ],
    );
    await queryRunner.query(`CREATE VIEW "vw_company" AS SELECT c.id, s.id AS "storeId", s.name, s.address, s.contact, c.image, s.location,
    cc."categoryId", COALESCE(ho.open, TIME '00:00:00') AS open,
    COALESCE(ho.close, TIME '00:00:00') AS close, ho.day,
    COALESCE(ho."isOpen", false) AS "isOpen"
FROM public.company c
INNER JOIN public.company_category cc ON cc."companyId" = c.id
INNER JOIN public.store s ON s."companyId" = c.id
LEFT JOIN LATERAL (
    SELECT candidate.open, candidate.close, candidate.day, candidate."isOpen"
    FROM (
        SELECT h.*, CASE
            WHEN h.open < h.close THEN
                h.day = EXTRACT(DOW FROM h.local_now) AND h.local_now::time >= h.open AND h.local_now::time < h.close
            WHEN h.open > h.close THEN
                (h.day = EXTRACT(DOW FROM h.local_now) AND h.local_now::time >= h.open)
                OR (h.day = (EXTRACT(DOW FROM h.local_now)::int + 6) % 7 AND h.local_now::time < h.close)
            ELSE false END AS "isOpen"
        FROM (
            SELECT schedule.*, (NOW() AT TIME ZONE 'UTC') + schedule."timeZone" * INTERVAL '1 hour' AS local_now
            FROM public.hours_operation schedule WHERE schedule."storeId" = s.id
        ) h
    ) candidate
    WHERE candidate."isOpen" OR candidate.day = EXTRACT(DOW FROM candidate.local_now)
    ORDER BY candidate."isOpen" DESC, candidate.day
    LIMIT 1
) ho ON true
WHERE s."deletedAt" IS NULL`);
    await queryRunner.query(
      `INSERT INTO "typeorm_metadata"("database", "schema", "table", "type", "name", "value") VALUES (DEFAULT, $1, DEFAULT, $2, $3, $4)`,
      [
        'public',
        'VIEW',
        'vw_company',
        'SELECT c.id, s.id AS "storeId", s.name, s.address, s.contact, c.image, s.location,\n    cc."categoryId", COALESCE(ho.open, TIME \'00:00:00\') AS open,\n    COALESCE(ho.close, TIME \'00:00:00\') AS close, ho.day,\n    COALESCE(ho."isOpen", false) AS "isOpen"\nFROM public.company c\nINNER JOIN public.company_category cc ON cc."companyId" = c.id\nINNER JOIN public.store s ON s."companyId" = c.id\nLEFT JOIN LATERAL (\n    SELECT candidate.open, candidate.close, candidate.day, candidate."isOpen"\n    FROM (\n        SELECT h.*, CASE\n            WHEN h.open < h.close THEN\n                h.day = EXTRACT(DOW FROM h.local_now) AND h.local_now::time >= h.open AND h.local_now::time < h.close\n            WHEN h.open > h.close THEN\n                (h.day = EXTRACT(DOW FROM h.local_now) AND h.local_now::time >= h.open)\n                OR (h.day = (EXTRACT(DOW FROM h.local_now)::int + 6) % 7 AND h.local_now::time < h.close)\n            ELSE false END AS "isOpen"\n        FROM (\n            SELECT schedule.*, (NOW() AT TIME ZONE \'UTC\') + schedule."timeZone" * INTERVAL \'1 hour\' AS local_now\n            FROM public.hours_operation schedule WHERE schedule."storeId" = s.id\n        ) h\n    ) candidate\n    WHERE candidate."isOpen" OR candidate.day = EXTRACT(DOW FROM candidate.local_now)\n    ORDER BY candidate."isOpen" DESC, candidate.day\n    LIMIT 1\n) ho ON true\nWHERE s."deletedAt" IS NULL',
      ],
    );
    await queryRunner.query(`CREATE VIEW "vw_category" AS SELECT ct.id, ct.name, ct.image, s.location
FROM public.company c
INNER JOIN public.store s ON s."companyId" = c.id
INNER JOIN public.company_category cc ON cc."companyId" = c.id
INNER JOIN public.category ct ON cc."categoryId" = ct.id
WHERE s."deletedAt" IS NULL`);
    await queryRunner.query(
      `INSERT INTO "typeorm_metadata"("database", "schema", "table", "type", "name", "value") VALUES (DEFAULT, $1, DEFAULT, $2, $3, $4)`,
      [
        'public',
        'VIEW',
        'vw_category',
        'SELECT ct.id, ct.name, ct.image, s.location\nFROM public.company c\nINNER JOIN public.store s ON s."companyId" = c.id\nINNER JOIN public.company_category cc ON cc."companyId" = c.id\nINNER JOIN public.category ct ON cc."categoryId" = ct.id\nWHERE s."deletedAt" IS NULL',
      ],
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `DELETE FROM "typeorm_metadata" WHERE "type" = $1 AND "name" = $2 AND "schema" = $3`,
      ['VIEW', 'vw_category', 'public'],
    );
    await queryRunner.query(`DROP VIEW "vw_category"`);
    await queryRunner.query(
      `DELETE FROM "typeorm_metadata" WHERE "type" = $1 AND "name" = $2 AND "schema" = $3`,
      ['VIEW', 'vw_company', 'public'],
    );
    await queryRunner.query(`DROP VIEW "vw_company"`);
    await queryRunner.query(
      `DELETE FROM "typeorm_metadata" WHERE "type" = $1 AND "name" = $2 AND "schema" = $3`,
      ['VIEW', 'vw_product', 'public'],
    );
    await queryRunner.query(`DROP VIEW "vw_product"`);
    await queryRunner.query(`CREATE VIEW "vw_company" AS SELECT c.id, s.id AS "storeId", s.name, s.address, s.contact, c.image, s.location,
    cc."categoryId", ho.open, ho.close, ho."day",
    ( (NOW() + ("timeZone" ||' H')::INTERVAL)::TIME > ho.open AND  (NOW() + ("timeZone" ||' H')::INTERVAL)::TIME < ho.close) AS "isOpen"
	FROM public.company AS c
    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id
    INNER JOIN public.store AS s ON s."companyId" = c.id
    INNER JOIN public.hours_operation AS ho ON ho."storeId" = s.id AND ho.day = EXTRACT(DOW FROM (NOW() + ("timeZone" ||' H')::INTERVAL));`);
    await queryRunner.query(
      `INSERT INTO "typeorm_metadata"("database", "schema", "table", "type", "name", "value") VALUES (DEFAULT, $1, DEFAULT, $2, $3, $4)`,
      [
        'public',
        'VIEW',
        'vw_company',
        'SELECT c.id, s.id AS "storeId", s.name, s.address, s.contact, c.image, s.location, \n    cc."categoryId", ho.open, ho.close, ho."day", \n    ( (NOW() + ("timeZone" ||\' H\')::INTERVAL)::TIME > ho.open AND  (NOW() + ("timeZone" ||\' H\')::INTERVAL)::TIME < ho.close) AS "isOpen"\n\tFROM public.company AS c \n    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id\n    INNER JOIN public.store AS s ON s."companyId" = c.id\n    INNER JOIN public.hours_operation AS ho ON ho."storeId" = s.id AND ho.day = EXTRACT(DOW FROM (NOW() + ("timeZone" ||\' H\')::INTERVAL));',
      ],
    );
    await queryRunner.query(`CREATE VIEW "vw_product" AS SELECT p.id, p."companyId", cc.name AS "companyName", p.name, p.image, p.description, p.type, p.price
	FROM public.product AS p
    INNER JOIN public.company AS cc ON cc.id = p."companyId"`);
    await queryRunner.query(
      `INSERT INTO "typeorm_metadata"("database", "schema", "table", "type", "name", "value") VALUES (DEFAULT, $1, DEFAULT, $2, $3, $4)`,
      [
        'public',
        'VIEW',
        'vw_product',
        'SELECT p.id, p."companyId", cc.name AS "companyName", p.name, p.image, p.description, p.type, p.price\n\tFROM public.product AS p\n    INNER JOIN public.company AS cc ON cc.id = p."companyId"',
      ],
    );
    await queryRunner.query(`CREATE VIEW "vw_category" AS SELECT DISTINCT ON (ct.id) ct.id, ct.name, ct.image, s.location
	FROM public.company AS c
    INNER JOIN public.store AS s ON s."companyId" = c.id
    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id
    INNER JOIN public.category AS ct ON cc."categoryId" = ct.id;`);
    await queryRunner.query(
      `INSERT INTO "typeorm_metadata"("database", "schema", "table", "type", "name", "value") VALUES (DEFAULT, $1, DEFAULT, $2, $3, $4)`,
      [
        'public',
        'VIEW',
        'vw_category',
        'SELECT DISTINCT ON (ct.id) ct.id, ct.name, ct.image, s.location\n\tFROM public.company AS c \n    INNER JOIN public.store AS s ON s."companyId" = c.id\n    INNER JOIN public.company_category AS cc ON cc."companyId" = c.id\n    INNER JOIN public.category AS ct ON cc."categoryId" = ct.id;',
      ],
    );
  }
}
