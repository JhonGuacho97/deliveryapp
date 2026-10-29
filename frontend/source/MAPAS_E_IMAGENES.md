# Seguimiento del pedido e imágenes

## Por qué no aparecía el mapa del cliente

`ContentOrder` ocultaba Google Maps cuando `EXTERNAL_SERVICES_ENABLED=false`, el valor del entorno local para trabajar sin Firebase, Google Sign-In y Stripe. La pantalla mostraba los estados del pedido, pero no explicaba que el mapa estaba desactivado. El código del mapa y el transporte Socket.IO seguían en el proyecto.

Ahora el mapa del pedido tiene su propio indicador `ORDER_MAP_ENABLED`. Puede ejecutarse con Firebase y Stripe desactivados. En el modo sin mapa, la pantalla conserva el progreso y explica su disponibilidad. El controlador escucha coordenadas por Socket.IO independientemente del mapa y consulta el pedido cada 15 segundos mientras está activo para descubrir asignaciones y cambios de estado cuando no hay notificaciones push.

La conexión ya no espera descargas de imágenes para los marcadores. Se utilizan marcadores que no dependen de Firebase y el motorizado aparece solo después de recibir sus primeras coordenadas; nunca se inventa una ubicación inicial `(0,0)`. Una actualización del pedido con el mismo motorizado conserva la conexión. Cambiar de repartidor reemplaza la suscripción, y completar o cerrar el pedido la cancela.

## Configurar Google Maps en Android

1. En tu proyecto de Google Cloud, habilita Maps SDK for Android y la facturación requerida por Google. Configura una clave de aplicación Android para `com.ivc.lili` y el SHA-1 del certificado con el que compilas. Los certificados de depuración y producción pueden ser diferentes.
2. Coloca `MAPS_API_KEY=tu_clave` en `android/maps.properties`, ignorado por Git. Hay un ejemplo en `android/maps.properties.example`. Gradle también admite la variable de entorno `MAPS_API_KEY`. La clave que ya traía el proyecto se ha conservado en el archivo local; su pertenencia, facturación y restricciones deben comprobarse en Google Cloud. Ya no se mantiene una clave literal en el manifiesto.
3. Activa solo `ORDER_MAP_ENABLED` en tu configuración de compilación y reconstruye la app. Puede coexistir con `EXTERNAL_SERVICES_ENABLED=false`. No hace falta activar Firebase para dibujar el mapa.

```json
{
  "API_BASE_URL": "http://10.0.2.2:3000/api/",
  "SOCKET_URL": "http://10.0.2.2:3000",
  "EXTERNAL_SERVICES_ENABLED": false,
  "ORDER_MAP_ENABLED": true
}
```

```powershell
.\flutterw.ps1 run --dart-define-from-file=config/local-emulator.json
```

Un mapa visible no garantiza movimiento del marcador: el pedido debe estar asignado o recogido, pertenecer al cliente y tener un motorizado conectado que envíe GPS con permisos de ubicación. NestJS autoriza al observador contra su pedido activo; Cloudinary no interviene en ese transporte. La recepción de coordenadas y su aplicación al marcador se verifican también contra el gateway Nest real con `test_backend/backend_contract_test.dart`.

El GPS del cliente no es necesario para ver al motorizado: se utilizan la dirección del pedido y las coordenadas recibidas. El seguimiento no solicita permisos de ubicación al cliente para dibujar su mapa.

La revisión Android cargó el mapa de Loja con la clave existente, sin errores de autorización del SDK. `config/local-emulator.json` vuelve a activar el mapa del pedido manteniendo Firebase desactivado. La captura del seguimiento utiliza un pedido y coordenadas controlados de prueba; no representa un recorrido GPS real ni crea pedidos en tu base de datos. La propiedad de la clave y su configuración para producción siguen siendo responsabilidad del proyecto de Google Cloud.

Fuentes: [configuración de Maps para Flutter](https://developers.google.com/maps/flutter-package/config), [restricciones de claves](https://developers.google.com/maps/api-security-best-practices).

## Viabilidad de Cloudinary

El proyecto es compatible. Las entidades de usuario, restaurante y producto guardan `image` como URL y Flutter ya muestra imágenes de red. Las subidas actuales están centralizadas en `lib/src/common/file_helper.dart`, usado por perfil, negocio y productos, y utilizan Firebase Storage. Este análisis no activa Cloudinary ni cambia el proveedor de las imágenes existentes.

La integración propuesta es:

1. NestJS autentica al usuario y autoriza el recurso que quiere modificar. Genera una firma con carpeta, identificador, formato y límites controlados por el servidor. El `api_secret` permanece en el backend.
2. Flutter comprime la imagen y la sube directamente a Cloudinary con esa firma. No se incluye el secreto en el APK ni se permiten parámetros arbitrarios para firmar.
3. NestJS verifica la respuesta y guarda la URL HTTPS del recurso junto con su identificador. Las pantallas existentes pueden seguir usando el campo `image`.
4. Se migran imágenes antiguas gradualmente y se controla la eliminación de archivos reemplazados. Cloudinary permite importar desde URLs accesibles; no hace falta cambiar todos los registros a la vez.

Conviene limitar peso, dimensiones y formatos, generar pocas variantes de tamaño reutilizables y revisar el consumo de almacenamiento, transferencia y transformaciones del plan. La lectura de URLs de Cloudinary puede coexistir con URLs antiguas de Firebase durante la transición. Cambiar el almacenamiento de imágenes no obliga a cambiar las notificaciones ni el seguimiento del motorizado.

El proveedor de subidas debe tener una configuración propia para poder usar Cloudinary en el entorno local sin habilitar Firebase o Stripe. No conviene reutilizar el indicador global de servicios externos para esa decisión.

Fuentes: [subidas desde aplicaciones cliente](https://cloudinary.com/documentation/client_side_uploading), [migración de medios](https://cloudinary.com/documentation/migration), [consumo y planes](https://cloudinary.com/documentation/billing_and_plans).

## Bienvenida

La pantalla nueva explica qué permite hacer la app, tiene accesos a elegir dirección y a iniciar sesión/registrarse, y se adapta a pantallas pequeñas y texto ampliado. Se retiraron el texto del proveedor y los enlaces legales de la plantilla anterior. Los enlaces propios se pueden configurar con `APP_PRIVACY_URL` y `APP_TERMS_URL`; solo aparecen cuando están definidos.

## Validación

- 136 pruebas de unidad/widgets y análisis estático sin incidencias.
- Nueve pruebas de contrato contra NestJS y dos del modo local sin Firebase, con `ORDER_MAP_ENABLED=true`.
- `test/location/order_tracking_test.dart`: conexión sin mapa/Firebase, primera ubicación real, conservación de la conexión, cambio de motorizado, fin del seguimiento, detección de asignación sin push, errores de red y presentación sin mapa.
- `test/ui/welcome_test.dart`: temas claro/oscuro, anchos de 320 y 411 px, texto al 130 %, desplazamiento y acceso al registro.
- `test_backend/backend_contract_test.dart`: incluye una prueba del controlador del cliente recibiendo una coordenada por el gateway Nest real y actualizando el marcador, sin mapas ni Firebase.
- `integration_test/welcome_tracking_experience_test.dart`: mapa nativo Android con coordenadas controladas, bienvenida y navegación al acceso. Conserva la sesión nativa y no escribe pedidos en la base.

Las capturas se guardan en `.tools/ui-review/ui-welcome-minimal*.png` y `ui-tracking-map-independent.png`. La app instalada se reconstruye con `lib/main.dart`, sin credenciales ni datos controlados del recorrido de prueba.
