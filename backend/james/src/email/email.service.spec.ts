import { OAuth2Client } from 'google-auth-library';
import { createTransport } from 'nodemailer';
import { EmailService } from './email.service';

jest.mock('google-auth-library', () => ({ OAuth2Client: jest.fn() }));
jest.mock('nodemailer', () => ({ createTransport: jest.fn() }));

describe('OAuth mail integration migration', () => {
  const originalTransport = process.env.ACCOUNT_TRANSPORT;
  const originalAppName = process.env.APP_NAME;
  const originalMailFrom = process.env.MAIL_FROM;

  beforeEach(() => {
    process.env.APP_NAME = 'Delivery App';
    delete process.env.MAIL_FROM;
  });

  afterEach(() => {
    jest.resetAllMocks();
    if (originalTransport === undefined) delete process.env.ACCOUNT_TRANSPORT;
    else process.env.ACCOUNT_TRANSPORT = originalTransport;
    if (originalAppName === undefined) delete process.env.APP_NAME;
    else process.env.APP_NAME = originalAppName;
    if (originalMailFrom === undefined) delete process.env.MAIL_FROM;
    else process.env.MAIL_FROM = originalMailFrom;
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
      'Test <User>',
      'recipient@example.test',
      'isolated-<value>&',
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
      expect.objectContaining({
        to: 'Test <User> <recipient@example.test>',
        from: 'Delivery App <sender@example.test>',
        subject: 'Recuperación de tu cuenta Delivery App',
      }),
      expect.any(Function),
    );
    const message = sendMail.mock.calls[0][0];
    expect(message.html).toContain('Test &lt;User&gt;');
    expect(message.html).toContain('isolated-&lt;value&gt;&amp;');
    expect(message.subject).not.toContain('isolated-');

    process.env.APP_NAME = 'Mi Delivery';
    process.env.MAIL_FROM = 'Mi Delivery <my-sender@example.test>';
    new EmailService().sendPassword(
      'Cliente',
      'recipient@example.test',
      'test',
    );
    expect(sendMail).toHaveBeenLastCalledWith(
      expect.objectContaining({
        from: 'Mi Delivery <my-sender@example.test>',
        subject: 'Recuperación de tu cuenta Mi Delivery',
      }),
      expect.any(Function),
    );
  });
});
