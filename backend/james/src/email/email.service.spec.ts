import { OAuth2Client } from 'google-auth-library';
import { createTransport } from 'nodemailer';
import { EmailService } from './email.service';

jest.mock('google-auth-library', () => ({ OAuth2Client: jest.fn() }));
jest.mock('nodemailer', () => ({ createTransport: jest.fn() }));

describe('OAuth mail integration migration', () => {
  const originalTransport = process.env.ACCOUNT_TRANSPORT;

  afterEach(() => {
    jest.resetAllMocks();
    if (originalTransport === undefined) delete process.env.ACCOUNT_TRANSPORT;
    else process.env.ACCOUNT_TRANSPORT = originalTransport;
  });

  it('refreshes OAuth credentials and passes the token to Nodemailer', () => {
    process.env.ACCOUNT_TRANSPORT = JSON.stringify({
      service: 'gmail',
      auth: {
        type: 'OAuth2',
        user: 'sender@example.test',
        clientId: 'test-client',
        clientSecret: 'test-secret',
        refreshToken: 'test-refresh',
      },
    });
    const setCredentials = jest.fn();
    const getAccessToken = jest.fn((callback) =>
      callback(null, 'isolated-access-token'),
    );
    (OAuth2Client as unknown as jest.Mock).mockImplementation(() => ({
      setCredentials,
      getAccessToken,
    }));
    const sendMail = jest.fn();
    (createTransport as jest.Mock).mockReturnValue({ sendMail });

    new EmailService().sendPassword(
      'Test User',
      'recipient@example.test',
      'isolated-value',
    );

    expect(setCredentials).toHaveBeenCalledWith({
      refresh_token: 'test-refresh',
    });
    expect(createTransport).toHaveBeenCalledWith(
      expect.objectContaining({
        auth: expect.objectContaining({ accessToken: 'isolated-access-token' }),
      }),
    );
    expect(sendMail).toHaveBeenCalledWith(
      expect.objectContaining({ to: 'Test User <recipient@example.test>' }),
      expect.any(Function),
    );
  });
});
