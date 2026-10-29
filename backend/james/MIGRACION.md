# Migración del backend

Inicio: 27 de octubre de 2026.

## Entregas y puntos de retorno

El historial Git de esta carpeta conserva el backend entregado, excluyendo `.env`, dependencias, compilados y herramientas locales. Cada etapa validada se guarda en un commit independiente.

| Etapa | Alcance | Estado |
| --- | --- | --- |
| Base | Node 24 LTS, lockfile, configuración y pruebas HTTP aisladas | Validada: build, tipos, 12 pruebas unitarias y 15 HTTP |
| NestJS 10 | Actualizar el framework y adaptadores desde 9 | Validada en 10.4.22: build, tipos y 27 pruebas |
| NestJS 11 | Actualizar el framework y comprobar Express 5 | Validada en 11.2.8: build, tipos, 12 pruebas unitarias y 17 HTTP |
| NestJS 12 | Actualizar framework, CLI, TypeScript y Jest | Validada en 12.3.2 con TypeScript 6.0.3, Jest 30 y Node 24 |
| Integraciones | Firebase Admin, correo, bcrypt y auditoría de producción | Implementada: 37 pruebas y auditoría npm completa con cero avisos |
| Seguridad del negocio | Verificación de Google, cobros/saldos y permisos WebSocket | Pendiente |
| Base de datos | Migraciones de esquema y pruebas con PostgreSQL/PostGIS aislado | Pendiente |

La migración de librerías no certifica el funcionamiento del sistema completo ni corrige automáticamente los problemas de negocio descritos en la revisión inicial.

## Configuración

- Node de referencia: 24.22.1, fijado en `.nvmrc` y `.node-version`. El Node global de Windows no se modifica.
- `package-lock.json` fija las dependencias resueltas. Usar `npm ci` para instalaciones reproducibles.
- `.env.example` contiene únicamente ejemplos. Las credenciales existentes de `.env` no se modifican.
- `JWT_SECRET` es el nombre recomendado. `JWT_SECREAT` sigue aceptándose y conserva la clave de firma de despliegues existentes.
- `DB_SYNCHRONIZE` pasa a `false` por defecto. Su activación se rechaza en producción. No se ejecutan migraciones automáticamente.
- Para una base desechable de desarrollo, `DB_SYNCHRONIZE=true` es una opción explícita; nunca debe usarse para sustituir migraciones de una base con datos que deban conservarse.

## Validación

Las pruebas HTTP utilizan controladores, DTO, Passport, JWT y permisos reales, con servicios de negocio y repositorios sustituidos por dobles de prueba. No leen `.env`, no conectan a la base entregada y no envían correo, cobros o notificaciones.

`npm run verify` compila, revisa los tipos de aplicación y tests, ejecuta lint y corre 20 pruebas unitarias y 17 HTTP. Incluye compatibilidad de hashes bcrypt 5/6, el contrato de envío de Firebase y la renovación OAuth del correo con transportes simulados. Las pruebas usan infraestructura simulada y no validan la disponibilidad de servicios externos.

La etapa 12 conserva CommonJS en la aplicación y utiliza resolución `NodeNext`. Los tests usan la opción `--experimental-vm-modules` de Node para cargar los paquetes ESM de Nest desde Jest 30; esa opción no se necesita para el servidor en producción. El caché incremental de TypeScript se guarda dentro de `dist` para que una limpieza no genere compilaciones vacías. `postbuild` comprueba la existencia de la entrada y carga controladores compilados sin arrancar servicios.

Docker está instalado pero su motor no estaba activo al iniciar el trabajo. Las pruebas reales de SQL, transacciones, PostGIS y arranque con infraestructura quedan pendientes de una base aislada. No ejecutar el backend contra la base existente para suplir esa comprobación.

## Dependencias finales de las integraciones

