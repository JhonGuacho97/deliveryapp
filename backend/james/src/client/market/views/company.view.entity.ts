import { Location } from 'src/common/interfaces/location.interface';
import { ViewColumn, ViewEntity } from 'typeorm';

export const companyViewQuery = `SELECT c.id, s.id AS "storeId", s.name, s.address, s.contact, c.image, s.location,
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
WHERE s."deletedAt" IS NULL`;

@ViewEntity({
  schema: 'public',
  name: 'vw_company',
  expression: companyViewQuery,
})
export class ViewCompany {
  @ViewColumn()
  id: number;

  @ViewColumn()
  storeId: number;

  @ViewColumn()
  isOpen: boolean;

  @ViewColumn()
  name: string;

  @ViewColumn()
  address: string;

  @ViewColumn()
  contact: string;

  @ViewColumn()
  image: string;

  @ViewColumn()
  open: string;

  @ViewColumn()
  close: string;

  @ViewColumn()
  categoryId: string;

  @ViewColumn()
  location: Location;
}
