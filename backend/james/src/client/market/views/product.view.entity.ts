import { ViewColumn, ViewEntity } from 'typeorm';

export const productViewQuery = `SELECT p.id, p."companyId", cc.name AS "companyName", p.name, p.image, p.description, p.type, p.price
FROM public.product p INNER JOIN public.company cc ON cc.id = p."companyId"
WHERE p."deletedAt" IS NULL`;

@ViewEntity({
  schema: 'public',
  name: 'vw_product',
  expression: productViewQuery,
})
export class ViewProduct {
  @ViewColumn()
  id: number;

  @ViewColumn({ name: 'companyId' })
  companyId: number;

  @ViewColumn({ name: 'companyName' })
  companyName: string;

  @ViewColumn()
  name: string;

  @ViewColumn()
  description: string;

  @ViewColumn()
  type: number;

  @ViewColumn()
  price: number;

  @ViewColumn()
  image: string;
}
