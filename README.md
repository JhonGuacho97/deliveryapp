# Delivery App

Aplicación de delivery con **NestJS** como backend y **Flutter** como frontend
Android, con vistas para clientes, restaurantes y motorizados.

## Estructura

```text
backend/james/       API NestJS, migraciones, scripts de datos y pruebas
frontend/source/     Aplicación Flutter, recursos y pruebas de interfaz
REVISION_TECNICA.md  Diagnóstico inicial y contexto de las migraciones
```

Ambos componentes forman parte de este repositorio. Los historiales locales
previos se conservaron por separado antes de preparar esta primera publicación.

## Requisitos

- Node.js 24: versión de referencia `24.22.1`; npm según `backend/james/package.json`.
- PostgreSQL con la extensión PostGIS. El entorno local se validó con PostgreSQL 16.
- Flutter `3.47.8` y Dart `3.13.7`, según el SDK de referencia y el lockfile.
- Para Android: SDK con API 36, JDK compatible con Gradle y un emulador o dispositivo.

Android Studio es opcional si ya se dispone del SDK, JDK y emulador.
Los SDK portátiles, dependencias instaladas y archivos de compilación se excluyen
de Git y se deben preparar en cada equipo.

## Backend local

Desde `backend/james`:

```powershell
npm ci
Copy-Item .env.example .env
```

Editar `.env` con los datos de PostgreSQL y un `JWT_SECRET` propio. Para trabajar
localmente sin configurar Firebase, correo y Google Places, establecer:

```dotenv
NODE_ENV=development
EXTERNAL_SERVICES_ENABLED=false
DB_SYNCHRONIZE=false
PAYMENTS_ENABLED=false
PAYMENT_PROVIDER=payphone
STRIPE_ENABLED=false
```

Con PostGIS instalado, preparar una base nueva e iniciar la API:

```powershell
npm run db:setup
npm run start:dev
```

La API local utiliza `http://localhost:3000/api`. `db:setup` aplica las migraciones
y crea un administrador y un cliente. Las credenciales se generan en
`backend/james/.local/credentials.json`, excluido de Git.

Para cargar los ejemplos de los otros roles y el catálogo:

```powershell
npm run db:seed:restaurant
npm run db:seed:courier
npm run db:seed:catalog
```

El catálogo incluye cinco restaurantes, treinta platos y fotografías
ilustrativas de demostración. Los scripts respetan los datos que ya se hayan
editado. Sus credenciales y reportes se guardan en `.local/`.

En Windows, `dev.ps1` usa Node 24 instalado en el equipo o un runtime portátil
en `.tools/`, si existe. Ejemplo: `.\dev.ps1 run start:dev`.

Más detalles: [entorno local](backend/james/ENTORNO_LOCAL.md),
[catálogo de prueba](backend/james/CATALOGO_LOCAL.md),
[restaurantes](backend/james/RESTAURANTES.md) y
[motorizados](backend/james/MOTORIZADOS.md).

## Aplicación Flutter

Instalar el SDK de referencia y, desde `frontend/source`, ejecutar:

```powershell
flutter pub get --enforce-lockfile
flutter run --dart-define-from-file=config/local-emulator.json
```

El perfil del emulador Android se conecta al backend del equipo mediante
`10.0.2.2:3000`. En un teléfono físico se necesita un perfil propio con la IP
local del equipo en `API_BASE_URL` y `SOCKET_URL`.

El lanzador `flutterw.ps1` utiliza `.tools/flutter` cuando está instalado allí,
o Flutter en el PATH como alternativa. Los ajustes de VS Code apuntan al SDK
local; si se usa otro SDK, adaptar `dart.flutterSdkPath` y el PATH de terminal
en `.vscode/settings.json`.

Para Google Maps en Android, copiar `android/maps.properties.example` a
`android/maps.properties` y configurar una clave propia, o definir `MAPS_API_KEY`
en el entorno. `ORDER_MAP_ENABLED` controla el mapa independientemente de los
otros servicios externos. La configuración de Firebase y las firmas de
publicación también deben proporcionarse por separado cuando se usen.

El nombre provisional es **Delivery App**, el paquete Dart es `delivery_app` y
el identificador Android es `com.deliveryapp.mobile`. Android lo considera una
aplicación diferente de las instalaciones anteriores: no se desinstalan ni se
transfieren automáticamente sus sesiones, direcciones locales o carrito.
Registrar este identificador en los proyectos propios de Google Maps y Firebase.
Se ignora cualquier `google-services.json` cuyo paquete no coincida. El perfil
predeterminado usa el backend local y desactiva los servicios externos; para
activarlos, suministrar la configuración propia y `EXTERNAL_SERVICES_ENABLED=true`.
PayPhone es el proveedor preparado para el pago electrónico mediante checkout web
externo. Los pagos tienen su propia activación, independiente de Firebase.
La configuración local admite HTTP en localhost para pruebas. Consultar
[configuración y pruebas de PayPhone](backend/james/PAGOS.md).
Stripe se conserva deshabilitado; para reactivarlo se necesita habilitarlo
explícitamente en backend y Flutter y proporcionar sus claves propias.
Los términos y la privacidad se configuran con `APP_TERMS_URL` y `APP_PRIVACY_URL`.
El backend admite `APP_NAME` y `MAIL_FROM` para personalizar los correos.

Las cuentas de demostración nuevas usan el dominio `delivery.local`; las cuentas
locales ya creadas conservan su correo y contraseña en `.local/`. La limpieza de
identidad no cambia la base indicada por `DB_NAME` ni modifica sus datos.

Consultar [mapas e imágenes](frontend/source/MAPAS_E_IMAGENES.md) y
[migración de Flutter](frontend/source/MIGRACION_FLUTTER.md).

## Verificación

Backend, desde `backend/james`:

```powershell
npm run verify
npm run test:catalog
```

`test:catalog` requiere PostgreSQL local y permisos para crear una base
desechable. Flutter, desde `frontend/source`:

```powershell
.\flutterw.ps1 verify
```

El último cambio de catálogo se comprobó con 150 pruebas Flutter, 97
comprobaciones del catálogo en PostgreSQL, análisis estático y un recorrido
Android contra el backend local. Los detalles y comandos de cada fase están
en la documentación de ambos componentes.

## Interfaz y estado del proyecto

El cliente incorpora búsqueda global de restaurantes y platos, catálogo con
fotografías, menú del restaurante con búsqueda y filtros, detalle de productos
y carrito. Los tres roles utilizan navegación Liquid Glass y la paleta salvia.
El seguimiento del pedido mantiene el mapa y las actualizaciones Socket.IO.

- [Catálogo visual](frontend/source/CATALOGO_VISUAL.md)
- [Navegación Liquid Glass](frontend/source/NAVEGACION_GLASS.md)
- [Formularios](frontend/source/FORMULARIOS.md)
- [Rediseño por roles](frontend/source/REDISENO_UI.md)
- [Migración del backend](backend/james/MIGRACION.md)

Las pruebas con proveedores externos y cobros reales se describen como
pendientes en los documentos de migración. Esta publicación corresponde al
entorno de desarrollo.

Los avisos del código base de backend y frontend se reúnen en
[THIRD_PARTY_NOTICES.txt](THIRD_PARTY_NOTICES.txt), en la raíz. Se conserva también
la [licencia de Inter](frontend/source/assets/fonts/OFL.txt). Flutter incorpora
el archivo común en los avisos de software de la app; el build del backend lo
copia en `dist/` para acompañar los compilados. Si se distribuye un componente
por separado, debe incluirse también el archivo común.
