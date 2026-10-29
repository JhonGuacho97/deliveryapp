<p align="center">
  <a href="https://www.planck.biz/" target="blank"><img src="https://play-lh.googleusercontent.com/d__eJWphVBKSH5WvOumfF7GrEnn0MkIshq0CbCAhezMKHsk0-Qnf4HuQ6aPYcEPD8GQ=w480-h960-rw" width="200" alt="Planck Logo" /></a>
</p>

# James Server Lili

Backend de delivery migrado de NestJS 9 a 12 mediante etapas verificadas. El detalle de los cambios, puntos de retorno y pendientes está en `MIGRACION.md`.

## Entorno

- Node.js 24.22.1 LTS; se acepta la línea 24 desde 24.15.
- npm 11.19.1, incluido en el entorno de referencia.
- PostgreSQL con PostGIS para ejecutar los flujos de negocio.
- Credenciales propias de Firebase, Google OAuth, correo, Maps y Stripe.

La CLI de Nest forma parte del proyecto; los comandos de esta guía usan esa versión local.

## Instalación y verificación

Con Node 24 activo, desde esta carpeta:

```sh
npm ci
npm run verify
npm audit
```

`verify` compila, comprueba la carga de controladores compilados, revisa tipos y lint, y ejecuta las pruebas unitarias y HTTP con infraestructura aislada. Las comprobaciones con PostgreSQL real se ejecutan por separado con `test:db` y `test:local`.

En esta máquina Windows hay un Node 24 portátil en `.tools`, excluido de Git. El siguiente lanzador lo selecciona para cada comando, conservando el Node global del equipo:

```powershell
.\dev.ps1 ci
.\dev.ps1 run verify
.\dev.ps1 audit
```

Si se clona el proyecto en otro equipo, instalar primero Node 24 o preparar su runtime portátil. `dev.ps1` también funciona con Node 24 instalado normalmente.

## Configuración y ejecución local

Tomar `.env.example` como referencia y configurar `.env` con una base de desarrollo aislada y recursos propios antes de iniciar el servidor. El ejemplo contiene marcadores que deben reemplazarse. Mantener las credenciales fuera de Git.

Variables principales: `NODE_ENV`, `PORT`, `DB_HOST`, `DB_PORT`, `DB_USERNAME`, `DB_PASSWORD`, `DB_NAME`, `DB_SYNCHRONIZE`, `JWT_SECRET`, `FIREBASE_CREDENTIAL_JSON`, `ACCOUNT_TRANSPORT`, `STRIPE_SECRET_KEY` y `API_KEY_GOOGLE`.

La preparación y los comandos de este equipo están en [ENTORNO_LOCAL.md](ENTORNO_LOCAL.md). `EXTERNAL_SERVICES_ENABLED=false` permite trabajar localmente sin inicializar Firebase/correo ni llamar a Stripe o Google Places.

`JWT_SECREAT` sigue aceptándose para los despliegues que usan el nombre anterior. `JWT_SECRET` tiene prioridad si se definen ambos.

`DB_SYNCHRONIZE=false` es el valor predeterminado y obligatorio en producción. No se ejecutan migraciones automáticamente. Para una base local nueva con PostGIS, `npm run db:setup` crea la base, aplica el esquema y genera un administrador y un cliente. Las contraseñas se guardan en `.local/credentials.json`, fuera de Git. El compose original no se utiliza en la configuración nativa de Windows.

```sh
npm run start:dev
```

La API conserva el prefijo `/api` y utiliza `PORT` (3000 por defecto). Para ejecutar los compilados:

```sh
npm run build
npm run start:prod
```

Las pruebas con Jest usan `--experimental-vm-modules` por la carga de paquetes ESM de NestJS 12. El servidor compilado conserva CommonJS y no necesita esa opción. Un aviso experimental de Node durante los tests es esperado.

## Estado de la migración

Las etapas de framework e integraciones están implementadas. La auditoría npm del 27 de octubre de 2026 reportó cero avisos en el árbol completo de dependencias. Esto no valida los flujos de negocio ni sustituye las correcciones pendientes de autenticación Google, acreditación de pagos y permisos de ubicación.

Las migraciones y el entorno PostgreSQL/PostGIS local están implementados y probados, incluidas las cuentas y permisos contra la API real. Siguen pendientes los recorridos completos de negocio y las pruebas con proveedores externos antes de un despliegue.

Autor original: [Juan Pablo Guamán Rodríguez (Planck)](https://www.planck.biz/).
