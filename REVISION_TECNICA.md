# Revisión técnica del proyecto de delivery

Fecha: 27 de octubre de 2026.

> Actualización del 28 de octubre: el backend fue migrado por etapas a NestJS 12 y el frontend a Flutter 3.47.8, con dependencias actualizadas y pruebas automáticas, integración local y emulador Android. Esta revisión conserva el diagnóstico inicial; el estado actual y los límites de las pruebas están en [MIGRACION.md](backend/james/MIGRACION.md) y [MIGRACION_FLUTTER.md](frontend/source/MIGRACION_FLUTTER.md). Los hallazgos de seguridad de autenticación, pagos y permisos del servidor siguen pendientes.

## Dictamen

El proyecto es una base aprovechable para continuar desarrollando. Recomiendo conservar NestJS y Flutter y hacer primero una fase de estabilización, actualización y corrección de seguridad. No hay evidencia que justifique reescribir toda la aplicación. Tampoco sería correcto afirmar que se puede trabajar o publicar sin problemas tal como se entregó: hay fallos de instalación reproducidos y problemas importantes en autenticación y pagos.

El backend contiene módulos separados para autenticación, administración, comercios, pedidos, repartidores, direcciones, notificaciones, chat y pagos. El frontend separa modelos, servicios, controladores y pantallas. Esta organización permite actualizar por componentes.

## Alcance y comprobaciones

- Revisión de manifiestos, bloqueo de dependencias, configuración de Android y código de integraciones y flujos sensibles.
- Consulta de documentación oficial y registros npm/pub.dev para contrastar versiones disponibles.
- Pruebas de resolución e instalación en una carpeta temporal. No se cambiaron las dependencias ni el código del proyecto original.
- No se inició el servidor, no se conectó a la base de datos ni se hicieron llamadas a las cuentas de Stripe, Google o Firebase configuradas en la aplicación.
- No se certifica el funcionamiento completo, el despliegue actual ni una compilación APK/AAB. No se ejecutaron pruebas funcionales de login, pedidos, mapas, pagos o notificaciones.

| Comprobación | Resultado |
| --- | --- |
| Resolución npm con el `package.json` original | Falla con `ERESOLVE`: `@nestjs/mapped-types: "*"` selecciona 12.0.0, incompatible con NestJS 9. |
| Resolución npm fijando únicamente `@nestjs/mapped-types` en 2.0.5, en copia temporal | Correcta. Esta versión declara compatibilidad con NestJS 9. |
| Instalación de esa copia con `npm ci --ignore-scripts` | Correcta. Se omitieron scripts de instalación; esto no verifica los binarios nativos de bcrypt. |
| `npm run build` en esa copia | Correcto. Confirma que el backend puede compilar con ese ajuste, no que sus servicios externos funcionen. |
| Descubrimiento de pruebas unitarias de Jest | No encuentra pruebas. Solo se entrega una prueba e2e de plantilla que espera `Hello World!`. |
| `flutter pub get` en copia temporal, con el SDK local | Falla: Dart 3.3.0 no satisface el requisito Dart 3.6 de `google_sign_in` 6.3.0. |
| Auditoría npm de dependencias de producción en la resolución temporal | 36 entradas reportadas: 2 críticas, 19 altas, 12 moderadas y 3 bajas. |

La auditoría corresponde a una resolución nueva de los rangos declarados, con el único ajuste temporal indicado. El backend original no incluye lockfile ni dependencias instaladas: no permite determinar las versiones exactas del servidor desplegado. Los avisos incluyen dependencias transitivas y no equivalen a 36 fallos demostrados como explotables en esta aplicación. El JSON de diagnóstico está en audit-production.json (diagnóstico local excluido del repositorio).

## Correcciones prioritarias

### 1. Verificar la identidad de Google en el servidor

