# Entorno local

Preparado el 28 de octubre de 2026 con PostgreSQL 16 y PostGIS, sin Docker.

| Componente | Configuración |
| --- | --- |
| Base | la base configurada en `.env`, en `localhost:5432` |
| API | `http://localhost:3000/api` |
| API desde Android Emulator | `http://10.0.2.2:3000/api/` |
| Administrador | `admin@delivery.local`, roles `admin` y `client` |
| Cliente | `cliente@delivery.local`, rol `client` |
| Restaurante de prueba | `restaurante.demo@delivery.local`, rol `manager` |
| Contraseñas | `.local/credentials.json`, generado y excluido de Git |
| Contraseña del restaurante | `.local/restaurant-credentials.json`, excluido de Git |

Los usuarios están activos y tienen su registro de saldo inicial en cero. La fase de restaurantes añade un negocio, un producto y un pedido identificados como demostración local, sin procesar pagos. El seed inicial de administrador y cliente conserva su comportamiento; la demostración se prepara con `dev.ps1 run db:seed:restaurant`.

## Iniciar y detener

Desde `C:\proyectos\delivery-app\backend\james`:

```powershell
.\dev.ps1 run local:start
.\dev.ps1 run local:status
.\dev.ps1 run local:stop
```

`local:start` compila y mantiene una sola instancia en segundo plano. El proceso y los logs se guardan en `.local/backend-process.json`, `.local/backend.stdout.log` y `.local/backend.stderr.log`. La parada comprueba el ejecutable y la ruta del proceso para no detener otro servidor que reutilice ese PID.

Para recarga automática, detener la instancia gestionada y ejecutar `dev.ps1 run start:dev`. El inicio de sesión es `POST /api/auth/login`, con `email`, `password` e `idDevice` (UUID). La raíz `/` no es una página de administración.

Si la terminal tiene Node 22, `npm run build` y `npm start` usan automáticamente
el Node 24 de `.tools/node-v24.22.1-win-x64`. El lanzador comprueba la versión
antes de limpiar `dist`; no modifica la instalación global de Node.
Los ajustes de VS Code se aplican al abrir una terminal nueva, tanto desde la
raíz del repositorio como al abrir `backend/james` por separado.

Para iniciar en primer plano, sin una segunda instancia en el puerto 3000:

```powershell
npm run local:stop
npm run build
npm start
```

Al cambiar `.env` basta reiniciar el backend para leer los valores nuevos; no
es necesario recompilar Flutter. `local:stop` y `local:status` funcionan incluso
si una compilación fallida eliminó `dist`.

## Preparar o actualizar la base

Configurar `.env` con PostgreSQL local y tener instalado su paquete PostGIS. Mantener `DB_SYNCHRONIZE=false`; las migraciones no se ejecutan al arrancar NestJS.

```powershell
.\dev.ps1 run db:setup
.\dev.ps1 run migration:show
.\dev.ps1 run db:check
```

`db:setup` compila, crea la base si no existe, aplica las migraciones pendientes, crea los usuarios y comprueba el esquema. Repetirlo no duplica cuentas ni restablece contraseñas, roles o saldos. Si una cuenta existente tiene otra contraseña, el seed se detiene para no sobrescribirla. Las contraseñas generadas se conservan en `.local/credentials.json`; en PostgreSQL se guardan con bcrypt.

Migraciones aplicadas:

1. `InitialSchema1793208090762`: 14 tablas de negocio, índices, claves foráneas y las vistas `vw_company`, `vw_product` y `vw_category`. TypeORM mantiene además tablas de historial y metadatos.
2. `EnablePostgis1793208090763`: habilita PostGIS. Su reversión conserva la extensión porque puede tener otras dependencias.
3. `RestaurantPreparation1793220000000`: agrega el estado de cocina, los minutos estimados y las fechas de aceptación y disponibilidad. Los pedidos anteriores conservan estado de cocina nulo; los nuevos comienzan pendientes de aceptación.
4. `CourierLifecycle1793300000000`: fechas opcionales de asignación, retiro, entrega y cancelación. Los pedidos anteriores conservan sus fechas desconocidas como nulas.
5. `CatalogVisibility1793310000000`: corrige horarios del catálogo, categorías por ubicación y exclusión de locales y productos eliminados. Solo reemplaza las vistas; conserva los datos.

