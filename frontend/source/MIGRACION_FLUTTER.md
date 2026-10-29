# Actualización de Flutter

Inicio: 28 de octubre de 2026.

El frontend original se conserva en el tag Git `flutter-original`. Las etapas verificadas se guardarán en commits independientes.

| Etapa | Alcance | Estado |
| --- | --- | --- |
| Base | Flutter 3.47.8 / Dart 3.13.7, Android y pruebas iniciales | Validada: análisis sin incidencias, cinco pruebas y APK debug |
| Acceso y almacenamiento | Google Sign-In 7, sesión, preferencias, SQLite y contratos HTTP | Validada: 26 pruebas acumuladas y análisis sin incidencias |
| Notificaciones y archivos | Firebase, permisos, notificaciones locales y carga de imágenes | Validada: 37 pruebas acumuladas y análisis sin incidencias |
| Mapas y ubicación | Mapas, permisos GPS, Socket.IO y reconexión | Validada: pruebas aisladas, GPS nativo y gateway NestJS local |
| Pagos | Stripe y coordinación de resultados con la API | Validada con dobles: 51 pruebas acumuladas; cobro externo pendiente |
| Interfaz y cierre | Widgets, catálogo, pedidos, comercios, repartidores y pruebas en emulador | Validada: 57 pruebas Flutter, 8 de integración local y 6 en Android |

## Entorno

El SDK local se encuentra en `.tools/flutter` y está fijado a 3.47.8. No se modifica el Flutter global del equipo. `flutterw.ps1` utiliza el SDK local; `flutterw.ps1 verify` resuelve el lockfile, analiza y ejecuta las pruebas.

VS Code configura el SDK y el PATH de terminales nuevas en `.vscode/settings.json`. La raíz `delivery-app` tiene también esa configuración, porque VS Code no aplica los ajustes de una subcarpeta al abrir su carpeta principal. Después de cambiar estos ajustes se debe recargar la ventana y abrir una terminal nueva. F5 ofrece **Flutter local (emulador)** con el perfil del backend local. `flutterw.ps1` permite ejecutar el SDK correcto incluso desde una terminal antigua.

Android Studio es opcional: este equipo dispone del SDK de Android, JDK y emulador. Se usan herramientas de línea de comandos. Android se configura para API 36, mínimo API 24 (Android 7.0), Java 17 en el código compilado, AGP 9.1.0, Kotlin 2.4.0 y Gradle 9.3.1. Se conservan temporalmente las opciones de compatibilidad `android.builtInKotlin=false` y `android.newDsl=false` que añade Flutter para plugins que todavía aplican KGP.

El archivo de firma, contraseñas, configuración local, configuración de Firebase y herramientas quedan fuera de Git. La identidad Android se conserva. Las credenciales existentes no se publican ni se usan para pruebas de pagos o mensajes reales.

## Cambios iniciales

- Se corrigen 47 llamadas a `Color.withValues` que usaban opacidad multiplicada por 255; esa API espera valores entre 0 y 1.
- Se empaqueta Inter junto a su licencia para que la tipografía funcione sin descargas en ejecución. Se retira la dependencia `google_fonts`, usada únicamente por el tema.
- Se restaura el wrapper Gradle, con verificación del checksum, y se normalizan las configuraciones Android.
- Se eliminan archivos del embedding Android antiguo, restricciones nativas de Stripe incompatibles y un BOM de Firebase fijado manualmente.

Las pruebas automáticas usan dobles de los proveedores externos. Las verificaciones reales de Google, Firebase, mapas y pagos necesitan configuración y cuentas de prueba válidas. Las correcciones de seguridad del backend identificadas en `MIGRACION.md` siguen siendo necesarias antes de producción.

## Acceso y almacenamiento

Google Sign-In 7 usa una pasarela con inicialización explícita y cancelación segura. Se conserva el contrato HTTP del backend existente; disponer del ID token del SDK no sustituye la verificación pendiente del servidor.

SQLite mantiene la versión 2, las tablas y el nombre del archivo existente. Se usan inserciones parametrizadas y una transacción al cambiar la dirección seleccionada. Las pruebas utilizan SQLite real en memoria y archivos temporales para comprobar reapertura y conservación de datos. La sesión exige usuario y token, y el cierre de sesión conserva el UUID y el idioma.

