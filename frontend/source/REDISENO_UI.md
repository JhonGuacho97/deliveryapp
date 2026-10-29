# Rediseño de experiencia

## Dirección visual

Paleta Salvia y marfil: fondo `#F7F7F2`, superficie blanca, acción `#35695A`, texto `#202A25` y texto secundario `#596660`. El tema oscuro adapta estas funciones con superficies oscuras y un verde más claro. Se conserva Inter, se elimina la reducción global del texto y se emplean botones de al menos 52 px y superficies sin sombras pronunciadas.

## Fase 1: cliente y componentes compartidos

- Temas claro y oscuro, formularios y botones compartidos.
- Cliente con navegación Explorar / Pedidos / Cuenta. Perfil, direcciones, notificaciones y opciones comerciales siguen accesibles en Cuenta, conservando las restricciones de sesión y rol.
- Catálogo con dirección visible, buscador, categorías discretas, filas de productos y locales. Los productos destacados aparecen una sola vez. No se presentan tiempos, calificaciones ni tarifas inventadas.
- Búsqueda con espera de 350 ms, conservación de la consulta al cambiar categoría y descarte de respuestas antiguas. Estados distintos para falta de dirección, resultados vacíos y fallos de conexión; actualización al deslizar hacia abajo.
- Agregar y quitar productos con un control explícito. Barra del carrito disponible en el catálogo y el local.
- Carrito con cantidades, notas persistidas en SQLite y subtotal. El envío se muestra en el resumen antes de confirmar; la compra mantiene la lógica de pagos existente.
- Lista de pedidos más legible y progreso basado en los estados actuales del backend. Cancelación y taxi conservan sus etiquetas específicas. El perfil local ofrece detalle y progreso sin depender de Google Maps; el perfil con servicios externos conserva el mapa y el chat existentes.
- Textos nuevos en español e inglés, definidos en `lib/l10n/*.arb` y regenerados mediante Flutter Intl / `intl_utils 2.8.17` como herramienta local. No se agregó una dependencia de producción.

## Validación

```powershell
.\flutterw.ps1 analyze
.\flutterw.ps1 test
.\flutterw.ps1 test test_backend/backend_contract_test.dart
.\flutterw.ps1 test test_local/local_environment_test.dart --dart-define-from-file=config/local-emulator.json
.\flutterw.ps1 drive --keep-app-running --driver=test_driver/ui_driver.dart --target=integration_test/client_experience_test.dart -d emulator-5554 --dart-define-from-file=config/local-emulator.json
```

El recorrido Android utiliza productos y pedidos controlados, SQLite nativo y las pantallas reales. Comprueba búsqueda, categoría, alta y baja del carrito, cantidades, notas, pedidos, seguimiento y Cuenta. Guarda capturas en `.tools/ui-review/`; los datos de ejemplo no se insertan en PostgreSQL. Restaura el carrito y la dirección seleccionada al terminar. `--keep-app-running` evita que Flutter Drive desinstale la app y borre sus datos al salir. Las credenciales utilizadas para una revisión local, si se proporcionan mediante `UI_LOCAL_EMAIL` y `UI_LOCAL_PASSWORD`, pertenecen únicamente al harness; no se incluyen en el APK normal.

Las pruebas de widgets incluyen ancho de 320 px y texto ampliado al 130 %, temas claro y oscuro, nombres largos, desglose de envío y estados del seguimiento. También se verifican contraste, espera de búsqueda, respuestas fuera de orden, conexión fallida y contratos de compra previos. Las capturas se inspeccionan antes de cerrar la fase.

Resultado del 28 de octubre de 2026: 72 pruebas de unidad y widgets, 8 pruebas de contratos NestJS y 2 del perfil local aprobadas; recorrido Android aprobado en Pixel 4 XL API 34 y APK de depuración compilado. Se revisaron las capturas de catálogo, carrito, pedidos, seguimiento y Cuenta. El catálogo real de la base local devuelve cero locales y productos; las capturas con comida corresponden al harness de pruebas.