La migración inicial está dirigida a una base nueva, no a una base poblada y sin historial. `migration:revert` puede eliminar tablas y datos al llegar al esquema inicial: no usarlo sobre la base configurada en `.env` para probar el rollback.

Para cambios futuros, modificar las entidades y generar una migración que se debe revisar antes de aplicar:

```powershell
.\dev.ps1 run build
.\dev.ps1 run migration:generate src/database/migrations/NombreDelCambio
.\dev.ps1 run build
.\dev.ps1 run migration:run
```

## Pruebas

```powershell
.\dev.ps1 run verify
.\dev.ps1 run test:db
.\dev.ps1 run test:local
```

- `verify`: build, tipos, lint, 39 pruebas unitarias y 17 HTTP con infraestructura aislada.
- `test:db`: crea una base temporal de nombre aleatorio, aplica las migraciones, comprueba las entidades, prueba vistas, distancia PostGIS, puntos, borrado lógico y cascada de sesiones, revierte y reaplica. Elimina solo esa base temporal. Requiere permiso de creación de bases y no revierte ni vacía la base configurada en `.env`.
- `test:local`: 25 comprobaciones contra el servidor encendido: login correcto e incorrecto, permisos, sesión, logout, saldo, pedidos, direcciones, catálogo y bloqueo de integraciones externas. Elimina las sesiones de prueba y guarda un informe sin contraseñas ni tokens en `.local/api-smoke-report.json`.

Se verificaron cuatro usuarios locales, cinco migraciones aplicadas, ninguna pendiente y cero diferencias entre el esquema y las entidades. El setup y los seeds conservan las cuentas y contraseñas existentes. `RESTAURANTES.md`, `MOTORIZADOS.md` y `CATALOGO_LOCAL.md` documentan las cuentas y datos de demostración.

Se compiló e instaló el perfil local de Flutter en `emulator-5554`. Se verificaron los accesos de cliente, restaurante y motorizado contra NestJS. La base local contiene cinco restaurantes, 30 productos y los pedidos de demostración anteriores. El último APK se deja con la sesión del cliente para revisar el catálogo y los menús desde la dirección predeterminada. Las cuentas conservan sus contraseñas en `.local/credentials.json`, `.local/restaurant-credentials.json` y `.local/courier-credentials.json`.

## Flutter

VS Code tiene configurado el SDK local tanto al abrir `delivery-app` como al abrir solo `frontend/source`. Después de cambiar el SDK, ejecutar **Developer: Reload Window** y cerrar las terminales antiguas; una terminal nueva debe mostrar Flutter 3.47.8 y Dart 3.13.7 con `flutter --version`. Las terminales ya abiertas conservan su PATH anterior. La opción **Flutter local (emulador)** de Ejecutar y depurar (F5) utiliza el perfil local automáticamente.

Desde `C:\proyectos\delivery-app\frontend\source`, con el emulador iniciado:

```powershell
.\flutterw.ps1 run -d emulator-5554 --dart-define-from-file=config/local-emulator.json
```

El perfil configura la API y Socket.IO en `10.0.2.2:3000`, la dirección del equipo anfitrión vista desde Android Emulator. El APK local de depuración usa ese mismo perfil. Las compilaciones sin él conservan las URL originales: usar el perfil para iniciar sesión con estas cuentas locales. Para un teléfono físico, preparar otro perfil con la IP del equipo en la red.

## Servicios externos

El `.env` local tiene `EXTERNAL_SERVICES_ENABLED=false`. El backend no inicializa Firebase ni correo y devuelve 503 para Stripe y Google Places. No se necesitan esas credenciales para login, cuentas, catálogo o la base local.

El perfil Flutter omite la inicialización de Firebase y Stripe, oculta el acceso con Google y controla las subidas desactivadas a Storage. Los mapas con tiles y los recursos visuales remotos siguen necesitando conectividad y configuración; no se simulan esos proveedores. HTTP sin TLS se permite en el manifiesto de depuración de Android para conectar al backend local.

Para activar integraciones reales hay que configurar cuentas propias, habilitar la opción en backend y cliente, y completar las correcciones de seguridad descritas en `MIGRACION.md` antes de producción. Este entorno no valida cobros, correo ni entrega push reales.