## Notificaciones y archivos

Firebase Core 5, Messaging 17, Storage 14 y notificaciones locales 22. Se espera la inicialización nativa, se controlan permisos denegados, rotación de tokens y errores de red. La carga de imágenes conserva las URL completas con sus tokens y comprime en memoria. Se prueban mensajes, permisos, fallos y bytes de imagen sin enviar datos a cuentas externas.

Messaging 17 recomienda FID (`register`/`onRegistered`), pero se conserva temporalmente la ruta compatible de tokens FCM porque el backend todavía envía `tokens` en Firebase Admin. Las dos llamadas obsoletas tienen una excepción de análisis localizada y explicada. La transición a FID requiere actualizar juntos el almacenamiento y envío del backend y el cliente; no se mezclan ambos mecanismos. Referencia: https://firebase.google.com/docs/cloud-messaging/flutter/get-started .

## Mapas y ubicación

Maps 2.19, Geolocator 14 y Socket.IO 3. Se usa `/socket.io`, la ruta del gateway NestJS, en vez de la ruta incorrecta del archivo JavaScript. Cada transporte nuevo recibe la sesión actual. Se comprueban coordenadas, permisos, fallback, timeout, limitación de frecuencia y limpieza de suscripciones. El seguimiento sigue siendo el existente en primer plano; estas pruebas no certifican seguimiento continuo en segundo plano ni visualización de mapas con una clave externa.

## Pagos

Stripe 14.2. El coordinador permite probar inicialización, éxito, cancelación, errores y confirmación sin cobrar. La interfaz bloquea solicitudes simultáneas y restaura su estado al terminar. Se espera la cancelación del intento cuando falla la hoja; un fallo al confirmar después de completar la hoja no se trata como una cancelación del usuario. El backend todavía necesita verificar el estado de Stripe antes de acreditar saldo. No se ha certificado ningún cobro real ni la conciliación de pagos.

## Interfaz y contratos

Se actualizan caché, imágenes, selector de imágenes, calendario, iconos, indicadores y selectores. Se retira `flutter_image_compress`, que no tenía usos. Los selectores de direcciones, categorías, grupos y pagos usan la API genérica de DropDown 2, con identificadores separados del texto visible. Las pruebas de widgets cubren acceso, registro, recuperación y selección real de la forma de pago. Se corrige un `Expanded` colocado dentro de `Form` que fallaba al abrir recuperación.

Se corrigen contratos contrastados con el código del backend:

- Catálogo y tarifas dejan de enviar parámetros que sus DTOs rechazan. El filtro por nombre se aplica sobre el catálogo recibido; no es búsqueda global del servidor.
- La creación de pedidos y el chat aceptan HTTP 201. El chat no informa éxito ante un fallo de transporte.
- El pedido nuevo utiliza el reconocimiento con `id` que devuelve NestJS, sin exigir un pedido completo. El carrito solo elimina los comercios confirmados y conserva el resto ante un fallo parcial.
- El origen del pedido se obtiene de `store.location` cuando el servidor no incluye `start`. El payload de compra no envía ese campo no admitido. Se toleran las tarifas sin coordenadas de origen y el catálogo sin grupos.
- Cada pantalla de pedido posee su conexión y cancela sus suscripciones, para no cerrar el transporte del seguimiento del repartidor.

Las pruebas cruzadas descubrieron además una regresión del target ES2023 del backend al validar referencias anidadas. Se corrigió en el commit backend `c1c11ca` y se añadieron tres regresiones; su verificación completa pasa con 40 pruebas. El fixture usa controladores, DTOs, JWT y gateway reales, con servicios de negocio en memoria. No verifica SQL, PostGIS ni la lógica de precios y saldos.

## Resultado de las comprobaciones

| Comprobación | Resultado |
| --- | --- |
| Análisis estático de Flutter | Sin incidencias |
| Pruebas automáticas de Flutter | 57 aprobadas |
| Contratos contra NestJS local | 8 aprobadas; acceso, catálogo, pedidos, direcciones, chat, comercios, repartidores, pagos y Socket.IO |
| Emulador Pixel 4 XL, API 34 | 6 aprobadas: preferencias, GPS, notificación local, recuperación de selección de imágenes, SQLite y formulario de acceso |
| Compilación Android | APK debug; sin publicación |

