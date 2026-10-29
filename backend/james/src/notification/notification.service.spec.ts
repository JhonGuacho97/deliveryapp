import { cert, getApps, initializeApp } from 'firebase-admin/app';
import { getMessaging } from 'firebase-admin/messaging';
import { NotificationService } from './notification.service';

jest.mock('firebase-admin/app', () => ({
  cert: jest.fn(),
  getApps: jest.fn(),
  initializeApp: jest.fn(),
}));
jest.mock('firebase-admin/messaging', () => ({ getMessaging: jest.fn() }));

describe('Firebase Admin messaging migration', () => {
  const sendEachForMulticast = jest.fn();
  const query = { select: jest.fn(), where: jest.fn(), getMany: jest.fn() };
  const sessions = { createQueryBuilder: jest.fn(() => query) };
  const originalCredentials = process.env.FIREBASE_CREDENTIAL_JSON;
  let service: NotificationService;

  beforeEach(() => {
    jest.resetAllMocks();
    process.env.FIREBASE_CREDENTIAL_JSON = '{}';
    query.select.mockReturnValue(query);
    query.where.mockReturnValue(query);
    sessions.createQueryBuilder.mockReturnValue(query);
    (getApps as jest.Mock).mockReturnValue([]);
    (initializeApp as jest.Mock).mockReturnValue({ name: 'isolated-app' });
    (getMessaging as jest.Mock).mockReturnValue({ sendEachForMulticast });
    sendEachForMulticast.mockResolvedValue({
      successCount: 1,
      failureCount: 0,
      responses: [],
    });
    service = new NotificationService(sessions as never, {} as never);
  });

  afterAll(() => {
    if (originalCredentials === undefined)
      delete process.env.FIREBASE_CREDENTIAL_JSON;
    else process.env.FIREBASE_CREDENTIAL_JSON = originalCredentials;
  });

  it('uses the supported multicast API and preserves the data payload and TTL', async () => {
    query.getMany.mockResolvedValue([
      { tokenPush: 'device-token' },
      { tokenPush: null },
      { tokenPush: '' },
    ]);
    const data = { type: '1010', orderId: '7' };
    await service.notify(1, data);
    expect(sendEachForMulticast).toHaveBeenCalledWith({
      tokens: ['device-token'],
      data,
      android: { ttl: 0 },
    });
  });

  it('does not call Firebase when no devices are registered', async () => {
    query.getMany.mockResolvedValue([]);
    await service.notify(1, { type: '1010' });
    expect(sendEachForMulticast).not.toHaveBeenCalled();
  });

  it('propagates send failures so callers can handle them', async () => {
    query.getMany.mockResolvedValue([{ tokenPush: 'device-token' }]);
    sendEachForMulticast.mockRejectedValue(new Error('isolated send failure'));
    await expect(service.notify(1, {})).rejects.toThrow(
      'isolated send failure',
    );
  });

  it('reuses the initialized Firebase app', () => {
    (getApps as jest.Mock).mockReturnValue([{ name: 'existing-app' }]);
    jest.mocked(initializeApp).mockClear();
    jest.mocked(cert).mockClear();
    new NotificationService(sessions as never, {} as never);
    expect(initializeApp).not.toHaveBeenCalled();
    expect(cert).not.toHaveBeenCalled();
  });

  it('preserves the final delivery notification attempt without scheduling further retries', async () => {
    await service.sendOrder(7, ['delivery-device'], { type: '1010' }, 4);
    expect(sendEachForMulticast).toHaveBeenCalledTimes(1);
  });

  it('notifies the kitchen without advertising a pending order to riders', async () => {
    const orders = {
      select: jest.fn(),
      innerJoin: jest.fn(),
      where: jest.fn(),
      getOne: jest.fn(),
    };
    orders.select.mockReturnValue(orders);
    orders.innerJoin.mockReturnValue(orders);
    orders.where.mockReturnValue(orders);
    orders.getOne.mockResolvedValue({ store: { user: { id: 3 } } });
    const kitchen = new NotificationService(
      sessions as never,
      { createQueryBuilder: () => orders } as never,
    );
    const riders = jest.spyOn(kitchen, 'notifyDeliverymen').mockResolvedValue();
    const owner = jest.spyOn(kitchen, 'notify').mockResolvedValue();
    const data = { type: '1010', orderId: '7' };
    await kitchen.notifyOrder(7, -0.2, -78.5, data, false);
    expect(riders).not.toHaveBeenCalled();
    expect(owner).toHaveBeenCalledWith(3, data);
  });

  it('starts and stays offline when integrations are explicitly disabled', async () => {
    const original = process.env.EXTERNAL_SERVICES_ENABLED;
    process.env.EXTERNAL_SERVICES_ENABLED = 'false';
    jest.mocked(initializeApp).mockClear();
    sessions.createQueryBuilder.mockClear();
    try {
      const offline = new NotificationService(sessions as never, {} as never);
      await offline.notify(1, { type: '1010' });
      await offline.notifyOrder(1, -0.2, -78.5, { type: '1010' });
      await offline.sendOrder(1, ['unused'], { type: '1010' }, 0);
      expect(initializeApp).not.toHaveBeenCalled();
      expect(sendEachForMulticast).not.toHaveBeenCalled();
      expect(sessions.createQueryBuilder).not.toHaveBeenCalled();
    } finally {
      if (original === undefined) delete process.env.EXTERNAL_SERVICES_ENABLED;
      else process.env.EXTERNAL_SERVICES_ENABLED = original;
    }
  });
});