En [auth.service.ts](backend/james/src/auth/auth.service.ts#L39), el método `google()` acepta `email` e `idGoogle` del cliente, vincula una cuenta por correo y emite un JWT de la aplicación. El DTO no exige un ID token y la ruta no verifica una firma de Google. La validación de formato de los campos no demuestra la identidad de la persona.

Esto permite suplantación de cuentas si la ruta se expone tal como está. Debe recibirse y verificarse el ID token en el backend, comprobar firma, audiencia, emisor y vencimiento, y usar el identificador `sub` validado para vincular cuentas. Es un problema de lógica de autenticación: actualizar el paquete del frontend no lo resuelve. [Documentación de Google](https://developers.google.com/identity/gsi/web/guides/verify-google-id-token).

### 2. Comprobar el pago antes de acreditar saldo

En [payments.service.ts](backend/james/src/client/payments/payments.service.ts#L62), `confirm()` cambia el estado local y acredita saldo a partir de una petición del cliente. Comprueba que el registro pertenece al usuario, pero no consulta si Stripe confirmó el cobro. La ruta está disponible para usuarios con rol cliente.

Un cliente podría confirmar un intento de pago propio sin completar el cobro. La acreditación debe depender del estado verificado del PaymentIntent, importe y moneda esperados, con notificaciones webhook verificadas e idempotencia. El cambio de estado y el saldo también necesitan una transacción para evitar inconsistencias. [Estados y verificación de pagos en Stripe](https://docs.stripe.com/payments/payment-intents/verifying-status).

### 3. Vincular las ubicaciones al usuario autenticado

En [location-ws.gateway.ts](backend/james/src/location-ws/location-ws.gateway.ts#L17), se verifica un JWT al conectar, pero el evento de ubicación utiliza el `id` enviado en el mensaje para actualizar y retransmitir la ubicación. Tampoco se comprueba en esa ruta que el usuario tenga rol de repartidor ni que pueda consultar la sala solicitada.

La identidad que se modifica debe proceder de la conexión autenticada. La suscripción a salas debe autorizarse según la relación entre usuario, repartidor y pedido. Conviene aplicar también la vigencia de la sesión que usa la autenticación HTTP.

### 4. Controlar los cambios de esquema

En [app.module.ts](backend/james/src/app.module.ts#L43), TypeORM tiene `synchronize: true` sin distinguir entornos. No se encontraron migraciones. Antes de usar una base con datos reales, desactivar esa sincronización en producción y establecer migraciones y respaldo/restauración probados.

## Backend: actualizaciones recomendadas

Las versiones del manifiesto son rangos, no versiones instaladas. Por ejemplo, `axios: ^1.4.0` resolvió a 1.21.0 en la prueba: no debe describirse como si Axios 1.4.0 estuviera necesariamente instalado.

| Componente | Declarado | Referencia consultada | Recomendación |
| --- | --- | --- | --- |
| NestJS core/common/platform | `^9.4.0` | 12.3.2; línea legacy 11.2.8 | Migrar por versiones mayores, comprobando las guías intermedias y alineando los paquetes del framework. |
| `@nestjs/mapped-types` | `*` | 12.0.0 | Eliminar el comodín. Fijar una versión compatible durante la estabilización. |
| `firebase-admin` | `^11.8.0` | 14.5.0 | Actualizar y adaptar el código de mensajería. |
| `nodemailer` | `^6.9.2` | 10.2.1 | Actualizar por etapas y probar envío/recuperación de cuentas. |
| TypeORM | `^0.3.16` | 0.3.31 en legacy; 1.1.2 en latest | Se puede estabilizar primero en la rama 0.3 parcheada. Evaluar 1.x por separado. |
| bcrypt | `^5.1.0` | 6.0.0 | Actualizar y verificar binarios nativos y compatibilidad con hashes existentes. |
| Node.js | Sin `engines` ni versión fijada | Equipo: 22.14.0 | Usar un parche actual de Node 24 LTS y fijar la versión del entorno. |
| Herramientas de desarrollo | CLI Nest 9, ESLint 8, Jest 29, TypeScript `^5.0.4` | Hay versiones mayores disponibles | Actualizarlas junto con la migración; no es necesario llevar todas simultáneamente a su última versión. |

NestJS 12 tiene cambios de compatibilidad y requisitos de Node distintos para ejecución y CLI. La migración requiere revisar también Express y resolución de módulos. [Guía de migración de NestJS](https://docs.nestjs.com/migration-guide). Node 24 figura como LTS en la [tabla oficial de versiones](https://nodejs.org/en/about/previous-releases).

El backend usa `sendMulticast()` en [notification.service.ts](backend/james/src/notification/notification.service.ts#L31). Ese método fue deprecado y retirado desde Firebase Admin 13. Debe sustituirse por `sendEachForMulticast()` y manejar sus resultados y errores al actualizar. [Notas oficiales de Firebase Admin](https://firebase.google.com/support/release-notes/admin/node).

Crear y conservar un `package-lock.json`, usar `npm ci` y repetir la auditoría después de las correcciones. No usar `--force` o `--legacy-peer-deps` como solución permanente al conflicto.

## Frontend: SDK y dependencias

El equipo tiene Flutter 3.19.2 y Dart 3.3.0. Los archivos generados entregados con el proyecto registran Flutter 3.29.3 y Dart 3.7.2, procedentes de una instalación macOS. El lockfile requiere Dart `>=3.7.0 <4.0.0` y Flutter `>=3.27.0`.

El `pubspec.yaml` conserva `sdk: ">=2.18.0 <3.0.0"`. Es una declaración desactualizada respecto de las dependencias. Por sí sola no demuestra que Dart 3 la rechace: pub reinterpreta ese límite superior para paquetes con null safety. El fallo reproducido es que el SDK instalado es demasiado antiguo para los paquetes solicitados. [Compatibilidad explicada por Dart](https://dart.dev/resources/dart-3-migration).

| Paquete | Versión del lockfile | Última consultada |
| --- | --- | --- |
| `firebase_core` | 3.13.0 | 5.1.0 |
| `firebase_messaging` | 15.2.5 | 17.0.1 |
| `firebase_storage` | 12.4.5 | 14.0.1 |
| `flutter_stripe` | 11.5.0 | 14.2.0 |
| `google_sign_in` | 6.3.0 | 7.2.0 |
| `geolocator` | 10.1.1 | 14.1.2 |
| `google_maps_flutter` | 2.12.1 | 2.19.0 |
| `flutter_local_notifications` | 19.1.0 | 22.3.3 |
| `socket_io_client` | 2.0.3+1 | 3.1.6 |
| `provider` | 6.1.4 | 6.1.5+1 |
| `http` | 1.3.0 | 1.6.0 |
| `intl` | 0.19.0 | 0.20.3 |
| `shared_preferences` | 2.5.3 | 2.5.6 |
| `sqflite` | 2.4.2 | 2.4.5 |

Las últimas versiones son referencias para planificar, no una combinación de dependencias validada. La primera tarea es fijar un SDK y conseguir una compilación reproducible. Después se pueden migrar Firebase, notificaciones, acceso con Google, mapas/ubicación y pagos por grupos, probando cada flujo.

Para modernizar, elegir una versión estable actual de Flutter y fijarla con su Dart correspondiente. La documentación actual incluye la línea estable Flutter 3.47. No es necesario abandonar Flutter 3. [Versiones oficiales](https://docs.flutter.dev/install/archive).

`google_sign_in` 7 cambia la inicialización y la API de autenticación; no basta con editar el número. [Documentación del paquete](https://pub.dev/packages/google_sign_in). Stripe y Firebase también requieren revisar sus instrucciones de migración y configuración nativa: [Stripe](https://pub.dev/packages/flutter_stripe), [Firebase](https://pub.dev/packages/firebase_core).

Provider puede conservarse. Esta revisión no aporta un motivo para cambiar la gestión de estado o reescribir las pantallas.

## Android y plataformas

En [build.gradle de la app](frontend/source/android/app/build.gradle#L37) se declara compile SDK 35, target SDK 34 y compatibilidad Java/Kotlin 1.8. El proyecto usa AGP 8.1.3 y Gradle 8.0, y contiene simultáneamente configuraciones raíz Groovy y Kotlin DSL.

- `flutter_local_notifications` 19.1.0 documenta habilitar desugaring y configurar Java 11. La app no habilita desugaring. El paquete recomienda AGP 8.6.0 como mínimo prudente. Esta configuración requiere corrección incluso antes de migrar a la versión más reciente del paquete. [Requisitos de la versión usada](https://pub.dev/packages/flutter_local_notifications/versions/19.1.0).
- Se fuerzan Stripe Android y Financial Connections a 20.11.0. Hay que retirar o justificar estas restricciones al validar la versión nativa exigida por `flutter_stripe`; no se comprobó la resolución Gradle.
- No se entregaron `gradlew` ni `gradlew.bat`, aunque existe el JAR del wrapper. Restaurar el conjunto del wrapper y normalizar la configuración de compilación.
- El Java encontrado en PATH es 22.0.1. No se comprobó qué JDK elegiría Flutter/Android Studio para Gradle; debe fijarse una combinación compatible de JDK, Gradle, AGP y Kotlin.
- Para publicar una actualización normal en Google Play, el target 34 es insuficiente. Desde el 31 de agosto de 2026 se exige API 36 para nuevas apps y actualizaciones, salvo excepciones de otras categorías. No se revisó si esta aplicación tiene alguna prórroga en Play Console. [Requisito oficial de Google Play](https://developer.android.com/google/play/requirements/target-sdk).
- Esta entrega incluye Android, pero no una carpeta `ios/`. Si se desea iOS, habrá que incorporar y validar esa plataforma, su firma y sus integraciones.

## Base de datos, configuración y mantenimiento

El compose declara `postgis/postgis:14-3.2`. PostgreSQL 14 termina su soporte el 12 de noviembre de 2026. Conviene programar la migración a una combinación soportada de PostgreSQL/PostGIS y comprobar las consultas geográficas, sin asumir que la base desplegada usa esa misma imagen. [Política oficial de PostgreSQL](https://www.postgresql.org/support/versioning/).

Se entregaron `.env`, `android/key.properties` y un archivo de firma `key.jks`. Revisar custodia y permisos de estos archivos, y rotar secretos si la copia se compartió fuera del equipo autorizado. Su presencia local no demuestra que hayan sido filtrados. No se reproducen sus valores en este informe.

Las constantes del frontend apuntan a servicios del proyecto original. Preparar configuración propia de desarrollo, pruebas y producción para API, Firebase, Google Maps, OAuth y Stripe antes de ejecutar flujos reales.

Esta carpeta no es un repositorio Git y contiene cachés y archivos generados de otro equipo, incluido `__MACOSX`. Incorporar control de versiones, exclusiones de archivos generados/secretos y documentación reproducible del entorno.

No se encontró una suite que valide el negocio. Añadir pruebas relevantes para identidad, permisos, confirmación/idempotencia de pagos, saldo, asignación concurrente de pedidos y transiciones de estado. Completar con pruebas en dispositivo de mapas, ubicación, notificaciones y recuperación de conexión.

## Orden de trabajo recomendado

1. Preparar control de versiones, configuración propia de pruebas y respaldo de cualquier base que deba conservarse.
2. Fijar SDK y dependencias, resolver la instalación, recuperar el wrapper Android y conseguir compilaciones reproducibles del backend y de la app.
3. Corregir autenticación Google, confirmación de pagos, permisos de ubicación y gestión del esquema antes de conectar usuarios reales.
4. Actualizar NestJS y sus integraciones por etapas; migrar los paquetes Flutter por grupos y adecuar Android a los requisitos de publicación.
5. Validar el recorrido completo: registro/login, direcciones, catálogo, pedido, asignación, seguimiento, entrega, saldo/pagos y notificaciones.

Se puede continuar sobre esta base. La condición práctica es estabilizarla primero y comprobar sus flujos principales; la actualización de librerías por sí sola no resuelve los problemas de seguridad encontrados en el código.