El GPS nativo comprueba una posición válida; el AVD tenía su propia configuración de ubicación, por lo que no se exige una coordenada geográfica fija. Se conceden permisos únicamente en el emulador. El picker se comprueba sin selección pendiente; no se certifican cámara y galería mediante interacción manual. El formulario de acceso se ejecuta en un harness sin inicializar cuentas externas ni llamar al login real.

Las dependencias directas se resolvieron con las versiones estables consultadas el 28 de octubre. Quedan cinco actualizaciones transitivas fuera de los rangos que fijan Flutter u otros plugins (`cross_file`, `dbus`, `gsettings`, `material_color_utilities`, `test_api`); no se fuerzan overrides. Los plugins Firebase Core/Storage todavía avisan sobre KGP con AGP 9; las opciones de compatibilidad permiten compilar esta versión, pero necesitarán revisarse al actualizar Flutter de nuevo.

## Repetir las pruebas

Desde `frontend/source`:

```powershell
.\flutterw.ps1 verify
.\flutterw.ps1 test test_backend/backend_contract_test.dart
.\flutterw.ps1 build apk --debug --target=lib/main.dart
```

Las pruebas de contratos requieren el backend vecino instalado y compilado con su Node 24 local. No arrancan su `AppModule`, no cargan `.env` ni se conectan a la base real. Si se abre VS Code, conviene abrir `frontend/source` para que aplique su configuración del SDK local.

Con `emulator-5554` iniciado y un APK instalado, preparar los permisos y ejecutar el harness:

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk
& $adb -s emulator-5554 shell pm grant com.ivc.lili android.permission.ACCESS_FINE_LOCATION
& $adb -s emulator-5554 shell pm grant com.ivc.lili android.permission.ACCESS_COARSE_LOCATION
& $adb -s emulator-5554 shell pm grant com.ivc.lili android.permission.POST_NOTIFICATIONS
.\flutterw.ps1 test integration_test/module_smoke_test.dart -d emulator-5554 --no-uninstall
```

Flutter desinstala el harness al finalizar salvo que se indique `--no-uninstall`; una nueva instalación pierde los permisos concedidos. Para volver a la app normal, reconstruir con `--target=lib/main.dart` e instalar ese APK. No hace falta Android Studio para estos comandos.

## Límites y siguientes pasos

El entorno local se configura con `config/local-emulator.json`: API y Socket.IO usan `10.0.2.2:3000`, con Firebase, Stripe y acceso Google desactivados. Para ejecutarlo: `flutterw.ps1 run -d emulator-5554 --dart-define-from-file=config/local-emulator.json`. Se conserva el comportamiento original cuando no se pasa el perfil. El manifiesto Android de depuración permite HTTP para la conexión local. Pasan las 57 pruebas anteriores y dos pruebas adicionales del perfil sin inicialización Firebase. Se compiló, instaló y abrió el APK local y se verificó el login del cliente contra PostgreSQL desde el formulario Android. El detalle del backend y las cuentas está en `backend/james/ENTORNO_LOCAL.md`.

Se puede continuar el desarrollo sobre esta base. Antes de producción quedan las correcciones de seguridad del backend, una base aislada con PostGIS y recorridos completos con cuentas de prueba de Google, Firebase, Maps y Stripe. No se han validado login externo, entrega push desde Firebase, descarga/subida real de Storage, mapa con tiles, cobro real, cámara/galería ni firma de release/AAB.

El backend entregado no implementa `admin/group` ni utiliza los parámetros específicos de taxi que enviaba el cliente. Los widgets heredados permanecen, pero esas funciones requieren implementar su contrato de negocio antes de considerarlas operativas. Las pruebas de la migración no las certifican.

Los tags `flutter-original`, `flutter-base`, `flutter-access-storage`, `flutter-notifications-files`, `flutter-location`, `flutter-payments` y `flutter-migration-complete` permiten revisar cada fase. El APK generado se encuentra en `build/app/outputs/flutter-apk/app-debug.apk`.
