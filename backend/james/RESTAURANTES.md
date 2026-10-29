# Restaurantes: cocina y administración

El estado de cocina es independiente de `status`, que conserva los códigos de asignación, retiro, entrega y cancelación existentes.

| Estado de cocina | Significado |
| --- | --- |
| `pending` | Pedido nuevo, pendiente de aceptación |
| `preparing` | Aceptado por el restaurante |
| `ready` | Listo para retiro |
| `null` | Pedido anterior a esta funcionalidad; conserva el flujo de entrega anterior |

## Contrato

- `PATCH /api/manager/request/:id/accept`, con `{ "preparationMinutes": 25 }`: acepta un pedido pendiente y registra `acceptedAt`. Admite entre 5 y 120 minutos enteros; Flutter ofrece 15, 25 y 35 minutos.
- `PATCH /api/manager/request/:id/ready`: registra `readyAt` para un pedido en preparación.
- Ambas rutas requieren rol `manager`, propiedad del local y un pedido en estado de entrega `STARTED` o `ASSIGNED`. Devuelven `{ "request": ... }`. No admiten volver a una etapa anterior. Los reintentos de la misma operación no vuelven a modificar sus fechas; cambios incompatibles devuelven HTTP 409.
- La actualización comprueba propietario, etapa y estado de entrega también en el `UPDATE`, para rechazar acciones simultáneas incompatibles.
- Un pedido nuevo se ofrece al motorizado después de aceptarlo el restaurante. Puede asignarse durante la preparación, pero solo puede retirarse cuando esté listo. Las filas anteriores a la migración conservan su comportamiento.
- Se informa el cambio al cliente y al motorizado asignado. Los envíos externos no condicionan el éxito de una transición ya guardada. Firebase permanece desactivado en el perfil local; la app del restaurante actualiza sus pedidos cada 20 segundos mientras está activa y permite actualización manual.

Las consultas y cambios de pedidos, productos y horarios se limitan al negocio del usuario autenticado. Los productos pertenecen a una compañía y se comparten entre sus locales; la gestión exige que el usuario tenga un local de esa compañía. No se permite reasignar un producto a otra compañía al editarlo. Los horarios requieren horas válidas en formato `HH:mm:ss`.

## Migración y datos locales

```powershell
.\dev.ps1 run build
.\dev.ps1 run migration:run
.\dev.ps1 run db:seed:restaurant
.\dev.ps1 run db:check
```

La tercera migración es aditiva y no interpreta el estado de cocina de pedidos antiguos. La demostración está protegida para ejecutarse únicamente en PostgreSQL local y `NODE_ENV=development`. Crea `restaurante.demo@delivery.local`, un negocio llamado **Restaurante de prueba**, un producto, siete horarios y un pedido en efectivo de demostración para el cliente local. No cobra ni altera saldos existentes. Guarda la contraseña generada y los identificadores en `.local/restaurant-credentials.json`, fuera de Git. Repetir el seed no restablece la contraseña, el menú ni el estado del pedido.

El backend y la versión de Flutter con aceptación de cocina deben desplegarse coordinados: las aplicaciones antiguas de restaurante no tienen la acción necesaria para aceptar pedidos nuevos.

## Verificación

```powershell
.\dev.ps1 run verify
.\dev.ps1 run test:db
.\dev.ps1 run test:restaurant
```

`test:db` comprueba aplicación, reversión, reaplicación y ausencia de diferencias de esquema en una base desechable. `test:restaurant` levanta la aplicación real con PostgreSQL aislado, sin servicios externos, y comprueba permisos, validación, aceptación, preparación, retiro, reintentos, concurrencia, pedidos anteriores, consulta del cliente, menú y horarios. Elimina su base al finalizar y no usa las credenciales de los usuarios locales.