## Fase 2: restaurantes

- Navegación Pedidos / Menú / Negocio, con historial accesible desde la cocina y perfil desde la barra superior. Cada negocio puede seleccionar su local si administra varios.
- Colas Nuevos / En preparación / Listos / En reparto; indicaciones junto a cada producto, preparación estimada de 15, 25 o 35 minutos y una acción principal por etapa. Se bloquean dobles pulsaciones mientras se guarda y se informa un conflicto cuando otro dispositivo cambia el pedido.
- El detalle prioriza productos, cliente, dirección y total. Conserva acceso a llamada y ubicación mediante las aplicaciones del dispositivo. Los cambios de cocina se consultan también desde el seguimiento del cliente. La pantalla actual del motorizado verifica que el pedido esté listo antes de confirmar el retiro y no muestra éxito si la API lo rechaza.
- Menú con creación y edición de productos, validación y copia de los datos al editar: cancelar o fallar no sobrescribe el producto. La foto es opcional; la selección y subida siguen disponibles con el perfil de servicios externos. Se eliminó el selector de grupos porque el backend no ofrece ese contrato.
- Negocio con datos del local y horarios editables, estados de carga y conexión fallida. Se corrigió la actualización de la primera fila de horarios y se conserva el valor anterior si falla la API.
- El backend añade el estado de cocina sin cambiar los códigos de entrega y comprueba propiedad del negocio para pedidos, productos y horarios. El contrato y los datos locales están en `backend/james/RESTAURANTES.md`.

Validación del 28 de octubre de 2026: 81 pruebas de Flutter, 8 de contratos NestJS y 2 del perfil local; 34 pruebas unitarias y 17 de integración del backend; 40 comprobaciones de la cocina contra PostgreSQL desechable; migraciones reversibles sin diferencias de esquema. Se recorrió la cocina, el detalle, la creación y edición del menú y los horarios en Android con datos controlados. Una segunda prueba inició la aplicación completa e hizo login real como restaurante contra el backend local, leyendo el pedido, el producto y los siete horarios de demostración. Se inspeccionaron las capturas.

```powershell
.\flutterw.ps1 drive --keep-app-running --driver=test_driver/ui_driver.dart --target=integration_test/restaurant_experience_test.dart -d emulator-5554 --dart-define-from-file=config/local-emulator.json
```

La prueba `integration_test/restaurant_local_backend_test.dart` utiliza además `UI_LOCAL_EMAIL` y `UI_LOCAL_PASSWORD`, pasados mediante un archivo ignorado con `--dart-define-from-file`. Inicia sesión con la cuenta local y conserva esa sesión para la revisión; no modifica el pedido ni los precios. Después se reconstruye el APK normal con `--target=lib/main.dart` y solamente `config/local-emulator.json`, para que las credenciales del harness no se incluyan en él. Las pruebas conservan los datos nativos del emulador y no desinstalan la aplicación.

## Fase 3: motorizados

- Navegación Entregas / Ingresos / Cuenta y la misma paleta salvia/marfil. La disponibilidad se confirma con la API y requiere ubicación actual al conectar. Desconectar no solicita GPS y permite continuar las entregas ya asignadas.
- Ofertas con ganancia estimada, retiro, destino, pago y distancias aproximadas en línea recta. Después de aceptar se muestra la ganancia guardada en ese pedido. No se presentan tiempos de viaje inventados.
- Una acción principal por etapa: aceptar, confirmar retiro y confirmar entrega. La preparación del restaurante bloquea el retiro; las confirmaciones de efectivo recuerdan cobrar el total. Cancelar explica que anula el pedido del cliente y revierte los saldos, sin sugerir una reasignación.
- Acceso a ruta, llamada al restaurante o cliente y chat desde la entrega asignada. Se abren por acción del usuario. Cuenta reúne perfil, notificaciones y acerca de la aplicación.
- Ingresos por fecha efectiva de entrega en Ecuador, separados del saldo operativo y la liquidación registrada. El historial conserva los pedidos antiguos sin fecha de entrega. Las cantidades desconocidas se muestran con un guion.
- Los errores HTTP se propagan y mantienen el estado anterior: la app no muestra entrega exitosa ante un rechazo. Se bloquean pulsaciones duplicadas y respuestas de consultas anteriores a una mutación. Las consultas periódicas se detienen cuando la app pierde el primer plano.
- Backend con asignación y movimientos de saldo atómicos, acciones exclusivas del motorizado asignado, cuatro fechas de ciclo de vida y ubicación acotada al dispositivo y al cliente de una entrega activa. Contrato y cuenta local en `backend/james/MOTORIZADOS.md`.

