// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'es';

  static String m0(count) =>
      "${Intl.plural(count, one: '1 producto', other: '${count} productos')}";

  static String m1(number) => "Mínimo de caracteres ${number}";

  static String m2(email) => "El correo ${email} ya está registrado";

  static String m3(minPurchaseAmountCard, coin) =>
      "El importe mínimo de compra con tarjeta de crédito es de ${minPurchaseAmountCard} ${coin}. Por favor, añada más productos a la cesta. O pague en efectivo";

  static String m4(name) => "El nombre ${name} ya está registrado";

  static String m5(phone) => "El celular ${phone} ya está registrado";

  static String m6(email) =>
      "El correo ${email} no figura en nuestros registros";

  static String m7(phone) => "Tu celular es: ${phone}";

  static String m8(minutes) => "Preparación estimada: ${minutes} min";

  static String m9(labelCancelButton) =>
      "Si está seguro de querer cancelar el pedido, toque el botón (${labelCancelButton})";

  static String m10(company) =>
      "La empresa ${company}, no envía unidades a su ubicación. Por favor seleccione otra dirección en la pantalla principal y seleccione otra empresa";

  static String m11(distance) =>
      "La distancia mínima del recorrido no puede ser inferior a ${distance} metros";

  static String m12(amount, coin, phone) =>
      "La recarga de\n\n${amount} ${coin} al número\n\n${phone}\n\nse ha completado con éxito";

  static String m13(email) =>
      "Contraseña enviada a ${email}, si no vez el correo revisa en tu bandeja de SPAM";

  static String m14(amount) => "Más de ${amount}";

  static String m15(count) => "${count} opciones";

  static String m16(amount) => "Hasta ${amount}";

  static String m17(id) => "Pedido #${id}";

  static String m18(minutes) => "${minutes} min";

  static String m19(alias) => "Cerca de ${alias}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "acceptOrder": MessageLookupByLibrary.simpleMessage("Aceptar y preparar"),
    "account": MessageLookupByLibrary.simpleMessage("Cuenta"),
    "accountBusiness": MessageLookupByLibrary.simpleMessage("Tu negocio"),
    "accountGuestMessage": MessageLookupByLibrary.simpleMessage(
      "Inicia sesión para guardar direcciones y seguir tus pedidos.",
    ),
    "accountGuestTitle": MessageLookupByLibrary.simpleMessage(
      "Todo listo para tu próximo pedido",
    ),
    "accountPreferences": MessageLookupByLibrary.simpleMessage(
      "Tus preferencias",
    ),
    "addToCart": MessageLookupByLibrary.simpleMessage("Agregar al carrito"),
    "allCategories": MessageLookupByLibrary.simpleMessage("Todo"),
    "authCreateMessage": MessageLookupByLibrary.simpleMessage(
      "Crea tu cuenta y descubre los sabores de tu ciudad.",
    ),
    "authCreateTitle": MessageLookupByLibrary.simpleMessage(
      "Un buen pedido\nempieza aquí.",
    ),
    "authWelcome": MessageLookupByLibrary.simpleMessage(
      "Tu comida favorita,\nmás cerca.",
    ),
    "authWelcomeMessage": MessageLookupByLibrary.simpleMessage(
      "Inicia sesión y encuentra algo rico para hoy.",
    ),
    "bAccept": MessageLookupByLibrary.simpleMessage("Aceptar"),
    "bCancel": MessageLookupByLibrary.simpleMessage("Cancelar"),
    "bChangePassword": MessageLookupByLibrary.simpleMessage(
      "Cambiar contraseña",
    ),
    "bConfirm": MessageLookupByLibrary.simpleMessage("Confirmar"),
    "bContinue": MessageLookupByLibrary.simpleMessage("Continuar"),
    "bDone": MessageLookupByLibrary.simpleMessage("Hecho"),
    "bEstablishLocation": MessageLookupByLibrary.simpleMessage(
      "Establecer ubicación",
    ),
    "bFinish": MessageLookupByLibrary.simpleMessage("Finalizar"),
    "bLogin": MessageLookupByLibrary.simpleMessage("Ingresar"),
    "bNewAddress": MessageLookupByLibrary.simpleMessage(
      "Añadir una nueva dirección",
    ),
    "bNewProduct": MessageLookupByLibrary.simpleMessage("Nuevo producto"),
    "bOffline": MessageLookupByLibrary.simpleMessage("Fuera de línea"),
    "bOnline": MessageLookupByLibrary.simpleMessage("En línea"),
    "bPay": MessageLookupByLibrary.simpleMessage("Pagar"),
    "bQualify": MessageLookupByLibrary.simpleMessage("Calificar"),
    "bRecoverAccount": MessageLookupByLibrary.simpleMessage("Recuperar cuenta"),
    "bRequestCabt": MessageLookupByLibrary.simpleMessage("Solicitar taxi"),
    "bReturn": MessageLookupByLibrary.simpleMessage("Regresar"),
    "bRouteClient": MessageLookupByLibrary.simpleMessage("Ruta al cliente"),
    "bRouteStore": MessageLookupByLibrary.simpleMessage("Ruta a la tienda"),
    "bSaveChanges": MessageLookupByLibrary.simpleMessage("Guardar"),
    "bSelectAddress": MessageLookupByLibrary.simpleMessage(
      "Seleccione una dirección",
    ),
    "bSelectPhoto": MessageLookupByLibrary.simpleMessage("Seleccione una foto"),
    "bSetDestinationPoint": MessageLookupByLibrary.simpleMessage(
      "Fijar punto de destino",
    ),
    "bSetPickUpPoint": MessageLookupByLibrary.simpleMessage(
      "Fijar punto de recogida",
    ),
    "bSignin": MessageLookupByLibrary.simpleMessage("Acceder"),
    "bSignup": MessageLookupByLibrary.simpleMessage("Registrarse"),
    "bUpload": MessageLookupByLibrary.simpleMessage("Subir"),
    "businessDetails": MessageLookupByLibrary.simpleMessage("Datos del local"),
    "cartEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Explora los locales y agrega tus productos favoritos.",
    ),
    "cartEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Tu carrito está esperando",
    ),
    "cartItemCount": m0,
    "cartTitle": MessageLookupByLibrary.simpleMessage("Tu carrito"),
    "catalogErrorMessage": MessageLookupByLibrary.simpleMessage(
      "Revisa tu conexión y vuelve a intentarlo.",
    ),
    "catalogErrorTitle": MessageLookupByLibrary.simpleMessage(
      "No pudimos cargar los locales",
    ),
    "catalogSearchHint": MessageLookupByLibrary.simpleMessage(
      "Busca un plato o restaurante",
    ),
    "chooseAddressMessage": MessageLookupByLibrary.simpleMessage(
      "Selecciona una dirección para ver los locales disponibles.",
    ),
    "chooseAddressTitle": MessageLookupByLibrary.simpleMessage(
      "¿Dónde te lo llevamos?",
    ),
    "chooseStore": MessageLookupByLibrary.simpleMessage("Selecciona tu local"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Limpiar búsqueda"),
    "courierAccept": MessageLookupByLibrary.simpleMessage("Aceptar entrega"),
    "courierAccount": MessageLookupByLibrary.simpleMessage("Cuenta"),
    "courierActive": MessageLookupByLibrary.simpleMessage("En curso"),
    "courierApprox": MessageLookupByLibrary.simpleMessage(
      "Distancias aproximadas en línea recta. Abre el mapa para ver la ruta.",
    ),
    "courierBack": MessageLookupByLibrary.simpleMessage("Volver"),
    "courierBalanceError": MessageLookupByLibrary.simpleMessage(
      "Tu saldo operativo no alcanza para aceptar esta entrega.",
    ),
    "courierCall": MessageLookupByLibrary.simpleMessage("Llamar"),
    "courierCancel": MessageLookupByLibrary.simpleMessage("Cancelar pedido"),
    "courierCancelMessage": MessageLookupByLibrary.simpleMessage(
      "Esto cancela el pedido del cliente y revierte los saldos correspondientes. No es una reasignación de motorizado.",
    ),
    "courierCancelled": MessageLookupByLibrary.simpleMessage(
      "Pedido cancelado",
    ),
    "courierCash": MessageLookupByLibrary.simpleMessage("Efectivo"),
    "courierChangedError": MessageLookupByLibrary.simpleMessage(
      "El pedido cambió o ya no está disponible. Actualiza para ver su estado.",
    ),
    "courierChat": MessageLookupByLibrary.simpleMessage("Chat"),
    "courierCollect": MessageLookupByLibrary.simpleMessage("Confirmar retiro"),
    "courierCompleted": MessageLookupByLibrary.simpleMessage(
      "Entregas completadas",
    ),
    "courierConfirmCash": MessageLookupByLibrary.simpleMessage(
      "Confirma que entregaste el pedido y recibiste el importe total del cliente.",
    ),
    "courierConfirmPaid": MessageLookupByLibrary.simpleMessage(
      "Confirma que entregaste el pedido al cliente. El pedido ya está pagado.",
    ),
    "courierConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "¿Completaste la entrega?",
    ),
    "courierCredit": MessageLookupByLibrary.simpleMessage(
      "Saldo para aceptar pedidos",
    ),
    "courierCreditHint": MessageLookupByLibrary.simpleMessage(
      "Cubre la comisión de los pedidos en efectivo.",
    ),
    "courierDayGain": MessageLookupByLibrary.simpleMessage("Ganancia del día"),
    "courierDeliver": MessageLookupByLibrary.simpleMessage("Confirmar entrega"),
    "courierDeliveries": MessageLookupByLibrary.simpleMessage("Entregas"),
    "courierDone": MessageLookupByLibrary.simpleMessage("Entrega completada"),
    "courierDropoff": MessageLookupByLibrary.simpleMessage("Entrega"),
    "courierEarnings": MessageLookupByLibrary.simpleMessage("Ingresos"),
    "courierEmpty": MessageLookupByLibrary.simpleMessage("Todo al día"),
    "courierEmptyHint": MessageLookupByLibrary.simpleMessage(
      "Las nuevas entregas aparecerán aquí. Puedes actualizar la lista.",
    ),
    "courierGain": MessageLookupByLibrary.simpleMessage("Tu ganancia"),
    "courierGpsError": MessageLookupByLibrary.simpleMessage(
      "Activa la ubicación y concede el permiso para recibir entregas.",
    ),
    "courierHeading": MessageLookupByLibrary.simpleMessage("Ve al restaurante"),
    "courierHistory": MessageLookupByLibrary.simpleMessage(
      "Ver historial de pedidos",
    ),
    "courierIncomeEmpty": MessageLookupByLibrary.simpleMessage(
      "Sin entregas completadas este día.",
    ),
    "courierIncomeHint": MessageLookupByLibrary.simpleMessage(
      "Día de entrega según la hora de Ecuador. Los pedidos antiguos sin fecha de entrega se consultan en el historial.",
    ),
    "courierLabel": MessageLookupByLibrary.simpleMessage("Motorizado"),
    "courierNetworkError": MessageLookupByLibrary.simpleMessage(
      "No se pudo confirmar la operación. Revisa tu conexión e inténtalo otra vez.",
    ),
    "courierOffers": MessageLookupByLibrary.simpleMessage("Disponibles"),
    "courierOffline": MessageLookupByLibrary.simpleMessage("No disponible"),
    "courierOfflineActive": MessageLookupByLibrary.simpleMessage(
      "No recibirás nuevas ofertas. Continúa tus entregas en curso.",
    ),
    "courierOfflineHint": MessageLookupByLibrary.simpleMessage(
      "Activa tu disponibilidad para ver nuevas ofertas.",
    ),
    "courierOnWay": MessageLookupByLibrary.simpleMessage(
      "En camino al cliente",
    ),
    "courierOnline": MessageLookupByLibrary.simpleMessage("Disponible"),
    "courierOnlineHint": MessageLookupByLibrary.simpleMessage(
      "Recibirás nuevas ofertas de entrega.",
    ),
    "courierPaid": MessageLookupByLibrary.simpleMessage("Pagado en la app"),
    "courierPickup": MessageLookupByLibrary.simpleMessage("Retiro"),
    "courierPreparing": MessageLookupByLibrary.simpleMessage(
      "El restaurante está preparando el pedido.",
    ),
    "courierProducts": MessageLookupByLibrary.simpleMessage("Pedido"),
    "courierReady": MessageLookupByLibrary.simpleMessage("Listo para retirar"),
    "courierRefresh": MessageLookupByLibrary.simpleMessage("Actualizar"),
    "courierRoute": MessageLookupByLibrary.simpleMessage("Abrir ruta"),
    "courierSessionError": MessageLookupByLibrary.simpleMessage(
      "Tu sesión no está disponible. Vuelve a iniciar sesión.",
    ),
    "courierSettlement": MessageLookupByLibrary.simpleMessage(
      "Liquidación registrada",
    ),
    "courierSettlementHint": MessageLookupByLibrary.simpleMessage(
      "Importe registrado por el sistema; no representa una transferencia bancaria.",
    ),
    "courierToday": MessageLookupByLibrary.simpleMessage("Hoy"),
    "courierTotal": MessageLookupByLibrary.simpleMessage("Total del pedido"),
    "courierUnknown": MessageLookupByLibrary.simpleMessage("No disponible"),
    "courierUnpriced": MessageLookupByLibrary.simpleMessage(
      "Algunas entregas no tienen ganancia registrada y no se incluyen en el importe.",
    ),
    "customerNotes": MessageLookupByLibrary.simpleMessage(
      "Indicaciones del cliente",
    ),
    "decreaseQuantity": MessageLookupByLibrary.simpleMessage(
      "Reducir cantidad",
    ),
    "deliverTo": MessageLookupByLibrary.simpleMessage("Entregar en"),
    "dishDetails": MessageLookupByLibrary.simpleMessage("Detalle del plato"),
    "dispatchedOrders": MessageLookupByLibrary.simpleMessage("En reparto"),
    "eValidatoAmount": MessageLookupByLibrary.simpleMessage("Monto Incorrecto"),
    "eValidatoCharacters": m1,
    "eValidatoEmail": MessageLookupByLibrary.simpleMessage(
      "El formato del correo es incorrecto",
    ),
    "eValidatoPhone": MessageLookupByLibrary.simpleMessage(
      "El formato del celular es incorrecto",
    ),
    "editClosing": MessageLookupByLibrary.simpleMessage(
      "Cambiar hora de cierre",
    ),
    "editImage": MessageLookupByLibrary.simpleMessage("Editar imagen"),
    "editOpening": MessageLookupByLibrary.simpleMessage(
      "Cambiar hora de apertura",
    ),
    "editProduct": MessageLookupByLibrary.simpleMessage("Editar producto"),
    "editProfile": MessageLookupByLibrary.simpleMessage("Editar perfil"),
    "emptyTab2": MessageLookupByLibrary.simpleMessage(
      " No tienes pedidos pendientes",
    ),
    "errDeleteAllAddress": MessageLookupByLibrary.simpleMessage(
      "No puedes eliminar todas las direcciones. Debes tener al menos una",
    ),
    "errDeliverymanNotFound": MessageLookupByLibrary.simpleMessage(
      "El número que proporciono no pertenece a ningún repartidor registrado",
    ),
    "errEmailUnique": m2,
    "errManagerCannotBeDeliveryman": MessageLookupByLibrary.simpleMessage(
      "El número de teléfono que proporciono está asignado a una tienda (rol manager) por lo que no puede ser repartidor (rol deliveryman)",
    ),
    "errMinPurchaseAmountCard": m3,
    "errNameUnique": m4,
    "errPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Por favor agrega un número de teléfono",
    ),
    "errPhoneNumberAgain": MessageLookupByLibrary.simpleMessage(
      "Por favor agrega de nuevo el número de teléfono",
    ),
    "errPhoneUnique": m5,
    "errPleaseUploadImage": MessageLookupByLibrary.simpleMessage(
      "Por favor, sube una imagen",
    ),
    "errRecoverAccount": m6,
    "errUnknown": MessageLookupByLibrary.simpleMessage(
      "Oops, algo parece haber ido mal, por favor, inténtelo de nuevo más tarde",
    ),
    "errdeliverymanCannotBeManager": MessageLookupByLibrary.simpleMessage(
      "El número de teléfono que proporciono está asignado a un repartidor (rol deliveryman) por lo que no puede ser tienda (rol manager)",
    ),
    "explore": MessageLookupByLibrary.simpleMessage("Explorar"),
    "featuredProducts": MessageLookupByLibrary.simpleMessage("Para descubrir"),
    "fullMenu": MessageLookupByLibrary.simpleMessage("Todo el menú"),
    "hAddress": MessageLookupByLibrary.simpleMessage("Dirección"),
    "hAlias": MessageLookupByLibrary.simpleMessage("Alias"),
    "hChat": MessageLookupByLibrary.simpleMessage("Escribe tu mensaje"),
    "hEmail": MessageLookupByLibrary.simpleMessage("Correo"),
    "hFilter": MessageLookupByLibrary.simpleMessage("Hoy, que se te antoja?"),
    "hFullName": MessageLookupByLibrary.simpleMessage("Nombre completo"),
    "hNoteProdcut": MessageLookupByLibrary.simpleMessage(
      "Indicaciones para este producto (opcional)",
    ),
    "hPassword": MessageLookupByLibrary.simpleMessage("Contraseña"),
    "hPhone": MessageLookupByLibrary.simpleMessage("Celular"),
    "hProductDescription": MessageLookupByLibrary.simpleMessage(
      "Descripción del producto",
    ),
    "hProductName": MessageLookupByLibrary.simpleMessage("Nombre del producto"),
    "hYourPhoneNumber": m7,
    "hidePassword": MessageLookupByLibrary.simpleMessage("Ocultar contraseña"),
    "homeGreeting": MessageLookupByLibrary.simpleMessage(
      "¿Qué te provoca hoy?",
    ),
    "homeSubtitle": MessageLookupByLibrary.simpleMessage(
      "Encuentra algo rico cerca de ti.",
    ),
    "hoursEmpty": MessageLookupByLibrary.simpleMessage(
      "Este local todavía no tiene horarios registrados.",
    ),
    "increaseQuantity": MessageLookupByLibrary.simpleMessage(
      "Aumentar cantidad",
    ),
    "kitchenActionError": MessageLookupByLibrary.simpleMessage(
      "No pudimos guardar el cambio. Vuelve a intentarlo.",
    ),
    "kitchenConflict": MessageLookupByLibrary.simpleMessage(
      "El pedido cambió. Revisa su estado actualizado.",
    ),
    "kitchenEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Los pedidos de esta etapa aparecerán aquí.",
    ),
    "kitchenEmptyTitle": MessageLookupByLibrary.simpleMessage("Todo al día"),
    "kitchenErrorTitle": MessageLookupByLibrary.simpleMessage(
      "No pudimos cargar los pedidos",
    ),
    "kitchenPendingClient": MessageLookupByLibrary.simpleMessage(
      "El restaurante está por aceptar tu pedido.",
    ),
    "kitchenPrepEstimate": m8,
    "kitchenPreparingClient": MessageLookupByLibrary.simpleMessage(
      "El restaurante está preparando tu pedido.",
    ),
    "kitchenReadyClient": MessageLookupByLibrary.simpleMessage(
      "Tu pedido está listo para retiro.",
    ),
    "kitchenSubtitle": MessageLookupByLibrary.simpleMessage(
      "Cada pedido, en su momento.",
    ),
    "kitchenTitle": MessageLookupByLibrary.simpleMessage("Tu cocina"),
    "lAddedCart": MessageLookupByLibrary.simpleMessage("Agregado al carrito"),
    "lAmount": MessageLookupByLibrary.simpleMessage("Monto"),
    "lClient": MessageLookupByLibrary.simpleMessage("Cliente"),
    "lClosed": MessageLookupByLibrary.simpleMessage("Cerrado"),
    "lDeliveryAddress": MessageLookupByLibrary.simpleMessage(
      "Dirección de entrega",
    ),
    "lDeliveryFee": MessageLookupByLibrary.simpleMessage("Envío"),
    "lDeliveryman": MessageLookupByLibrary.simpleMessage("Repartidor"),
    "lFriday": MessageLookupByLibrary.simpleMessage("Viernes"),
    "lHAmounValid": MessageLookupByLibrary.simpleMessage(
      "Importe a reembolsar por tarjeta de crédito",
    ),
    "lHBalanceValid": MessageLookupByLibrary.simpleMessage(
      "Balance para poder tomar pedidos",
    ),
    "lHMoneyValid": MessageLookupByLibrary.simpleMessage(
      "Este importe reduce automáticamente el pago",
    ),
    "lMonday": MessageLookupByLibrary.simpleMessage("Lunes"),
    "lNewAddress": MessageLookupByLibrary.simpleMessage("Nueva dirección"),
    "lNumber": MessageLookupByLibrary.simpleMessage("Cantidad"),
    "lOrderBy": MessageLookupByLibrary.simpleMessage("Orden a cargo de"),
    "lPayCash": MessageLookupByLibrary.simpleMessage("Pagar en efectivo"),
    "lPayMoney": MessageLookupByLibrary.simpleMessage("Pagar con tarjeta"),
    "lPaymentMethods": MessageLookupByLibrary.simpleMessage("Métodos de pago"),
    "lPrice": MessageLookupByLibrary.simpleMessage("Precio"),
    "lProduct": MessageLookupByLibrary.simpleMessage("Producto"),
    "lSaturday": MessageLookupByLibrary.simpleMessage("Sábado"),
    "lSearch": MessageLookupByLibrary.simpleMessage("Buscar"),
    "lSelect": MessageLookupByLibrary.simpleMessage("Seleccionar"),
    "lStatusOrderAssigned": MessageLookupByLibrary.simpleMessage(
      "🛵 El repartidor se dirige a recoger tu pedido",
    ),
    "lStatusOrderCancelled": MessageLookupByLibrary.simpleMessage(
      "🥺 Oops. Lo sentimos, pero el pedido ha sido cancelado. Por favor, califiqua tu experiencia",
    ),
    "lStatusOrderDelivered": MessageLookupByLibrary.simpleMessage(
      "🥳 Gracias por preferirnos. Por favor, califiqua tu experiencia",
    ),
    "lStatusOrderQualified": MessageLookupByLibrary.simpleMessage(
      "Gracias por preferirnos",
    ),
    "lStatusOrderStarted": MessageLookupByLibrary.simpleMessage(
      "👨🏼‍🍳 El restaurante esta preparando tu pedido",
    ),
    "lStatusOrderTaken": MessageLookupByLibrary.simpleMessage(
      "💚 El repartidor ya tiene tu pedido",
    ),
    "lStatusTaxiAssigned": MessageLookupByLibrary.simpleMessage(
      "🚖 Se le ha asignado un taxi. 🚕 El taxi se dirige a su ubicación",
    ),
    "lStatusTaxiCancelled": MessageLookupByLibrary.simpleMessage(
      "🥺 Oops. Lo sentimos, pero el pedido ha sido cancelado. Por favor, califiqua tu experiencia",
    ),
    "lStatusTaxiDelivered": MessageLookupByLibrary.simpleMessage(
      "🥳 Gracias por preferirnos. Por favor, califiqua tu experiencia",
    ),
    "lStatusTaxiQualified": MessageLookupByLibrary.simpleMessage(
      "Gracias por preferirnos",
    ),
    "lStatusTaxiStarted": MessageLookupByLibrary.simpleMessage(
      "🔎 Estamos buscando una unidad cercana",
    ),
    "lStatusTaxiTaken": MessageLookupByLibrary.simpleMessage(
      "💚 El conductor ha informado de que ha subido al vehículo",
    ),
    "lSunday": MessageLookupByLibrary.simpleMessage("Domingo"),
    "lTMoneyValid": MessageLookupByLibrary.simpleMessage(
      "Money. Válido sólo con tarjeta de crédito",
    ),
    "lThursday": MessageLookupByLibrary.simpleMessage("Jueves"),
    "lTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "lTuesday": MessageLookupByLibrary.simpleMessage("Martes"),
    "lWednesday": MessageLookupByLibrary.simpleMessage("Miércoles"),
    "legacyKitchen": MessageLookupByLibrary.simpleMessage(
      "Sin estado de cocina registrado",
    ),
    "lselectCategory": MessageLookupByLibrary.simpleMessage(
      "Selecciona una categoría",
    ),
    "lselectGroup": MessageLookupByLibrary.simpleMessage("Selecciona un grupo"),
    "lselectPayment": MessageLookupByLibrary.simpleMessage(
      "Selecciona un método de pago",
    ),
    "mDCancelOrder": m9,
    "mDConfirmOrder": MessageLookupByLibrary.simpleMessage(
      "Confirma que has recogido el pedido",
    ),
    "mDFinish": MessageLookupByLibrary.simpleMessage(
      "Por favor califica al cliente",
    ),
    "mDLogoutSession": MessageLookupByLibrary.simpleMessage(
      "Seguro que quieres cerrar la sesión?",
    ),
    "mDStoreClosed": MessageLookupByLibrary.simpleMessage(
      "Esta tienda está cerrada, puedes ver sus productos pero no podrás hacer una compra hasta que la tienda esté abierta",
    ),
    "mEither": MessageLookupByLibrary.simpleMessage("o bien"),
    "mIncorrectLogin": MessageLookupByLibrary.simpleMessage(
      "Usuario o contraseña incorrectos",
    ),
    "mMaximumDistanceStoreStartingPoint": m10,
    "mMinimumTravelDistance": m11,
    "mRAddressRemoved": MessageLookupByLibrary.simpleMessage(
      "Dirección eliminada",
    ),
    "mRChangesMadeCorrectly": MessageLookupByLibrary.simpleMessage(
      "Cambios realizados correctamente",
    ),
    "mRConfirmOrde": MessageLookupByLibrary.simpleMessage(
      "En hora buena. Notificamos que has recogido el pedido",
    ),
    "mRStoreCongratulations": MessageLookupByLibrary.simpleMessage(
      "Felicitaciones, has registrado correctamente tu tienda. Ahora crea tus productos y empieza a vender",
    ),
    "mRTopUpBalance": m12,
    "mRecoverAccount": m13,
    "mRinsufficientBalance": MessageLookupByLibrary.simpleMessage(
      "Fondos insuficientes. Por favor, recarga tu saldo",
    ),
    "mRorderFulfilled": MessageLookupByLibrary.simpleMessage(
      "Oops, la solicitud ya se ha atendido",
    ),
    "manageHours": MessageLookupByLibrary.simpleMessage("Horarios de atención"),
    "managerStoresEmpty": MessageLookupByLibrary.simpleMessage(
      "Aún no tienes locales asignados",
    ),
    "managerStoresEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Los locales vinculados a tu cuenta aparecerán aquí.",
    ),
    "markReady": MessageLookupByLibrary.simpleMessage(
      "Marcar listo para retiro",
    ),
    "matchingDishes": MessageLookupByLibrary.simpleMessage(
      "Platos que coinciden",
    ),
    "matchingRestaurants": MessageLookupByLibrary.simpleMessage(
      "Restaurantes relacionados",
    ),
    "menuAbove": m14,
    "menuDescription": MessageLookupByLibrary.simpleMessage(
      "Administra los productos de tu negocio.",
    ),
    "menuEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Agrega tu primer producto con su nombre, descripción y precio.",
    ),
    "menuEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Tu menú empieza aquí",
    ),
    "menuItems": m15,
    "menuSingleItem": MessageLookupByLibrary.simpleMessage("1 opción"),
    "menuUpTo": m16,
    "nearbyStores": MessageLookupByLibrary.simpleMessage("Cerca de ti"),
    "newOrders": MessageLookupByLibrary.simpleMessage("Nuevos"),
    "noNotifications": MessageLookupByLibrary.simpleMessage(
      "No tienes notificaciones por ahora.",
    ),
    "noResultsMessage": MessageLookupByLibrary.simpleMessage(
      "Prueba otra búsqueda o cambia de categoría.",
    ),
    "noResultsTitle": MessageLookupByLibrary.simpleMessage(
      "No encontramos coincidencias",
    ),
    "noStoresMessage": MessageLookupByLibrary.simpleMessage(
      "Prueba con otra dirección de entrega o vuelve más tarde.",
    ),
    "noStoresTitle": MessageLookupByLibrary.simpleMessage(
      "Aún no hay locales por aquí",
    ),
    "openHistory": MessageLookupByLibrary.simpleMessage("Historial de pedidos"),
    "openStore": MessageLookupByLibrary.simpleMessage("Abierto"),
    "orderAccepted": MessageLookupByLibrary.simpleMessage(
      "Pedido aceptado. Ya puedes prepararlo.",
    ),
    "orderAssigned": MessageLookupByLibrary.simpleMessage(
      "Motorizado asignado",
    ),
    "orderCompleted": MessageLookupByLibrary.simpleMessage("Entregado"),
    "orderDetails": MessageLookupByLibrary.simpleMessage("Ver detalle"),
    "orderNumber": m17,
    "orderOnTheWay": MessageLookupByLibrary.simpleMessage("En camino"),
    "orderProgress": MessageLookupByLibrary.simpleMessage("Estado del pedido"),
    "orderReady": MessageLookupByLibrary.simpleMessage(
      "Pedido listo para que lo recoja el motorizado.",
    ),
    "orderReceived": MessageLookupByLibrary.simpleMessage("Pedido recibido"),
    "ordersEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Cuando hagas un pedido, podrás seguirlo desde aquí.",
    ),
    "ordersEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Aquí verás tus pedidos",
    ),
    "ordersErrorMessage": MessageLookupByLibrary.simpleMessage(
      "Revisa tu conexión y vuelve a intentarlo.",
    ),
    "ordersErrorTitle": MessageLookupByLibrary.simpleMessage(
      "No pudimos cargar tus pedidos",
    ),
    "ordersGuestMessage": MessageLookupByLibrary.simpleMessage(
      "Inicia sesión para consultar y seguir tus pedidos.",
    ),
    "paymentBackToCart": MessageLookupByLibrary.simpleMessage(
      "Volver al carrito",
    ),
    "paymentBrowserError": MessageLookupByLibrary.simpleMessage(
      "No pudimos abrir el pago. Vuelve al carrito para reintentarlo.",
    ),
    "paymentCheckStatus": MessageLookupByLibrary.simpleMessage(
      "Ya pagué, verificar",
    ),
    "paymentCheckoutHelp": MessageLookupByLibrary.simpleMessage(
      "Paga con tu tarjeta o con PayPhone en el navegador. Al terminar, vuelve aquí para continuar con tu pedido.",
    ),
    "paymentCheckoutTitle": MessageLookupByLibrary.simpleMessage(
      "Completa tu pago",
    ),
    "paymentConnectionError": MessageLookupByLibrary.simpleMessage(
      "No pudimos consultar el pago. Revisa tu conexión y vuelve a verificar.",
    ),
    "paymentDeclined": MessageLookupByLibrary.simpleMessage(
      "PayPhone no aprobó este pago. No se acreditó saldo. Puedes volver al carrito e intentarlo otra vez.",
    ),
    "paymentOpenBrowser": MessageLookupByLibrary.simpleMessage(
      "Abrir PayPhone",
    ),
    "paymentPayphone": MessageLookupByLibrary.simpleMessage(
      "Tarjeta o PayPhone / saldo",
    ),
    "paymentPending": MessageLookupByLibrary.simpleMessage(
      "Esperando la confirmación de PayPhone.",
    ),
    "paymentResumeHelp": MessageLookupByLibrary.simpleMessage(
      "Si ya pagaste, verificaremos tu saldo antes de continuar. Puedes retomar el pago desde el carrito.",
    ),
    "paymentUnavailable": MessageLookupByLibrary.simpleMessage(
      "El pago electrónico no está disponible ahora. Puedes elegir efectivo o usar tu saldo disponible.",
    ),
    "paymentWallet": MessageLookupByLibrary.simpleMessage("Saldo disponible"),
    "photoOptional": MessageLookupByLibrary.simpleMessage("Foto opcional"),
    "preparationMinutesLabel": m18,
    "preparationTime": MessageLookupByLibrary.simpleMessage(
      "Tiempo de preparación",
    ),
    "preparingOrders": MessageLookupByLibrary.simpleMessage("En preparación"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacidad"),
    "productDescriptionError": MessageLookupByLibrary.simpleMessage(
      "Describe el producto con al menos 10 caracteres.",
    ),
    "productDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Descripción",
    ),
    "productNameError": MessageLookupByLibrary.simpleMessage(
      "Escribe un nombre de al menos 4 caracteres.",
    ),
    "productNameLabel": MessageLookupByLibrary.simpleMessage(
      "Nombre del producto",
    ),
    "productPriceError": MessageLookupByLibrary.simpleMessage(
      "Ingresa un precio mayor que cero.",
    ),
    "productPriceLabel": MessageLookupByLibrary.simpleMessage("Precio (USD)"),
    "quantity": MessageLookupByLibrary.simpleMessage("Cantidad"),
    "readyOrders": MessageLookupByLibrary.simpleMessage("Listos"),
    "removeFromCart": MessageLookupByLibrary.simpleMessage(
      "Quitar del carrito",
    ),
    "removeProduct": MessageLookupByLibrary.simpleMessage("Eliminar producto"),
    "restaurantBusiness": MessageLookupByLibrary.simpleMessage("Negocio"),
    "restaurantInformation": MessageLookupByLibrary.simpleMessage(
      "Información del restaurante",
    ),
    "restaurantMenu": MessageLookupByLibrary.simpleMessage("Menú"),
    "retry": MessageLookupByLibrary.simpleMessage("Reintentar"),
    "reviewOrder": MessageLookupByLibrary.simpleMessage("Revisar pedido"),
    "sFeatured": MessageLookupByLibrary.simpleMessage("Las personas los aman"),
    "sSlideApply": MessageLookupByLibrary.simpleMessage("Desliza para aplicar"),
    "sTCategory": MessageLookupByLibrary.simpleMessage("Filtrar por categoría"),
    "sTCompanyPopular": MessageLookupByLibrary.simpleMessage(
      "No te los puedes perder",
    ),
    "sTCompanyTop": MessageLookupByLibrary.simpleMessage(
      "Tienes que probarlos",
    ),
    "sTOrders": MessageLookupByLibrary.simpleMessage(
      "Consulta el estado de tus entregas",
    ),
    "saveProduct": MessageLookupByLibrary.simpleMessage("Guardar producto"),
    "scheduleUpdated": MessageLookupByLibrary.simpleMessage(
      "Horario actualizado.",
    ),
    "searchMenu": MessageLookupByLibrary.simpleMessage("Buscar en el menú"),
    "selectOption": MessageLookupByLibrary.simpleMessage(
      "Selecciona una opción",
    ),
    "shippingAtCheckout": MessageLookupByLibrary.simpleMessage(
      "El envío se calcula al revisar tu pedido.",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Mostrar contraseña"),
    "signOut": MessageLookupByLibrary.simpleMessage("Cerrar sesión"),
    "softwareLicenses": MessageLookupByLibrary.simpleMessage(
      "Licencias de software",
    ),
    "storeEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Este local aún no tiene productos disponibles.",
    ),
    "storeEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "El menú se está preparando",
    ),
    "subtotal": MessageLookupByLibrary.simpleMessage("Subtotal"),
    "tAbout": MessageLookupByLibrary.simpleMessage("Acerca de"),
    "tAddress": MessageLookupByLibrary.simpleMessage("Direccion"),
    "tAddresses": MessageLookupByLibrary.simpleMessage("Direcciones"),
    "tAppBarOrders": MessageLookupByLibrary.simpleMessage("Pedidos"),
    "tCartSummary": MessageLookupByLibrary.simpleMessage(
      "Resumen y dirección de entrega",
    ),
    "tCategories": MessageLookupByLibrary.simpleMessage("Categorías"),
    "tCloseTo": m19,
    "tClosingTime": MessageLookupByLibrary.simpleMessage("HORA DE CIERRE"),
    "tCompanyPopular": MessageLookupByLibrary.simpleMessage("Lo más comprado"),
    "tCompanyTop": MessageLookupByLibrary.simpleMessage("Los mejor valorados"),
    "tDestination": MessageLookupByLibrary.simpleMessage("Destino"),
    "tFeatured": MessageLookupByLibrary.simpleMessage("Destacados"),
    "tMyOrder": MessageLookupByLibrary.simpleMessage("Mi pedido"),
    "tNotifications": MessageLookupByLibrary.simpleMessage("Notificaciones"),
    "tOpeningTime": MessageLookupByLibrary.simpleMessage("HORA DE APERTURA"),
    "tOrders": MessageLookupByLibrary.simpleMessage("Tus pedidos"),
    "tPetitions": MessageLookupByLibrary.simpleMessage("Pedidos"),
    "tPetitionsHistory": MessageLookupByLibrary.simpleMessage("Historial"),
    "tPickupLocation": MessageLookupByLibrary.simpleMessage(
      "Lugar de recogida",
    ),
    "tRegisterStore": MessageLookupByLibrary.simpleMessage(
      "Registra tu tienda",
    ),
    "tRequestCab": MessageLookupByLibrary.simpleMessage("Solicitar taxi"),
    "tRequests": MessageLookupByLibrary.simpleMessage("Pedidos"),
    "tRequestsHistory": MessageLookupByLibrary.simpleMessage("Historial"),
    "tStore": MessageLookupByLibrary.simpleMessage("Productos"),
    "tStores": MessageLookupByLibrary.simpleMessage("Mis tiendas"),
    "tTStore": MessageLookupByLibrary.simpleMessage("Solo para ti"),
    "tTopUpBalance": MessageLookupByLibrary.simpleMessage("Recarga de saldo"),
    "tWelcome": MessageLookupByLibrary.simpleMessage(
      "Dinos de que lugar te mostramos los mejores restaurantes",
    ),
    "tab1": MessageLookupByLibrary.simpleMessage("Explorar"),
    "tab2": MessageLookupByLibrary.simpleMessage("Pedidos"),
    "termsOfService": MessageLookupByLibrary.simpleMessage("Términos de uso"),
    "trackingLocationUpdated": MessageLookupByLibrary.simpleMessage(
      "Ubicación del motorizado recibida",
    ),
    "trackingMapUnavailable": MessageLookupByLibrary.simpleMessage(
      "El mapa no está disponible por ahora. Puedes seguir el estado de tu pedido aquí.",
    ),
    "trackingWaitingLocation": MessageLookupByLibrary.simpleMessage(
      "Esperando la ubicación del motorizado",
    ),
    "viewActiveOrders": MessageLookupByLibrary.simpleMessage(
      "Volver a pedidos activos",
    ),
    "viewCart": MessageLookupByLibrary.simpleMessage("Ver carrito"),
    "viewLocation": MessageLookupByLibrary.simpleMessage("Ver ubicación"),
    "waitingForKitchen": MessageLookupByLibrary.simpleMessage(
      "Espera a que el restaurante marque el pedido como listo.",
    ),
    "walletBalance": MessageLookupByLibrary.simpleMessage(
      "Saldo de tu billetera",
    ),
    "walletBalanceHint": MessageLookupByLibrary.simpleMessage(
      "Este saldo se aplica al pagar con tu billetera.",
    ),
    "welcomeAccess": MessageLookupByLibrary.simpleMessage(
      "Entrar o crear cuenta",
    ),
    "welcomeDelivery": MessageLookupByLibrary.simpleMessage(
      "Pide a tu dirección",
    ),
    "welcomeDeliveryMessage": MessageLookupByLibrary.simpleMessage(
      "Elige tus platos y confirma tu entrega.",
    ),
    "welcomeDescription": MessageLookupByLibrary.simpleMessage(
      "Explora restaurantes y menús, pide tus platos favoritos y recíbelos en la dirección que elijas.",
    ),
    "welcomeDiscover": MessageLookupByLibrary.simpleMessage(
      "Encuentra qué comer",
    ),
    "welcomeDiscoverMessage": MessageLookupByLibrary.simpleMessage(
      "Compara opciones y descubre nuevos sabores.",
    ),
    "welcomeExplore": MessageLookupByLibrary.simpleMessage(
      "Elegir dirección y explorar",
    ),
    "welcomeTitle": MessageLookupByLibrary.simpleMessage(
      "Tus restaurantes,\na tu puerta.",
    ),
    "welcomeTracking": MessageLookupByLibrary.simpleMessage("Sigue tu pedido"),
    "welcomeTrackingMessage": MessageLookupByLibrary.simpleMessage(
      "Desde la preparación hasta que llega a ti.",
    ),
  };
}
