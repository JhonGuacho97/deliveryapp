import { User } from 'src/auth/entities/user.entity';
import { StatusPayment } from 'src/common/glob/status';
import {
  Column,
  CreateDateColumn,
  Entity,
  Index,
  ManyToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import type { PaymentProvider } from '../payment-policy';

@Entity()
@Index('IDX_payment_client_transaction', ['clientTransactionId'], {
  unique: true,
})
@Index(
  'IDX_payment_provider_transaction',
  ['provider', 'providerTransactionId'],
  { unique: true },
)
@Index('IDX_payment_pending_amount', ['userId', 'provider', 'amountCents'], {
  unique: true,
  where: '"status" = 1 AND "provider" = \'payphone\'',
})
export class Payment {
  @PrimaryGeneratedColumn('increment')
  id: number;

  @Column('float')
  money: number;

  @Column('varchar', { length: 16, default: 'stripe' })
  provider: PaymentProvider;

  @Column('int', { nullable: true })
  amountCents: number | null;

  @Column('varchar', { length: 64, nullable: true })
  clientTransactionId: string | null;

  @Column('varchar', { length: 128, nullable: true })
  providerTransactionId: string | null;

  @Column('timestamptz', { nullable: true })
  creditedAt: Date | null;

  @Column('int', { nullable: true })
  userId: number | null;

  @Column('smallint', { default: StatusPayment.STARTED })
  status: number;

  @Column('text')
  currency: string;

  @Column('json')
  products: JSON;

  @Column('json')
  response: Record<string, unknown>;

  @CreateDateColumn({ type: 'timestamptz', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamptz', onUpdate: 'CURRENT_TIMESTAMP' })
  updatedAt: Date;

  @ManyToOne(() => User, (user) => user.payments, { onDelete: 'SET NULL' })
  user: User;
}
