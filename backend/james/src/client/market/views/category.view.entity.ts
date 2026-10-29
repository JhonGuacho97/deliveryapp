import { ViewColumn, ViewEntity } from 'typeorm';

export const categoryViewQuery = `SELECT ct.id, ct.name, ct.image, s.location
FROM public.company c
INNER JOIN public.store s ON s."companyId" = c.id
INNER JOIN public.company_category cc ON cc."companyId" = c.id
INNER JOIN public.category ct ON cc."categoryId" = ct.id
WHERE s."deletedAt" IS NULL`;

@ViewEntity({
  schema: 'public',
  name: 'vw_category',
  expression: categoryViewQuery,
})
export class ViewCategory {
  @ViewColumn()
  id: number;

  @ViewColumn()
  name: string;

  @ViewColumn()
  image: string;
}
