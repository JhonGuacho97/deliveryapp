# Motorizados — fase UI y flujo de reparto

La aplicación Flutter usa Entregas / Ingresos / Cuenta. Las ofertas muestran la ganancia estimada del motorizado, retiro, destino, forma de pago y distancias. Después de aceptar, la ganancia corresponde a la comisión guardada en el pedido, aunque cambie posteriormente el porcentaje de la cuenta.

## Contrato

Todos los endpoints requieren JWT y rol `deliveryman`, y utilizan la sesión del dispositivo incluido en el token.

| Operación | Endpoint | Comportamiento |
| --- | --- | --- |
| Disponibilidad | `PATCH deliveryman/petition/activate` | Valida `idDevice`, `isOnline`, latitud y longitud. Desconectar conserva la última ubicación. |
| Entregas | `GET deliveryman/petition/near?idDevice=UUID` | Ofertas cuando la sesión está disponible; siempre incluye las entregas activas propias. |
| Detalle | `GET deliveryman/petition/id/:id` | Oferta accesible o pedido asignado al usuario. Oculta el teléfono del cliente antes de aceptar. |
| Aceptar | `PATCH deliveryman/petition/apply/:id` | Necesita disponibilidad, ubicación y cocina aceptada; guarda ganancias y comisión en una transacción. |
| Retirar | `PATCH deliveryman/petition/collect/:id` | Solo el asignado; necesita cocina lista para los pedidos nuevos. |
| Entregar | `PATCH deliveryman/petition/deliver/:id` | Solo después del retiro; cuerpo `{}`. No genera una calificación automática. |
| Cancelar | `PATCH deliveryman/petition/cancel/:id` | Solo el asignado antes del retiro. Cancela el pedido del cliente, no libera una oferta para reasignarla. |
| Ingresos | `GET deliveryman/petition/earnings/YYYY-MM-DD` | Cuenta y suma entregas completadas por `deliveredAt`, usando `America/Guayaquil`. Devuelve también entregas, saldo operativo e importe de liquidación registrado. |
| Historial | `GET deliveryman/petition/ordered-at/YYYY-MM-DD` | Pedidos propios por fecha de creación del pedido; conserva acceso a pedidos antiguos sin fecha de entrega. |

Las respuestas de pedidos añaden `isAssignedToMe`, `estimatedProfit`, `pickupDistanceMeters` y `tripDistanceMeters`. Las distancias son geodésicas en línea recta y respetan los puntos históricos con latitud en `x` y longitud en `y`. No son rutas por carretera ni tiempos estimados. El radio comercial existente de `FilterKM.DELIVERYMAN` se conserva.

Las transiciones bloquean el pedido y los saldos afectados para evitar doble asignación, doble comisión y reembolsos duplicados. En efectivo se descuenta la comisión del saldo operativo; en pagos electrónicos se registra la ganancia en `amount`. Cancelar revierte esos importes y, cuando corresponde, devuelve el total a la billetera del cliente. Una notificación push fallida no revierte una operación confirmada.

Socket.IO verifica sesión y usuario. El evento `l` solo acepta coordenadas válidas del propio motorizado y actualiza exclusivamente el dispositivo autenticado. Los clientes pueden suscribirse al motorizado de su pedido activo; los destinatarios se comprueban de nuevo en cada actualización, por lo que los pedidos finalizados dejan de recibir ubicación.

## Migración y compatibilidad

`CourierLifecycle1793300000000` añade `assignedAt`, `collectedAt`, `deliveredAt` y `cancelledAt`, todas opcionales. No inventa fechas para pedidos previos. Los códigos de estado y las rutas anteriores se conservan. Los pedidos antiguos con preparación nula siguen pudiendo retirarse.

La ganancia diaria excluye cancelaciones y pedidos sin fecha de entrega. Las entregas sin importe de ganancia se cuentan y se informan con `unpricedCount`, sin fabricar una cantidad. `settlementAmount` es el registro contable existente y no acredita una transferencia bancaria.

## Demostración local

```powershell
.\dev.ps1 run build
.\dev.ps1 run migration:run
.\dev.ps1 run db:seed:courier
```

Requiere haber creado primero la demostración de restaurante. Genera `motorizado.demo@delivery.local`, guarda la contraseña aleatoria en `.local/courier-credentials.json` y añade **20 USD de saldo operativo de demostración** y un pedido en efectivo listo para retirar. No realiza cobros externos. Es local, idempotente y no reinicia pedidos ni cambia cuentas existentes.

La prueba Android contra el backend inicia sesión y consulta el pedido sin aceptarlo ni consumir ese saldo. El APK normal no incorpora las credenciales de las pruebas.

## Validación del 28 de octubre de 2026

- `dev.ps1 run verify`: compilación, tipos, lint, 39 pruebas unitarias y 17 HTTP.
- `dev.ps1 run test:courier`: 58 comprobaciones con NestJS y PostgreSQL desechable. Incluye dos motorizados compitiendo, un mismo saldo compitiendo por dos pedidos, fallo SQL inducido después del débito con rollback completo, dispositivos distintos, permisos, preparación, reintentos, cancelaciones e ingresos.
- `dev.ps1 run test:restaurant`: 41 comprobaciones de regresión de cocina, menú y horarios.
- `dev.ps1 run test:db`: cuatro migraciones reversibles, reaplicación y cero diferencias con entidades.
- `dev.ps1 run test:local`: 25 comprobaciones del entorno local.
- Flutter: 92 pruebas de unidad/widgets, 8 contratos con NestJS, 2 del perfil local y dos recorridos Android: flujo completo controlado y login/GPS/lectura contra el backend local. Detalles en `frontend/source/REDISENO_UI.md`.

Las llamadas y la navegación abren aplicaciones del dispositivo a petición del usuario. Las pruebas no llaman teléfonos, envían mensajes ni realizan transferencias. Push, cobros y otros servicios externos requieren sus entornos de prueba configurados.