Validación: 92 pruebas Flutter de unidad/widgets, incluidas once del motorizado; 8 de contratos con NestJS y 2 del perfil local; análisis estático sin incidencias. Backend: 39 unitarias, 17 HTTP, 58 comprobaciones de reparto y 41 de regresión de restaurante con PostgreSQL desechable. Migraciones aplicadas y reversibles sin diferencias de esquema.

Se recorrió disponibilidad, oferta, espera de cocina, retiro, entrega con confirmación, ingresos y cuenta en Pixel 4 XL API 34. Una segunda prueba abrió la aplicación completa, inició sesión como motorizado y usó el GPS del emulador para leer una oferta real del backend local. Se revisaron capturas en `.tools/ui-review/ui-courier-*.png`. El recorrido completo usa datos controlados; la prueba local conserva el pedido listo para que el usuario pueda tomarlo.

```powershell
.\flutterw.ps1 drive --keep-app-running --driver=test_driver/ui_driver.dart --target=integration_test/courier_experience_test.dart -d emulator-5554 --dart-define-from-file=config/local-emulator.json
```

`courier_local_backend_test.dart` recibe `UI_LOCAL_EMAIL` y `UI_LOCAL_PASSWORD` mediante un archivo ignorado. Después se reconstruye el APK normal con `--target=lib/main.dart` y únicamente `config/local-emulator.json`; los secretos del harness no se distribuyen. La cuenta de demostración tiene 20 USD de saldo operativo ficticio y el pedido de prueba en efectivo; no se activaron cobros reales.

## Catálogo local y menús de prueba

Corrección del catálogo local: la API de restaurantes omitía `type` y Flutter descartaba la respuesta al convertirla. El backend devuelve el tipo de tienda y el modelo móvil admite respuestas anteriores sin ese campo. Se corrigieron también horarios calculados con doble desplazamiento UTC, categorías por ubicación y distancias del envío. La base tiene cinco restaurantes y 30 productos reales de prueba; detalles y comando de carga en `backend/james/CATALOGO_LOCAL.md`.

Se aprobaron 93 pruebas Flutter, incluida una regresión con el JSON original, y el análisis estático. `integration_test/catalog_local_backend_test.dart` verifica en Android el login del cliente, la dirección predeterminada, los cinco restaurantes, sus menús y el costo del envío contra el backend local. La cuenta y dirección existentes se conservan; la prueba no crea pedidos. El APK normal se reconstruye con `lib/main.dart` sin credenciales del harness.

## Formularios

Los formularios de crear y editar siguen una base compartida con superficie blanca, etiquetas externas, contorno suave y acciones adaptadas al teclado. Se actualizan perfil de los tres roles, acceso, registro, recuperación, dirección, contraseña, negocio, productos, recarga y selectores. Se elimina el desbordamiento inferior del perfil y se conserva el teléfono al guardar otros datos. El detalle visual y la validación —121 pruebas Flutter, 8 contratos, 2 del perfil local y recorridos Android— están en `FORMULARIOS.md`.

## Acceso, navegación y búsqueda global

