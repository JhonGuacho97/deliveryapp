import { Controller, Get, Header, Param, Query, Res } from '@nestjs/common';
import type { Response } from 'express';
import { PaymentsService } from './payments.service';
import { StatusPayment } from '../../common/glob/status';
import { isPayphoneCheckout } from './payment-gateways';

const escapeHtml = (value: string) =>
  value.replace(
    /[&<>"']/g,
    (char) =>
      ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[
        char
      ],
  );

function page(title: string, content: string) {
  return `<!doctype html><html lang="es"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>${escapeHtml(title)}</title><style>body{margin:0;background:#f7f7f2;color:#202a25;font:16px system-ui,sans-serif}main{max-width:440px;margin:8vh auto;padding:24px}h1{font-size:26px}p{line-height:1.6}a{display:block;padding:16px;margin:16px 0;background:#35695a;color:white;border-radius:16px;text-align:center;text-decoration:none}.secondary{background:white;color:#35695a;border:1px solid #dfe5df}</style></head><body><main>${content}</main></body></html>`;
}

@Controller('client/payments/payphone')
export class PayphoneController {
  constructor(private readonly payments: PaymentsService) {}

  @Get('start/:clientTransactionId')
  @Header('Content-Type', 'text/html; charset=utf-8')
  @Header('Cache-Control', 'no-store')
  @Header('Referrer-Policy', 'origin')
  @Header(
    'Content-Security-Policy',
    "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; frame-ancestors 'none'",
  )
  async start(@Param('clientTransactionId') reference: string) {
    const checkout = await this.payments.checkout(reference);
    if (!checkout.links)
      return page(
        'Estado del pago',
        '<h1>Revisa tu pago en la app</h1><p>Este enlace ya tiene un resultado. Puedes volver a Delivery App para continuar.</p>',
      );
    const { card, payphone } = checkout.links;
    if (!isPayphoneCheckout(card) || !isPayphoneCheckout(payphone))
      return page(
        'Pago no disponible',
        '<h1>El enlace no está disponible</h1><p>Vuelve a la aplicación para retomar el pago.</p>',
      );
    return page(
      'Pagar con PayPhone',
      `<h1>Completa tu pago</h1><p>Total: <strong>${checkout.money.toFixed(2)} USD</strong></p><a href="${escapeHtml(card)}">Tarjeta de débito o crédito</a><a class="secondary" href="${escapeHtml(payphone)}">Pagar con PayPhone</a><p>Al terminar podrás volver a Delivery App. El resultado se verificará antes de acreditar el saldo.</p>`,
    );
  }

  @Get('return')
  async result(
    @Query('id') id: string,
    @Query('clientTransactionId') reference: string,
    @Res() response: Response,
  ) {
    response.set({
      'Cache-Control': 'no-store',
      'Referrer-Policy': 'no-referrer',
      'Content-Security-Policy':
        "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; frame-ancestors 'none'",
    });
    try {
      const payment = await this.payments.payphoneReturn(id, reference);
      const confirmed = payment.status === StatusPayment.CONFIRMED;
      const canceled = payment.status === StatusPayment.CANCELLED;
      const title = confirmed
        ? 'Pago confirmado'
        : canceled
          ? 'Pago no aprobado'
          : 'Pago pendiente';
      return response
        .type('html')
        .send(
          page(
            title,
            `<h1>${title}</h1><p>${confirmed ? 'El pago se verificó correctamente. Vuelve a Delivery App para continuar con tu pedido.' : canceled ? 'No se acreditó saldo. Puedes volver a la aplicación.' : 'Todavía no hay una confirmación. Vuelve a la app para revisar el estado.'}</p>`,
          ),
        );
    } catch {
      // No provider payload, token, callback reference or customer data in HTML.
      return response
        .status(503)
        .type('html')
        .send(
          page(
            'Verificación pendiente',
            '<h1>Verificación pendiente</h1><p>No pudimos comprobar el resultado todavía. Vuelve a la app para reintentar la verificación. No es necesario iniciar otro pago.</p>',
          ),
        );
    }
  }
}
