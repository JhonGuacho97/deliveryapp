# Catálogo visual y pantalla del restaurante

El inicio presenta platos y restaurantes en carruseles con fotografías. Los
platos muestran precio, nombre, negocio y un botón para agregar o quitar del
carrito. Los restaurantes muestran portada, apertura, dirección y horario.
Se conserva la búsqueda global de NestJS y sus filtros por dirección/categoría.

Dentro del local hay una portada que se contrae al desplazar, nombre y dirección,
estado de apertura, horario y cotización real del envío. El acceso a información
del restaurante permite consultar dirección, teléfono y horario. Los datos que
la API no proporciona, como calificaciones o tiempos de viaje, no se inventan.

El buscador del menú y los filtros Todo / Hasta 5 USD / Más de 5 USD permanecen
visibles al desplazar. Se combinan sin peticiones adicionales y la búsqueda
ignora tildes y mayúsculas. El menú usa una cuadrícula que pasa a una columna
en teléfonos con texto muy ampliado. Tocar una tarjeta abre su imagen, precio,
descripción completa y acción de carrito. Se conservan las cantidades y notas
del carrito existente; la creación de pedidos y los pagos mantienen sus contratos.

Las respuestas tardías de un local anterior se descartan. Una actualización
fallida conserva el menú que ya se había cargado e informa el error. El envío
se vuelve a cotizar por local; cuando todavía no está disponible se indica que
se calculará al confirmar.

## Imágenes

`CatalogImage` reserva el espacio de la foto y muestra un fondo discreto si la
imagen está vacía, cargando o falla. Las URLs existentes y las de proveedores
como Cloudinary se muestran mediante la caché de imágenes ya instalada.

Los datos locales incluyen cinco portadas y treinta fotos ilustrativas de
Unsplash. El fixture y el seed están en `backend/james/scripts/`; detalles de
origen y conservación de imágenes propias en `backend/james/CATALOGO_LOCAL.md`.
Estas imágenes pertenecen a los ejemplos de demostración.

## Validación

```powershell
.\flutterw.ps1 verify
.\flutterw.ps1 drive --keep-app-running --driver=test_driver/ui_driver.dart --target=integration_test/storefront_visual_experience_test.dart -d emulator-5554 --dart-define-from-file=config/local-emulator.json
```

Las 150 pruebas de Flutter comprueban además búsqueda local combinada con precio,
respuestas fuera de orden, recuperación de errores, detalle y acción de carrito,
temas claro/oscuro, anchos de 320 px y texto al 130 % y 200 %. El análisis estático
queda sin incidencias. El backend aprueba 97 comprobaciones de catálogo en
PostgreSQL desechable, incluyendo idempotencia y conservación de fotos propias.

El recorrido Android usa los endpoints públicos del backend local con las fotos
de demostración, recorre inicio, restaurantes, búsqueda del menú, filtro por
precio, detalle y carrito, y toma capturas en `.tools/ui-review/ui-storefront-*`.
Utiliza un control de sesión aislado para evitar cerrar la cuenta nativa del
usuario, restaura su carrito y no crea pedidos ni modifica su dirección existente.
Después se recompila el APK normal desde `lib/main.dart`.

Recorrido aprobado el 29 de octubre de 2026 en Pixel 4 XL API 34. Se revisaron
las capturas de inicio, restaurantes, portada, cuadrícula, filtros, detalle y
carrito, incluyendo el tema oscuro. La base local conserva los datos de prueba
previos y sus fotos ilustrativas; el recorrido no crea cuentas ni pedidos.
