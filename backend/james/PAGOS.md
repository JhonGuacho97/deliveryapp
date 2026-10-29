# Pagos: PayPhone y Stripe

PayPhone es el proveedor seleccionado. Stripe conserva su implementación y su
historial, y queda deshabilitado con `STRIPE_ENABLED=false` en ambos componentes.
`PAYMENTS_ENABLED` controla únicamente pagos: no exige activar Firebase, correo
ni Google Places. La configuración inicial mantiene los pagos electrónicos
apagados hasta que se proporcionen las credenciales.

## Configuración local de pruebas

En PayPhone Developer, elegir una aplicación WEB de Botón de pago y seleccionar
el entorno **de pruebas**. Registrar el origen `http://localhost:3000` y esta
URL de respuesta:

```text
http://localhost:3000/api/client/payments/payphone/return
```

En el `.env` del backend, guardar las credenciales propias y habilitar:

```dotenv
PAYMENTS_ENABLED=true
PAYMENT_PROVIDER=payphone
STRIPE_ENABLED=false
PAYPHONE_MODE=test
PAYPHONE_TOKEN=tu-token-de-pruebas
PAYPHONE_STORE_ID=tu-store-id
PAYPHONE_RESPONSE_URL=http://localhost:3000/api/client/payments/payphone/return
```

`PAYPHONE_MODE=test` valida las URLs locales de esta aplicación. **No cambia el
modo de la cuenta en PayPhone**: debe seleccionarse también en Developer. El
token queda en el servidor, nunca en Flutter ni en archivos versionados.

Aplicar las migraciones y reiniciar el backend:

```powershell
.\dev.ps1 run build
.\dev.ps1 run migration:run
.\dev.ps1 run local:stop
.\dev.ps1 run local:start
```

Para el emulador Android, desde PowerShell:

```powershell
& "$env:LOCALAPPDATA\Android\sdk\platform-tools\adb.exe" -s emulator-5554 reverse tcp:3000 tcp:3000
```

El navegador del emulador podrá visitar `http://localhost:3000`; Flutter sigue
usando `http://10.0.2.2:3000/api/` con `config/local-emulator.json`. Repetir el
comando al reiniciar el emulador. Si hay varios dispositivos, usar su serial.
Esta conexión depende de ADB: no sirve como URL de un despliegue público.

En el carrito elegir **Tarjeta o PayPhone / saldo**, abrir PayPhone, completar el
pago en su navegador y volver a la app. El retorno confirma el pago en el
backend sin depender de que Flutter esté en primer plano. El botón «Ya pagué,
verificar» vuelve a consultar al servidor; no acredita dinero por sí mismo.

## Flujo y controles

1. El cliente autenticado solicita una sesión de pago en USD. El backend envía
   centavos enteros y una referencia aleatoria a `button/Prepare`.
2. Flutter abre una página del backend. Esa página envía al checkout de PayPhone
   con el origen registrado como referente; no publica el token. Este es un
   checkout WEB externo, no un SDK móvil de Cajita ni un formulario nativo.
3. El retorno recibe `id` y `clientTransactionId`; esos parámetros no son prueba
   de pago. El servidor consulta `button/V2/Confirm` y compara referencia,
   identificador, importe y moneda.
4. Solamente un resultado aprobado acredita el saldo del cliente. La escritura
   del saldo y el estado del pago comparten una transacción y bloqueo en
   PostgreSQL. Retornos repetidos no vuelven a acreditar dinero.
5. Cerrar el navegador deja la sesión pendiente. Se reutiliza al volver a
   solicitar el mismo importe. Una caída temporal de la verificación conserva
   la referencia de retorno para reintentar desde el estado autenticado.

La confirmación de PayPhone debe ejecutarse dentro de cinco minutos después del
pago; de otro modo PayPhone indica que lo reversa automáticamente. Si el usuario
no llega al retorno, la aplicación no inventa una confirmación. Una sesión cuyo
estado no se pueda verificar permanece pendiente para su revisión; no hay un
proceso automático de conciliación ni se declara cancelada por cerrar la app.

El flujo mantiene el monedero existente: primero acredita saldo y luego el
carrito paga los pedidos con ese saldo. No distribuye dinero automáticamente a
restaurantes o motorizados ni cambia sus comisiones. El importe enviado como
`amountWithoutTax` corresponde a la recarga de saldo del flujo existente; la
facturación de pedidos e impuestos requiere una definición contable aparte.
La validación del precio final de los pedidos en el servidor y su conciliación
completa siguen siendo trabajo pendiente antes de habilitar cobros de producción.

## Pruebas y despliegue

```powershell
.\dev.ps1 run verify
.\dev.ps1 run test:db
.\dev.ps1 run test:payments
```

`test:payments` crea una base temporal local, aplica las migraciones y usa un
proveedor simulado. Cubre permisos, reutilización concurrente, datos que no
coinciden, rechazo, reintentos, confirmación repetida, incrementos simultáneos,
rollback y conservación del historial de Stripe. Elimina solamente su base
temporal al terminar. Las pruebas no cobran ni contactan PayPhone.

Las pruebas de Flutter están en `test/payments/`. La validación de la cuenta
PayPhone, el dominio registrado y un pago de su sandbox debe hacerse cuando
se configuren las credenciales propias.

En producción se requiere `NODE_ENV=production`, `PAYPHONE_MODE=production`,
URL HTTPS y credenciales del entorno correcto. El backend rechaza HTTP allí.
Para reactivar Stripe: `PAYMENTS_ENABLED=true`, `PAYMENT_PROVIDER=stripe`,
`STRIPE_ENABLED=true`, `STRIPE_SECRET_KEY` en backend; `STRIPE_ENABLED=true` y
`STRIPE_PUBLISHABLE_KEY` en el perfil Flutter. Los cobros también se verifican
contra Stripe antes de acreditar saldo.

Fuente: [documentación oficial del Botón de pago PayPhone](https://docs.payphone.app/boton-de-pago).
