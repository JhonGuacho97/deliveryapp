# Formularios con diseño unificado

Los formularios siguen la referencia visual aportada: superficie blanca, etiquetas sobre los campos, contornos discretos, esquinas suaves y espacios uniformes. Se conserva el acento salvia en las acciones y el foco, con una variante equivalente para el tema oscuro.

## Componentes compartidos

- `lib/src/widgets/forms/form_fields.dart`: campos de texto, contraseña con control de visibilidad, teléfono y valores informativos de solo lectura.
- `lib/src/widgets/forms/form_page.dart`: página desplazable y área de acciones adaptada al teclado; diálogos con desplazamiento y ancho limitado.
- `lib/src/widgets/forms/form_options.dart`: selección de categorías, grupos y forma de pago con el mismo tratamiento visual.

Las etiquetas permanecen visibles al escribir. Los errores pueden ocupar varias líneas y los campos no usan contenedores verdes alrededor del editor. Los botones principales ocupan el ancho de los campos. En pantallas amplias el contenido se limita a un ancho cómodo.

## Pantallas actualizadas

| Área | Formularios y controles |
| --- | --- |
| Cuenta | Perfil de cliente, restaurante y motorizado; cambio de contraseña y foto |
| Acceso | Inicio de sesión, registro y recuperación de cuenta |
| Direcciones | Creación y edición de alias y dirección |
| Restaurante | Alta del negocio, categoría, contacto, producto nuevo y edición de productos |
| Administración | Teléfono e importe para recarga |
| Compra | Notas, billetera y forma de pago |
| Controles relacionados | Selector de local, grupos, búsqueda de direcciones y editor del chat |

El perfil usa iniciales cuando no hay foto propia. La imagen sigue dependiendo del servicio de almacenamiento configurado; el perfil local no presenta una subida disponible cuando ese servicio está desactivado. Los saldos se presentan como información, sin foco ni teclado de edición. No se muestran estados de verificación de correo o teléfono que el backend no proporciona.

## Corrección del desbordamiento

La advertencia amarilla del perfil era un desbordamiento de Flutter. La estructura anterior colocaba `Expanded` dentro de `Form`, añadía espacio vertical fijo y dejaba el botón fuera de una distribución adaptable.

La nueva estructura coloca el contenido desplazable dentro de un `Expanded` que pertenece directamente a la columna, y reserva el espacio de las acciones dentro del área que se ajusta al teclado. El pie respeta el área segura y el último campo sigue siendo accesible mediante desplazamiento. Se eliminaron también los campos de saldo con `autofocus` y las pestañas de acceso con ancho fijo.

## Guardado y validación

Guardar perfil permanece desactivado hasta que hay una edición. El teléfono existente aparece rellenado; modificar solo el correo o el nombre conserva el número guardado. Si el servidor rechaza el cambio, el borrador sigue disponible para reintentar.

La validación se ejecuta antes de guardar o convertir importes numéricos. Los formularios que cierran mientras una petición sigue pendiente no intentan actualizar su interfaz descartada. Los límites y contratos de los campos existentes se conservan.

## Validación

- 121 pruebas de unidad/widgets, incluidas 28 nuevas de formularios.
- Matriz con ancho de 320 px, texto al 130 %, temas claro y oscuro y teclado de 280 px. Incluye perfil en los tres roles, acceso, registro, recuperación, recarga, negocio y productos nuevos/editados.
- Diálogos de dirección y contraseña con teclado y errores; guardado correcto y rechazado del perfil; conservación del teléfono; producto con precio decimal y borrador ante un rechazo; importe de recarga inválido y cierre de una petición pendiente.
- 8 pruebas de contratos NestJS y 2 del perfil local.
- Recorrido Android de los formularios, validación y teclado. Una segunda prueba inicia sesión con el cliente real y abre su perfil contra el backend local, sin cambiar sus datos.
- Análisis estático sin incidencias y APK normal de depuración compilado.

```powershell
.\flutterw.ps1 test
.\flutterw.ps1 analyze
.\flutterw.ps1 drive --keep-app-running --driver=test_driver/ui_driver.dart --target=integration_test/forms_experience_test.dart -d emulator-5554 --dart-define-from-file=config/local-emulator.json
```

La prueba `profile_local_backend_test.dart` recibe `UI_LOCAL_EMAIL` y `UI_LOCAL_PASSWORD` mediante un archivo ignorado. Las capturas revisadas se guardan en `.tools/ui-review/ui-form-*.png`. El recorrido con datos controlados usa preferencias en memoria y restaura la referencia a las preferencias nativas al finalizar. El APK entregado utiliza `lib/main.dart` y únicamente `config/local-emulator.json`, sin las credenciales del harness.
