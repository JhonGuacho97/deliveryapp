import { LocationWsGateway } from './location-ws.gateway';
describe('courier location permissions', () => {
  const actor = { id: 7, idDevice: 'device-a', roles: ['deliveryman'] };
  let service: any,
    gateway: LocationWsGateway,
    socket: any,
    emit: jest.Mock,
    to: jest.Mock;
  beforeEach(() => {
    service = {
      registerUser: jest.fn(),
      canWatch: jest.fn().mockResolvedValue(true),
      updateLocation: jest.fn().mockResolvedValue(true),
      watcherIds: jest.fn().mockResolvedValue([7, 9]),
    };
    emit = jest.fn();
    to = jest.fn().mockReturnValue({ emit });
    gateway = new LocationWsGateway(service, {
      verify: () => ({ id: 7, idDevice: 'device-a' }),
    } as any);
    gateway.server = { to } as any;
    socket = {
      isAuth: true,
      data: { actor },
      handshake: { headers: { auth: 'jwt', iduserdeliverymen: '7' } },
      join: jest.fn(),
      disconnect: jest.fn(),
    };
  });
  it('binds the socket to the verified device', async () => {
    await gateway.handleConnection(socket);
    expect(service.registerUser).toHaveBeenCalledWith(socket, 7, 'device-a');
    expect(socket.join).toHaveBeenCalledWith('courier:7:viewer:7');
  });
  it('rejects a foreign courier subscription', async () => {
    service.canWatch.mockResolvedValue(false);
    await gateway.handleConnection(socket);
    expect(socket.disconnect).toHaveBeenCalled();
    expect(socket.join).not.toHaveBeenCalled();
  });
  it('ignores forged user IDs and invalid coordinates', async () => {
    await gateway.handleEvent(socket, { id: 8, p: [0, 0] });
    await gateway.handleEvent(socket, { id: 7, p: [91, 0] });
    await gateway.handleEvent(socket, { id: 7, p: [NaN, 0] });
    expect(service.updateLocation).not.toHaveBeenCalled();
  });
  it('writes only to the authenticated device and authorized viewers', async () => {
    await gateway.handleEvent(socket, { id: 7, p: [-4, -79] });
    expect(service.updateLocation).toHaveBeenCalledWith(
      7,
      'device-a',
      [-4, -79],
    );
    expect(to.mock.calls).toEqual([
      ['courier:7:viewer:7'],
      ['courier:7:viewer:9'],
    ]);
  });
  it('revokes completed delivery viewers and revoked sessions', async () => {
    service.watcherIds.mockResolvedValue([7]);
    await gateway.handleEvent(socket, { id: 7, p: [0, 0] });
    expect(to).toHaveBeenCalledTimes(1);
    service.updateLocation.mockResolvedValue(false);
    to.mockClear();
    await gateway.handleEvent(socket, { id: 7, p: [0, 0] });
    expect(to).not.toHaveBeenCalled();
  });
});
