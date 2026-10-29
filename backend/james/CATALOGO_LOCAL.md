# Catálogo y menús de prueba

El entorno local contiene **cinco restaurantes y 30 productos** cerca de la dirección predeterminada de Flutter: latitud `-4.0236715`, longitud `-79.1978733` (Loja). Los datos se guardan en PostgreSQL y son visibles para el cliente, el restaurante y el administrador.

| Restaurante | Categoría | Productos |
| --- | --- | --- |
| Restaurante de prueba | Comida casera | Bowl de pollo, pollo con menestra, arroz con camarón, menú vegetariano, encebollado y limonada |
| La Esquina · Pizzería Demo | Pizzas | Margarita, pepperoni, vegetariana, cuatro quesos, pan de ajo y limonada |
| Barrio Burger · Demo | Hamburguesas | Clásica, doble, pollo, vegetariana, papas rústicas y agua |
| Verde y Fresco · Demo | Saludable | Bowls mediterráneo y de quinoa, ensalada de pollo, wrap, jugo verde y yogur con granola |
| Café del Parque · Demo | Café y postres | Cappuccino, americano, latte, cheesecake, brownie y croissant |

Cada producto tiene descripción y precio en USD. Los cuatro restaurantes nuevos tienen horarios de `00:00` a `23:59:59`, los siete días, en UTC-5. El restaurante original conserva el horario y los precios que ya tuviera. Todos pertenecen a la cuenta de restaurante existente, cuyas credenciales están en `.local/restaurant-credentials.json`. Se conservan los pedidos y las direcciones anteriores.

## Carga reproducible

```powershell
.\dev.ps1 run build
.\dev.ps1 run migration:run
.\dev.ps1 run db:seed:restaurant
.\dev.ps1 run db:seed:catalog
```

El último comando solo se permite en desarrollo con PostgreSQL local. Usa `scripts/fixtures/catalog-demo.json` y guarda los identificadores y precios en `.local/catalog-demo.json`. Repetirlo no duplica filas ni reinicia precios, horarios o productos eliminados. Rechaza colisiones con negocios o productos de otra cuenta. La operación completa utiliza una transacción.

## Fotos de demostración

Los cinco restaurantes y los treinta platos de `scripts/fixtures/catalog-demo.json`
incluyen URLs de imágenes ilustrativas de Unsplash. Son referencias visuales para
los datos de prueba, no fotografías de los negocios o de sus platos reales.
Las fuentes quedan identificadas por sus URLs en el fixture y se usan bajo la
[licencia de Unsplash](https://unsplash.com/license).

`dev.ps1 run db:seed:catalog` incorpora las imágenes a registros de demostración
que todavía tengan el campo vacío. Verifica la propiedad de la cuenta, conserva
fotos cargadas por el usuario, precios y horarios, y no restaura productos
eliminados. Devuelve `updatedImages` para comprobar cuántos registros se completan.
En la base local se completaron cinco portadas y treinta platos; la segunda
ejecución no modificó imágenes.

Validación del 29 de octubre de 2026: 97 comprobaciones del catálogo con
PostgreSQL desechable, incluyendo conservación de fotos personalizadas y carga
idempotente de imágenes. No se requieren migraciones nuevas.

## Corrección de visibilidad

La API devolvía el restaurante sin `type`, aunque el modelo Flutter lo exigía. El cliente descartaba el catálogo al intentar convertir ese registro. La API ahora añade `type: 10` para las tiendas y Flutter admite el contrato anterior sin ese campo.

La vista de horarios aplicaba el desplazamiento UTC sobre una hora que PostgreSQL ya había convertido a la zona local. Esto podía marcar cerrado un negocio que ya estaba abierto. La migración `CatalogVisibility1793310000000` calcula desde UTC, contempla horarios nocturnos y conserva visibles como cerrados los locales sin horario. También excluye locales y productos eliminados.

Las categorías se filtran por ubicación antes de eliminar duplicados. Las distancias y el costo de envío utilizan longitud/latitud en el orden de PostGIS, respetando los puntos históricos guardados como `x = latitud`, `y = longitud`. El radio comercial configurado previamente se conserva.

## Búsqueda global

`GET /api/client/market/companies?latitude=...&longitude=...&query=pizz` busca en todos los menús de los restaurantes elegibles por ubicación y categoría. Devuelve platos por nombre o descripción y restaurantes por nombre, categoría o coincidencias en sus platos. Sin `query` conserva los destacados del inicio. Ignora mayúsculas y tildes; `%`, `_` y barras se tratan como texto literal y los parámetros SQL están enlazados. El texto acepta hasta 120 caracteres. `limit` y `offset` se aplican por separado a platos y restaurantes, con orden estable; no se limita la búsqueda al primer grupo de restaurantes de la portada.

Flutter envía el texto al servidor y muestra los restaurantes relacionados aunque su nombre no contenga el término. Ejemplo local: `pizz` encuentra cuatro pizzas y La Esquina; `pepperoni` encuentra ese plato y su pizzería. No requiere otra migración ni modificar los datos existentes.

## Validación

- `dev.ps1 run test:catalog`: 92 comprobaciones con PostgreSQL desechable y la API NestJS real: catálogo y menús, búsqueda global y paginación entre restaurantes, categorías, cotización del envío, repetición del seed, conservación de precios y eliminaciones, zonas horarias y horarios nocturnos.
- `dev.ps1 run test:db`: cinco migraciones aplicables, reversibles y sin diferencias con las entidades.
- `dev.ps1 run verify`: compilación, tipos, lint, 39 pruebas unitarias y 17 HTTP.
- Regresiones: 41 comprobaciones de restaurante, 58 de motorizado y 25 del entorno local.
- Flutter: 93 pruebas de unidad/widgets y análisis estático sin incidencias. La nueva regresión reproduce el JSON que provocaba el catálogo vacío.
- `integration_test/catalog_local_backend_test.dart`: login real como cliente, selección de su dirección en las coordenadas predeterminadas, lectura de los cinco menús, búsqueda del restaurante original, apertura del menú y consulta del envío en Android. Conserva la cuenta del cliente para la revisión y no crea pedidos.

El test Android recibe las credenciales mediante un archivo ignorado con `UI_LOCAL_EMAIL` y `UI_LOCAL_PASSWORD`. Después se reconstruye el APK normal con `lib/main.dart` y únicamente `config/local-emulator.json`.
