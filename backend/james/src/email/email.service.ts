import { Injectable, Logger, NotImplementedException } from '@nestjs/common';
import { CreateEmailDto } from './dto/create-email.dto';
import { createTransport, Transporter } from 'nodemailer';
import { OAuth2Client } from 'google-auth-library';
import {
  externalServicesEnabled,
  requireExternalServices,
} from '../config/external-services';

function escapeHtml(value: string): string {
  return value.replace(
    /[&<>"']/g,
    (character) =>
      ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;',
      })[character],
  );
}

@Injectable()
export class EmailService {
  private readonly logger = new Logger('EmailService');
  private readonly appName = process.env.APP_NAME?.trim() || 'Delivery App';
  private readonly mailFrom: string;
  private readonly emailTransport: (
    callback: (transporter: Transporter) => void,
  ) => void;

  constructor() {
    if (!externalServicesEnabled()) return;
    const accountTransport = JSON.parse(process.env.ACCOUNT_TRANSPORT);
    this.mailFrom =
      process.env.MAIL_FROM?.trim() ||
      `${this.appName} <${accountTransport.auth.user}>`;
    this.emailTransport = (callback) => {
      const oauth2Client = new OAuth2Client(
        accountTransport.auth.clientId,
        accountTransport.auth.clientSecret,
        'https://developers.google.com/oauthplayground',
      );
      oauth2Client.setCredentials({
        refresh_token: accountTransport.auth.refreshToken,
      });
      oauth2Client.getAccessToken((error, token) => {
        if (error) return this.logger.error(error);
        accountTransport.auth.accessToken = token;
        callback(createTransport(accountTransport));
      });
    };
  }

  create(_createEmailDto: CreateEmailDto) {
    throw new NotImplementedException(
      'Use el flujo de recuperación de cuenta.',
    );
  }

  sendPassword(fullName: string, email: string, password: string) {
    requireExternalServices();
    this.emailTransport((transporter) => {
      transporter.sendMail(
        {
          from: this.mailFrom,
          to: fullName + ' <' + email + '>',
          subject: `Recuperación de tu cuenta ${this.appName}`,
          text: `Hola ${fullName}. Tu contraseña de recuperación de ${this.appName} es: ${password}. Si no solicitaste este cambio, contacta al soporte de la aplicación.`,
          html: `<!DOCTYPE html><html lang="es"><head><meta charset="utf-8"><title>${escapeHtml(this.appName)}</title></head>
          <body style="margin:0;padding:32px;background:#f6f8f5;font-family:Arial,sans-serif;color:#202a25">
            <main style="max-width:560px;margin:auto;padding:32px;background:#fff;border-radius:20px">
              <h1 style="font-size:24px">${escapeHtml(this.appName)}</h1>
              <p>Hola ${escapeHtml(fullName)},</p>
              <p>Tu contraseña de recuperación es:</p>
              <p style="font-size:24px;font-weight:bold;color:#35695a">${escapeHtml(password)}</p>
              <p>Si no solicitaste este cambio, contacta al soporte de la aplicación.</p>
            </main>
          </body></html>`,
        },
        () => {},
      );
    });
  }
}
