import * as bcrypt from 'bcrypt';
import { AuthService } from './auth.service';

describe('Local password authentication', () => {
  let service: AuthService;
  const password = bcrypt.hashSync('ValidLocal123!', 4);
  const sessions = {
    delete: jest.fn(),
    create: jest.fn((data) => data),
    save: jest.fn(),
  };
  const users = { findOne: jest.fn() };
  const login = {
    email: 'client@example.test',
    password: 'ValidLocal123!',
    idDevice: '0a824db1-708e-4bf1-a50d-76c441073069',
    tokenPush: undefined,
  };
  beforeEach(() => {
    jest.clearAllMocks();
    users.findOne.mockResolvedValue({
      id: 1,
      email: login.email,
      roles: ['client'],
      password,
      passwordTemporary: null,
    });
    service = new AuthService(
      users as never,
      sessions as never,
      {} as never,
      { sign: () => 'fixture-token' } as never,
    );
  });
  it('authenticates a new account without a temporary password', async () => {
    const result = await service.login(login);
    expect(result.token).toBe('fixture-token');
    expect(result.password).toBeUndefined();
    expect(result.passwordTemporary).toBeUndefined();
    expect(sessions.save).toHaveBeenCalledTimes(1);
  });
  it('rejects incorrect passwords with 401 instead of calling bcrypt with null', async () => {
    await expect(
      service.login({ ...login, password: 'Incorrect123!' }),
    ).rejects.toMatchObject({ status: 401 });
    expect(sessions.save).not.toHaveBeenCalled();
  });
  it('still accepts an existing temporary password', async () => {
    users.findOne.mockResolvedValue({
      id: 1,
      email: login.email,
      roles: ['client'],
      password,
      passwordTemporary: bcrypt.hashSync('Temporary123!', 4),
    });
    await expect(
      service.login({ ...login, password: 'Temporary123!' }),
    ).resolves.toMatchObject({ token: 'fixture-token' });
  });
});