| Componente | Resultado |
| --- | --- |
| Firebase Admin | 14.5.0, inicialización reutilizable y `sendEachForMulticast` en lugar del método retirado |
| Nodemailer | 10.2.1 |
| OAuth de Google | `google-auth-library` 11.3.1; sustituye `googleapis`, que solo se usaba para OAuth |
| bcrypt | 6.0.0; comprobado con un hash de prueba generado previamente con 5.1.1 |
| Passport | 0.7.0, manteniendo autenticación JWT y sesiones existentes |
| TypeORM | Rama 0.3 conservada en 0.3.31; el salto a 1.x se evaluará con la fase de datos |
| Herramientas | TypeScript 6.0.3, Jest 30.5.2, ESLint 10.13.0 y Prettier 3.9.10 |

Se actualizaron también los mínimos de los rangos conservados a las versiones verificadas del lockfile. `rimraf` pasa a desarrollo. Los scripts de instalación están declarados en `allowScripts`: bcrypt tiene aprobación fijada a su versión; los postinstall opcionales que no necesitan las comprobaciones actuales están desactivados explícitamente.

La auditoría npm completa del 27 de octubre de 2026 reportó 0 avisos (incluido desarrollo). El resultado inicial de 36 entradas pertenecía a la resolución temporal del código antiguo y ya no describe este árbol. Lint termina sin errores ni advertencias. Dos valores de enums se conservan con excepciones locales documentadas para mantener los códigos del cliente y los radios de búsqueda existentes.

La instalación final se repitió con `npm ci` desde un árbol de dependencias limpio. Después se ejecutó de nuevo `npm run verify` y la auditoría completa, conservando los 37 tests aprobados y cero vulnerabilidades reportadas.

## Siguiente fase

El 28 de octubre se añadió el entorno de `ENTORNO_LOCAL.md`: migraciones para 14 tablas y tres vistas, PostGIS, seed repetible de dos usuarios con saldos en cero y comandos de inicio/parada. Se usa el PostgreSQL 16 nativo con la base configurada en `.env`, en `localhost:5432`. Se verificaron esquema sin diferencias, aplicación idempotente y rollback/reaplicación en una base temporal, vistas, distancias, puntos, borrado lógico y cascadas. Pasan 50 pruebas y 25 comprobaciones contra la API local con las cuentas creadas. El modo local desactiva integraciones externas; `.env` y `.local` quedan excluidos de Git.

La integración con Flutter del 28 de octubre detectó que el target ES2023 emitía campos de entidades sin inicializar como propiedades propias con valor `undefined`. `class-transformer` creaba esas propiedades al validar referencias anidadas y `forbidNonWhitelisted` las rechazaba, aunque el cliente solo enviara `{id}`. Se fija `useDefineForClassFields=false` para conservar el comportamiento anterior de esos campos. Se añaden tres regresiones de chat, pedidos, pagos y productos; los campos extra siguen rechazándose. Build, typecheck, lint y 40 pruebas del backend pasan. Ocho pruebas adicionales desde Flutter ejercitan los controladores, DTOs, guards JWT y el gateway Socket.IO con proveedores de negocio aislados, sin base de datos ni servicios externos.

1. Verificar tokens de Google en el servidor y coordinar el envío de esos tokens desde Flutter.
2. Acreditar saldo solo tras verificar el resultado de Stripe, con transacciones e idempotencia.
3. Autorizar salas y actualizaciones de ubicación según el usuario autenticado.
4. Ampliar las pruebas PostgreSQL/PostGIS a los recorridos completos de pedidos, transacciones de saldos y asignación, utilizando cuentas externas de prueba cuando corresponda.

Estas tareas siguen pendientes. No se debe interpretar la ausencia de avisos npm como una certificación de seguridad de la aplicación.

## Referencias

- [Migración oficial de NestJS](https://docs.nestjs.com/migration-guide).
- [Releases de Node.js](https://nodejs.org/en/about/previous-releases).
- [Notas de Firebase Admin para Node](https://firebase.google.com/support/release-notes/admin/node).