Se retira la marca anterior de la cabecera del cliente y se coloca allí la dirección de entrega. La navegación usa un índice compartido para que la pestaña activa, la cabecera y su pantalla coincidan al volver de otros flujos o cambiar el tamaño del teclado.

Acceso y registro usan un encabezado tipográfico, un detalle de delivery en salvia y un selector compacto. Conservan etiquetas externas, validación, visibilidad de contraseña y botones accesibles con teclado. Los borradores se mantienen al alternar entre ambos formularios. El diálogo compartido de confirmación define un color de texto con contraste; el cierre de sesión muestra «Cerrar sesión» y un icono de salida.

El buscador envía `query` a NestJS en vez de filtrar los destacados descargados. Presenta «Platos que coinciden» y «Restaurantes relacionados», incluyendo negocios encontrados por sus menús. Respeta la dirección y categoría seleccionadas. Las pruebas de PostgreSQL cubren menús de varios negocios, tildes, mayúsculas, descripciones, paginación y productos/locales eliminados.

Validación de esta revisión: 126 pruebas Flutter; análisis estático; 39 pruebas unitarias y 17 HTTP de NestJS; 92 comprobaciones de catálogo con PostgreSQL desechable. El recorrido Android `catalog_local_backend_test.dart` incorpora login por formulario contra NestJS, registro sin crear cuentas, búsqueda `pizz` y `pepperoni`, navegación y cancelación del diálogo de salida. Las capturas se guardan en `.tools/ui-review/` y la app normal se compila sin las credenciales de prueba.

## Bienvenida y mapa del pedido

La bienvenida utiliza una superficie limpia, título que explica el servicio, tres beneficios concretos y accesos para elegir dirección o entrar/crear cuenta. Ya no muestra textos ni enlaces legales del proveedor de la plantilla. Se pueden definir las URLs propias mediante `APP_PRIVACY_URL` y `APP_TERMS_URL`.

El mapa del cliente vuelve a activarse en el entorno local mediante `ORDER_MAP_ENABLED=true`, independiente de `EXTERNAL_SERVICES_ENABLED=false`. Se han eliminado las dependencias de imágenes remotas antes de conectar el seguimiento y la ubicación inicial inventada del motorizado. El controlador recibe coordenadas aunque el mapa esté desactivado, conserva su conexión en actualizaciones del mismo pedido y refresca los estados sin depender de Firebase.

Se verifican la bienvenida en temas claro/oscuro y tamaños de texto ampliados, la asignación del motorizado sin push y la recepción del marcador desde el gateway Nest real. El recorrido Android comprueba un mapa nativo con coordenadas controladas y la navegación desde la bienvenida al acceso. La viabilidad de Cloudinary y la configuración detallada de Maps están en `MAPAS_E_IMAGENES.md`.

## Navegación Liquid Glass

La barra inferior de los tres roles utiliza `liquid_glass_widgets` 1.16.0:
cápsula flotante, desenfoque, lente con aumento y deslizamiento continuo. La
pantalla cambia al soltar el dedo, y un gesto cancelado conserva la pestaña
actual. Se ajustan las áreas seguras y el final de las listas para convivir con
el carrito. Implementación y validación en `NAVEGACION_GLASS.md`.

## Catálogo y restaurante con fotografías

Platos y restaurantes se presentan en carruseles visuales, con precios y acciones
explícitas. El restaurante incorpora portada, información del local, buscador
fijo, filtros por precio y menú en cuadrícula. El detalle del plato conserva
acceso al carrito. La base local contiene fotos ilustrativas para los cinco
restaurantes y sus treinta platos. Diseño y validación en `CATALOGO_VISUAL.md`.

## Mejoras posteriores

Quedan como mejoras posteriores la pausa inmediata del local y la disponibilidad por producto. Los cobros reales, Firebase y Google Sign-In necesitan sus servicios y cuentas de prueba configurados. El mapa del pedido ya se validó en Android; la configuración de claves para producción se detalla en `MAPAS_E_IMAGENES.md`.
