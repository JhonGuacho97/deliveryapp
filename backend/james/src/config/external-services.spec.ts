import {
  externalServicesEnabled,
  requireExternalServices,
} from './external-services';
import { AddressService } from '../client/address/address.service';
import { PaymentsService } from '../client/payments/payments.service';
import { EmailService } from '../email/email.service';

describe('Offline local development', () => {
  const original = process.env.EXTERNAL_SERVICES_ENABLED;
  beforeEach(() => {
    process.env.EXTERNAL_SERVICES_ENABLED = 'false';
  });
  afterEach(() => {
    if (original === undefined) delete process.env.EXTERNAL_SERVICES_ENABLED;
    else process.env.EXTERNAL_SERVICES_ENABLED = original;
  });

  it('only disables integrations when explicitly configured', () => {
    expect(externalServicesEnabled()).toBe(false);
    expect(requireExternalServices).toThrow('External services are disabled');
    delete process.env.EXTERNAL_SERVICES_ENABLED;
    expect(externalServicesEnabled()).toBe(true);
  });
  it('blocks Google Places requests before making HTTP calls', async () => {
    const service = new AddressService({} as never);
    await expect(service.geocode('fixture')).rejects.toMatchObject({
      status: 503,
    });
    await expect(
      service.autocomplete('Calle', { latitude: -0.2, longitude: -78.5 }),
    ).rejects.toMatchObject({ status: 503 });
  });
  it('blocks Stripe creation and confirmation before accessing repositories', async () => {
    const service = new PaymentsService({} as never, {} as never);
    await expect(
      service.create({} as never, {} as never),
    ).rejects.toMatchObject({ status: 503 });
    await expect(service.confirm({} as never, 1)).rejects.toMatchObject({
      status: 503,
    });
  });
  it('does not require OAuth configuration to start offline', () => {
    const service = new EmailService();
    expect(() =>
      service.sendPassword('Fixture', 'test@example.test', 'unused'),
    ).toThrow('External services are disabled');
  });
});
