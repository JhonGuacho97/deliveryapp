# Navegación Liquid Glass

La barra inferior compartida usa `liquid_glass_widgets` **1.16.0**, la versión
publicada del [repositorio solicitado](https://github.com/sdegenaar/liquid_glass_widgets).
Se fija esa versión en `pubspec.yaml` y su checksum en `pubspec.lock`.
Requiere Flutter >=3.41; el SDK local del proyecto es 3.47.8. El paquete añade
sus shaders y depende solamente del SDK de Flutter.

## Comportamiento

- Cliente: Explorar / Pedidos / Cuenta; restaurante: Pedidos / Menú / Negocio;
  motorizado: Entregas / Ingresos / Cuenta.
- Cápsula flotante con desenfoque y reflejos, lente móvil, aumento de 1.22 y
  deformación elástica al mantener y deslizar el dedo. También admite toques.
- La preselección visual sigue el gesto. La pantalla y sus consultas cambian
  una vez al soltar, conservando el índice de los controladores existentes.
- Un `PointerCancel` descarta la preselección y restaura la lente en la pestaña
  actual. Activar con teclado o lector de pantalla no requiere un gesto táctil.
- Tema salvia en claro y oscuro. Calidad `standard` para los shaders, evitando
  la captura multipaso de `premium` en la barra. Se respetan las preferencias
  del sistema de movimiento reducido y alto contraste. El aumento se desactiva
  con movimiento reducido.
- El carrito permanece encima de la cápsula y el dock respeta el área segura
  del sistema. El final de las listas incorpora su altura real medida por
  `Scaffold`, para poder desplazar las últimas acciones por encima del dock.
- `GlassPage` proporciona el contexto de renderizado, conservando `Scaffold`
  Material para las cabeceras, mensajes, teclado y navegación existentes.
  `main()` precarga los shaders mediante `LiquidGlassWidgets.initialize()`.

La implementación está en `lib/src/widgets/delivery_glass_scaffold.dart`.

La cápsula mantiene su material translúcido, con tinte al 20 %, refracción y
desenfoque. `GlassContentAwareScope` captura el contenido detrás de la barra,
separado de los controles, y adapta el color de letras e iconos. La selección
usa verde intenso sobre contenido claro y menta sobre contenido oscuro; las
demás pestañas usan texto oscuro o blanco. Una sombra fina refuerza los glifos
sin añadir un relleno opaco. Cuando termina de cargar una fotografía, se pide
una nueva lectura del fondo. Los títulos miden 13 px, con mayor peso en la
selección. Se conservan el arrastre, la lente y el aumento. Las preferencias
de movimiento reducido y alto contraste siguen aplicándose.

## Comprobaciones

```powershell
.\flutterw.ps1 verify
.\flutterw.ps1 drive --keep-app-running --driver=test_driver/ui_driver.dart --target=integration_test/liquid_navigation_experience_test.dart -d emulator-5554 --dart-define-from-file=config/local-emulator.json --dart-define=ORDER_MAP_ENABLED=false
```

Las pruebas de widgets comprueban selección al soltar, cancelación, preselección
al mantener otra pestaña, texto al 200 % en 320 px, carrito, área segura, última
acción accesible, alto contraste, movimiento reducido, teclado y dirección RTL.

La revisión de contraste añade el recorrido
`integration_test/storefront_visual_experience_test.dart`, con el catálogo y
fotografías de la API local, apariencia clara y oscura y arrastre de la lente.
Capturas: `ui-storefront-home.png`, `ui-navigation-photos-*.png` y
`ui-glass-contrast-*.png`, en `.tools/ui-review/`. El ajuste pasó 42 pruebas
relacionadas de navegación, catálogo, cliente, restaurante y motorizado, análisis estático
y el recorrido Android con los datos reales de demostración.

El recorrido Android utiliza las pantallas y datos controlados de los tres
roles, toma capturas durante el arrastre y comprueba el índice antes y después
de soltar. Después recorre carrito/pedidos del cliente, cocina/menú/negocio y
entregas/ingresos/cuenta. Conserva la sesión y restaura el carrito y dirección
locales. No inserta pedidos en PostgreSQL. Las capturas se guardan en
`.tools/ui-review/ui-glass-*.png`.

`ORDER_MAP_ENABLED=false` se aplica únicamente a ese recorrido para conservar
la comprobación de seguimiento sin mapa del harness del cliente. El APK normal
se compila con `lib/main.dart` y `config/local-emulator.json`, que conserva
`ORDER_MAP_ENABLED=true`. El cambio de navegación no cambia Maps ni el backend.

Validación del 29 de octubre de 2026: análisis sin incidencias, 143 pruebas de
unidad/widgets aprobadas y los tres recorridos Android aprobados en Pixel 4 XL
API 34. Se revisaron las capturas del cliente, del carrito y de los otros roles.
Sobre el APK normal se comprobó además un gesto táctil continuo de Android,
capturando la lente ampliada en Pedidos mientras el catálogo seguía visible y
el cambio a Cuenta al soltar. Capturas: `ui-glass-installed.png`,
`ui-glass-installed-scrub.png` y `ui-glass-installed-account.png`.
La comprobación en Android se realiza con el emulador; no equivale a una medida
de rendimiento en dispositivos físicos ni a una validación de iOS.

Documentación de referencia: [instalación, calidad y accesibilidad](https://github.com/sdegenaar/liquid_glass_widgets#readme).
