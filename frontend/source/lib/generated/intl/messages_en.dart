// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(count) =>
      "${Intl.plural(count, one: '1 product', other: '${count} products')}";

  static String m1(number) => "Minimum of characters ${number}";

  static String m2(email) => "The email ${email} is already registered";

  static String m3(minPurchaseAmountCard, coin) =>
      "The minimum credit card purchase amount is ${minPurchaseAmountCard} ${coin}. Please add more products to the cart. Or pay cash";

  static String m4(name) => "The name ${name} is already registered";

  static String m5(phone) => "The phone number ${phone} is already registered";

  static String m6(email) =>
      "The email address ${email} is not in our records.";

  static String m7(phone) => "Your phone number is: ${phone}";

  static String m8(minutes) => "Estimated preparation: ${minutes} min";

  static String m9(labelCancelButton) =>
      "If you are sure you want to cancel the order, touch on the (${labelCancelButton}) button";

  static String m10(company) =>
      "The company ${company}, does not ship units to your location. Please select another address on the main screen and select another company";

  static String m11(distance) =>
      "The minimum distance of the route cannot be less than ${distance} meters";

  static String m12(amount, coin, phone) =>
      "The recharge of\n\n${amount} ${coin} to the number\n\n${phone}\n\nhas been successfully completed";

  static String m13(email) =>
      "Password sent to ${email}, if you don\'t see the email check your SPAM folder";

  static String m14(amount) => "Over ${amount}";

  static String m15(count) => "${count} options";

  static String m16(amount) => "Up to ${amount}";

  static String m17(id) => "Order #${id}";

  static String m18(minutes) => "${minutes} min";

  static String m19(alias) => "Close to ${alias}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "acceptOrder": MessageLookupByLibrary.simpleMessage("Accept and prepare"),
    "account": MessageLookupByLibrary.simpleMessage("Account"),
    "accountBusiness": MessageLookupByLibrary.simpleMessage("Your business"),
    "accountGuestMessage": MessageLookupByLibrary.simpleMessage(
      "Sign in to save addresses and track orders.",
    ),
    "accountGuestTitle": MessageLookupByLibrary.simpleMessage(
      "Ready for your next order",
    ),
    "accountPreferences": MessageLookupByLibrary.simpleMessage(
      "Your preferences",
    ),
    "addToCart": MessageLookupByLibrary.simpleMessage("Add to cart"),
    "allCategories": MessageLookupByLibrary.simpleMessage("All"),
    "authCreateMessage": MessageLookupByLibrary.simpleMessage(
      "Create your account and discover the flavors of your city.",
    ),
    "authCreateTitle": MessageLookupByLibrary.simpleMessage(
      "A great order\nstarts here.",
    ),
    "authWelcome": MessageLookupByLibrary.simpleMessage(
      "Your favorite food,\ncloser to you.",
    ),
    "authWelcomeMessage": MessageLookupByLibrary.simpleMessage(
      "Sign in and find something delicious for today.",
    ),
    "bAccept": MessageLookupByLibrary.simpleMessage("Accept"),
    "bCancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "bChangePassword": MessageLookupByLibrary.simpleMessage("Change password"),
    "bConfirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "bContinue": MessageLookupByLibrary.simpleMessage("Continue"),
    "bDone": MessageLookupByLibrary.simpleMessage("Done"),
    "bEstablishLocation": MessageLookupByLibrary.simpleMessage("Set location"),
    "bFinish": MessageLookupByLibrary.simpleMessage("Finish"),
    "bLogin": MessageLookupByLibrary.simpleMessage("Login"),
    "bNewAddress": MessageLookupByLibrary.simpleMessage("Add a new address"),
    "bNewProduct": MessageLookupByLibrary.simpleMessage("New product"),
    "bOffline": MessageLookupByLibrary.simpleMessage("Offline"),
    "bOnline": MessageLookupByLibrary.simpleMessage("Online"),
    "bPay": MessageLookupByLibrary.simpleMessage("Pay"),
    "bQualify": MessageLookupByLibrary.simpleMessage("Qualify"),
    "bRecoverAccount": MessageLookupByLibrary.simpleMessage("Recover account"),
    "bRequestCabt": MessageLookupByLibrary.simpleMessage("Request cab"),
    "bReturn": MessageLookupByLibrary.simpleMessage("Return"),
    "bRouteClient": MessageLookupByLibrary.simpleMessage("Route to the client"),
    "bRouteStore": MessageLookupByLibrary.simpleMessage("Route to the store"),
    "bSaveChanges": MessageLookupByLibrary.simpleMessage("Save"),
    "bSelectAddress": MessageLookupByLibrary.simpleMessage("Select an address"),
    "bSelectPhoto": MessageLookupByLibrary.simpleMessage("Select a photo"),
    "bSetDestinationPoint": MessageLookupByLibrary.simpleMessage(
      "Set destination point",
    ),
    "bSetPickUpPoint": MessageLookupByLibrary.simpleMessage(
      "Set pick-up point",
    ),
    "bSignin": MessageLookupByLibrary.simpleMessage("Sign in"),
    "bSignup": MessageLookupByLibrary.simpleMessage("Sign up"),
    "bUpload": MessageLookupByLibrary.simpleMessage("Upload"),
    "businessDetails": MessageLookupByLibrary.simpleMessage("Store details"),
    "cartEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Explore stores and add your favorite products.",
    ),
    "cartEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Your cart is waiting",
    ),
    "cartItemCount": m0,
    "cartTitle": MessageLookupByLibrary.simpleMessage("Your cart"),
    "catalogErrorMessage": MessageLookupByLibrary.simpleMessage(
      "Check your connection and try again.",
    ),
    "catalogErrorTitle": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t load the stores",
    ),
    "catalogSearchHint": MessageLookupByLibrary.simpleMessage(
      "Search for a dish or restaurant",
    ),
    "chooseAddressMessage": MessageLookupByLibrary.simpleMessage(
      "Choose an address to see available stores.",
    ),
    "chooseAddressTitle": MessageLookupByLibrary.simpleMessage(
      "Where should we deliver?",
    ),
    "chooseStore": MessageLookupByLibrary.simpleMessage("Select your store"),
    "clearSearch": MessageLookupByLibrary.simpleMessage("Clear search"),
    "courierAccept": MessageLookupByLibrary.simpleMessage("Accept delivery"),
    "courierAccount": MessageLookupByLibrary.simpleMessage("Account"),
    "courierActive": MessageLookupByLibrary.simpleMessage("In progress"),
    "courierApprox": MessageLookupByLibrary.simpleMessage(
      "Approximate straight-line distances. Open the map for directions.",
    ),
    "courierBack": MessageLookupByLibrary.simpleMessage("Back"),
    "courierBalanceError": MessageLookupByLibrary.simpleMessage(
      "Your operating balance is insufficient for this delivery.",
    ),
    "courierCall": MessageLookupByLibrary.simpleMessage("Call"),
    "courierCancel": MessageLookupByLibrary.simpleMessage("Cancel order"),
    "courierCancelMessage": MessageLookupByLibrary.simpleMessage(
      "This cancels the customer\'s order and reverses the corresponding balances. It does not reassign the courier.",
    ),
    "courierCancelled": MessageLookupByLibrary.simpleMessage("Order cancelled"),
    "courierCash": MessageLookupByLibrary.simpleMessage("Cash"),
    "courierChangedError": MessageLookupByLibrary.simpleMessage(
      "This order changed or is no longer available. Refresh to see its status.",
    ),
    "courierChat": MessageLookupByLibrary.simpleMessage("Chat"),
    "courierCollect": MessageLookupByLibrary.simpleMessage("Confirm pickup"),
    "courierCompleted": MessageLookupByLibrary.simpleMessage(
      "Completed deliveries",
    ),
    "courierConfirmCash": MessageLookupByLibrary.simpleMessage(
      "Confirm you handed over the order and collected the full amount from the customer.",
    ),
    "courierConfirmPaid": MessageLookupByLibrary.simpleMessage(
      "Confirm you handed over the order to the customer. The order is already paid.",
    ),
    "courierConfirmTitle": MessageLookupByLibrary.simpleMessage(
      "Did you complete the delivery?",
    ),
    "courierCredit": MessageLookupByLibrary.simpleMessage(
      "Balance for accepting deliveries",
    ),
    "courierCreditHint": MessageLookupByLibrary.simpleMessage(
      "Covers the commission on cash orders.",
    ),
    "courierDayGain": MessageLookupByLibrary.simpleMessage("Daily earnings"),
    "courierDeliver": MessageLookupByLibrary.simpleMessage("Confirm delivery"),
    "courierDeliveries": MessageLookupByLibrary.simpleMessage("Deliveries"),
    "courierDone": MessageLookupByLibrary.simpleMessage("Delivery completed"),
    "courierDropoff": MessageLookupByLibrary.simpleMessage("Drop-off"),
    "courierEarnings": MessageLookupByLibrary.simpleMessage("Earnings"),
    "courierEmpty": MessageLookupByLibrary.simpleMessage("All caught up"),
    "courierEmptyHint": MessageLookupByLibrary.simpleMessage(
      "New deliveries will appear here. You can refresh the list.",
    ),
    "courierGain": MessageLookupByLibrary.simpleMessage("Your earnings"),
    "courierGpsError": MessageLookupByLibrary.simpleMessage(
      "Enable location and grant permission to receive deliveries.",
    ),
    "courierHeading": MessageLookupByLibrary.simpleMessage(
      "Go to the restaurant",
    ),
    "courierHistory": MessageLookupByLibrary.simpleMessage(
      "View order history",
    ),
    "courierIncomeEmpty": MessageLookupByLibrary.simpleMessage(
      "No completed deliveries on this day.",
    ),
    "courierIncomeHint": MessageLookupByLibrary.simpleMessage(
      "Delivery day uses Ecuador time. Older orders without a delivery timestamp are available in history.",
    ),
    "courierLabel": MessageLookupByLibrary.simpleMessage("Courier"),
    "courierNetworkError": MessageLookupByLibrary.simpleMessage(
      "The operation could not be confirmed. Check your connection and try again.",
    ),
    "courierOffers": MessageLookupByLibrary.simpleMessage(
      "Available deliveries",
    ),
    "courierOffline": MessageLookupByLibrary.simpleMessage("Unavailable"),
    "courierOfflineActive": MessageLookupByLibrary.simpleMessage(
      "No new offers. Continue your active deliveries.",
    ),
    "courierOfflineHint": MessageLookupByLibrary.simpleMessage(
      "Go available to see new offers.",
    ),
    "courierOnWay": MessageLookupByLibrary.simpleMessage(
      "On the way to the customer",
    ),
    "courierOnline": MessageLookupByLibrary.simpleMessage("Available"),
    "courierOnlineHint": MessageLookupByLibrary.simpleMessage(
      "You will receive new delivery offers.",
    ),
    "courierPaid": MessageLookupByLibrary.simpleMessage("Paid in app"),
    "courierPickup": MessageLookupByLibrary.simpleMessage("Pickup"),
    "courierPreparing": MessageLookupByLibrary.simpleMessage(
      "The restaurant is preparing the order.",
    ),
    "courierProducts": MessageLookupByLibrary.simpleMessage("Order"),
    "courierReady": MessageLookupByLibrary.simpleMessage("Ready for pickup"),
    "courierRefresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "courierRoute": MessageLookupByLibrary.simpleMessage("Open directions"),
    "courierSessionError": MessageLookupByLibrary.simpleMessage(
      "Your session is unavailable. Please sign in again.",
    ),
    "courierSettlement": MessageLookupByLibrary.simpleMessage(
      "Recorded settlement",
    ),
    "courierSettlementHint": MessageLookupByLibrary.simpleMessage(
      "Amount recorded by the system; it does not represent a bank transfer.",
    ),
    "courierToday": MessageLookupByLibrary.simpleMessage("Today"),
    "courierTotal": MessageLookupByLibrary.simpleMessage("Order total"),
    "courierUnknown": MessageLookupByLibrary.simpleMessage("Unavailable"),
    "courierUnpriced": MessageLookupByLibrary.simpleMessage(
      "Some deliveries have no recorded earnings and are excluded from the amount.",
    ),
    "customerNotes": MessageLookupByLibrary.simpleMessage(
      "Customer instructions",
    ),
    "decreaseQuantity": MessageLookupByLibrary.simpleMessage(
      "Decrease quantity",
    ),
    "deliverTo": MessageLookupByLibrary.simpleMessage("Deliver to"),
    "dishDetails": MessageLookupByLibrary.simpleMessage("Dish details"),
    "dispatchedOrders": MessageLookupByLibrary.simpleMessage("On delivery"),
    "eValidatoAmount": MessageLookupByLibrary.simpleMessage("Incorrect Amount"),
    "eValidatoCharacters": m1,
    "eValidatoEmail": MessageLookupByLibrary.simpleMessage(
      "The mail format is incorrect",
    ),
    "eValidatoPhone": MessageLookupByLibrary.simpleMessage(
      "The phone number format is incorrect",
    ),
    "editClosing": MessageLookupByLibrary.simpleMessage("Change closing time"),
    "editImage": MessageLookupByLibrary.simpleMessage("Edit image"),
    "editOpening": MessageLookupByLibrary.simpleMessage("Change opening time"),
    "editProduct": MessageLookupByLibrary.simpleMessage("Edit product"),
    "editProfile": MessageLookupByLibrary.simpleMessage("Edit profile"),
    "emptyTab2": MessageLookupByLibrary.simpleMessage(
      "You have does not pending orders",
    ),
    "errDeleteAllAddress": MessageLookupByLibrary.simpleMessage(
      "You cannot delete all addresses. You must have at least one",
    ),
    "errDeliverymanNotFound": MessageLookupByLibrary.simpleMessage(
      "The number I provide does not belong to any registered deliveryman",
    ),
    "errEmailUnique": m2,
    "errManagerCannotBeDeliveryman": MessageLookupByLibrary.simpleMessage(
      "The phone number I provide is assigned to a store (manager role) so it cannot deliveryman (deliveryman role)",
    ),
    "errMinPurchaseAmountCard": m3,
    "errNameUnique": m4,
    "errPhoneNumber": MessageLookupByLibrary.simpleMessage(
      "Please add a phone number",
    ),
    "errPhoneNumberAgain": MessageLookupByLibrary.simpleMessage(
      "Please add the phone number again",
    ),
    "errPhoneUnique": m5,
    "errPleaseUploadImage": MessageLookupByLibrary.simpleMessage(
      "Please upload an image",
    ),
    "errRecoverAccount": m6,
    "errUnknown": MessageLookupByLibrary.simpleMessage(
      "Oops, something seems to have gone wrong, please try again later",
    ),
    "errdeliverymanCannotBeManager": MessageLookupByLibrary.simpleMessage(
      "The phone number I provide is assigned to a deliveryman (deliveryman role) so it cannot manager (manager role)",
    ),
    "explore": MessageLookupByLibrary.simpleMessage("Explore"),
    "featuredProducts": MessageLookupByLibrary.simpleMessage(
      "Discover something new",
    ),
    "fullMenu": MessageLookupByLibrary.simpleMessage("Full menu"),
    "hAddress": MessageLookupByLibrary.simpleMessage("Address"),
    "hAlias": MessageLookupByLibrary.simpleMessage("Alias"),
    "hChat": MessageLookupByLibrary.simpleMessage("Type your message"),
    "hEmail": MessageLookupByLibrary.simpleMessage("Email"),
    "hFilter": MessageLookupByLibrary.simpleMessage(
      "What do you want to eat today?",
    ),
    "hFullName": MessageLookupByLibrary.simpleMessage("Full name"),
    "hNoteProdcut": MessageLookupByLibrary.simpleMessage(
      "Instructions for this product (optional)",
    ),
    "hPassword": MessageLookupByLibrary.simpleMessage("Password"),
    "hPhone": MessageLookupByLibrary.simpleMessage("Phone number"),
    "hProductDescription": MessageLookupByLibrary.simpleMessage(
      "Product description",
    ),
    "hProductName": MessageLookupByLibrary.simpleMessage("Product name"),
    "hYourPhoneNumber": m7,
    "hidePassword": MessageLookupByLibrary.simpleMessage("Hide password"),
    "homeGreeting": MessageLookupByLibrary.simpleMessage(
      "What sounds good today?",
    ),
    "homeSubtitle": MessageLookupByLibrary.simpleMessage(
      "Find something delicious nearby.",
    ),
    "hoursEmpty": MessageLookupByLibrary.simpleMessage(
      "This store has no business hours yet.",
    ),
    "increaseQuantity": MessageLookupByLibrary.simpleMessage(
      "Increase quantity",
    ),
    "kitchenActionError": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t save the change. Please try again.",
    ),
    "kitchenConflict": MessageLookupByLibrary.simpleMessage(
      "The order changed. Check its updated status.",
    ),
    "kitchenEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Orders at this stage will appear here.",
    ),
    "kitchenEmptyTitle": MessageLookupByLibrary.simpleMessage("All caught up"),
    "kitchenErrorTitle": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t load the orders",
    ),
    "kitchenPendingClient": MessageLookupByLibrary.simpleMessage(
      "The restaurant is about to accept your order.",
    ),
    "kitchenPrepEstimate": m8,
    "kitchenPreparingClient": MessageLookupByLibrary.simpleMessage(
      "The restaurant is preparing your order.",
    ),
    "kitchenReadyClient": MessageLookupByLibrary.simpleMessage(
      "Your order is ready for pickup.",
    ),
    "kitchenSubtitle": MessageLookupByLibrary.simpleMessage(
      "Every order, at the right time.",
    ),
    "kitchenTitle": MessageLookupByLibrary.simpleMessage("Your kitchen"),
    "lAddedCart": MessageLookupByLibrary.simpleMessage("Added to cart"),
    "lAmount": MessageLookupByLibrary.simpleMessage("Amount"),
    "lClient": MessageLookupByLibrary.simpleMessage("Client"),
    "lClosed": MessageLookupByLibrary.simpleMessage("Closed"),
    "lDeliveryAddress": MessageLookupByLibrary.simpleMessage(
      "Delivery address",
    ),
    "lDeliveryFee": MessageLookupByLibrary.simpleMessage("Shipment"),
    "lDeliveryman": MessageLookupByLibrary.simpleMessage("Deliveryman"),
    "lFriday": MessageLookupByLibrary.simpleMessage("Friday"),
    "lHAmounValid": MessageLookupByLibrary.simpleMessage(
      "Amount to be refunded by credit card",
    ),
    "lHBalanceValid": MessageLookupByLibrary.simpleMessage(
      "Balance to be able to take orders",
    ),
    "lHMoneyValid": MessageLookupByLibrary.simpleMessage(
      "This amount automatically reduces the payment",
    ),
    "lMonday": MessageLookupByLibrary.simpleMessage("Monday"),
    "lNewAddress": MessageLookupByLibrary.simpleMessage("New address"),
    "lNumber": MessageLookupByLibrary.simpleMessage("Number"),
    "lOrderBy": MessageLookupByLibrary.simpleMessage("Order by"),
    "lPayCash": MessageLookupByLibrary.simpleMessage("Pay in cash"),
    "lPayMoney": MessageLookupByLibrary.simpleMessage("Pay by credit card"),
    "lPaymentMethods": MessageLookupByLibrary.simpleMessage("Payment methods"),
    "lPrice": MessageLookupByLibrary.simpleMessage("Price"),
    "lProduct": MessageLookupByLibrary.simpleMessage("Product"),
    "lSaturday": MessageLookupByLibrary.simpleMessage("Saturday"),
    "lSearch": MessageLookupByLibrary.simpleMessage("Search"),
    "lSelect": MessageLookupByLibrary.simpleMessage("Select"),
    "lStatusOrderAssigned": MessageLookupByLibrary.simpleMessage(
      "🛵 The delivery man is on his way to pick up your order",
    ),
    "lStatusOrderCancelled": MessageLookupByLibrary.simpleMessage(
      "🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience",
    ),
    "lStatusOrderDelivered": MessageLookupByLibrary.simpleMessage(
      "🥳 Thank you for choosing us. Please rate your experience",
    ),
    "lStatusOrderQualified": MessageLookupByLibrary.simpleMessage(
      "Thank you for choosing us",
    ),
    "lStatusOrderStarted": MessageLookupByLibrary.simpleMessage(
      "👨🏼‍🍳 The restaurant is preparing your order",
    ),
    "lStatusOrderTaken": MessageLookupByLibrary.simpleMessage(
      "💚 The driver has reported boarding the vehicle",
    ),
    "lStatusTaxiAssigned": MessageLookupByLibrary.simpleMessage(
      "🚖 You have been assigned a cab. 🚕 The cab is heading to your location",
    ),
    "lStatusTaxiCancelled": MessageLookupByLibrary.simpleMessage(
      "🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience",
    ),
    "lStatusTaxiDelivered": MessageLookupByLibrary.simpleMessage(
      "🥳 Thank you for choosing us. Please rate your experience",
    ),
    "lStatusTaxiQualified": MessageLookupByLibrary.simpleMessage(
      "Thank you for choosing us",
    ),
    "lStatusTaxiStarted": MessageLookupByLibrary.simpleMessage(
      "🔎 We are looking for a nearby unit",
    ),
    "lStatusTaxiTaken": MessageLookupByLibrary.simpleMessage(
      "💚 The driver has reported boarding the vehicle.",
    ),
    "lSunday": MessageLookupByLibrary.simpleMessage("Sunday"),
    "lTMoneyValid": MessageLookupByLibrary.simpleMessage(
      "Money. Valid only with credit card",
    ),
    "lThursday": MessageLookupByLibrary.simpleMessage("Thursday"),
    "lTotal": MessageLookupByLibrary.simpleMessage("Total"),
    "lTuesday": MessageLookupByLibrary.simpleMessage("Tuesday"),
    "lWednesday": MessageLookupByLibrary.simpleMessage("Wednesday"),
    "legacyKitchen": MessageLookupByLibrary.simpleMessage(
      "No kitchen status recorded",
    ),
    "lselectCategory": MessageLookupByLibrary.simpleMessage(
      "Select a category",
    ),
    "lselectGroup": MessageLookupByLibrary.simpleMessage("Select a group"),
    "lselectPayment": MessageLookupByLibrary.simpleMessage(
      "Select a payment method",
    ),
    "mDCancelOrder": m9,
    "mDConfirmOrder": MessageLookupByLibrary.simpleMessage(
      "Confirm that you have picked up the order",
    ),
    "mDFinish": MessageLookupByLibrary.simpleMessage("Please rate the client"),
    "mDLogoutSession": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to log out?",
    ),
    "mDStoreClosed": MessageLookupByLibrary.simpleMessage(
      "This store is closed, you can view their products but you will not be able to make a purchase until the store is open",
    ),
    "mEither": MessageLookupByLibrary.simpleMessage("either"),
    "mIncorrectLogin": MessageLookupByLibrary.simpleMessage(
      "Incorrect username or password",
    ),
    "mMaximumDistanceStoreStartingPoint": m10,
    "mMinimumTravelDistance": m11,
    "mRAddressRemoved": MessageLookupByLibrary.simpleMessage("Address removed"),
    "mRChangesMadeCorrectly": MessageLookupByLibrary.simpleMessage(
      "Changes made correctly",
    ),
    "mRConfirmOrde": MessageLookupByLibrary.simpleMessage(
      "Cool. We notify that you have picked up the order",
    ),
    "mRStoreCongratulations": MessageLookupByLibrary.simpleMessage(
      "Congratulations, you have successfully registered your store. Now create your products and start selling",
    ),
    "mRTopUpBalance": m12,
    "mRecoverAccount": m13,
    "mRinsufficientBalance": MessageLookupByLibrary.simpleMessage(
      "Insufficient funds. Please top up your balance",
    ),
    "mRorderFulfilled": MessageLookupByLibrary.simpleMessage(
      "Oops, the request has already been fulfilled",
    ),
    "manageHours": MessageLookupByLibrary.simpleMessage("Business hours"),
    "managerStoresEmpty": MessageLookupByLibrary.simpleMessage(
      "No stores assigned yet",
    ),
    "managerStoresEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Stores linked to your account will appear here.",
    ),
    "markReady": MessageLookupByLibrary.simpleMessage("Mark ready for pickup"),
    "matchingDishes": MessageLookupByLibrary.simpleMessage("Matching dishes"),
    "matchingRestaurants": MessageLookupByLibrary.simpleMessage(
      "Related restaurants",
    ),
    "menuAbove": m14,
    "menuDescription": MessageLookupByLibrary.simpleMessage(
      "Manage your business\'s products.",
    ),
    "menuEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Add your first product with a name, description and price.",
    ),
    "menuEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Your menu starts here",
    ),
    "menuItems": m15,
    "menuSingleItem": MessageLookupByLibrary.simpleMessage("1 option"),
    "menuUpTo": m16,
    "nearbyStores": MessageLookupByLibrary.simpleMessage("Nearby"),
    "newOrders": MessageLookupByLibrary.simpleMessage("New"),
    "noResultsMessage": MessageLookupByLibrary.simpleMessage(
      "Try another search or choose a different category.",
    ),
    "noResultsTitle": MessageLookupByLibrary.simpleMessage("No matches found"),
    "noStoresMessage": MessageLookupByLibrary.simpleMessage(
      "Try a different delivery address or check back later.",
    ),
    "noStoresTitle": MessageLookupByLibrary.simpleMessage(
      "No stores nearby yet",
    ),
    "openHistory": MessageLookupByLibrary.simpleMessage("Order history"),
    "openStore": MessageLookupByLibrary.simpleMessage("Open"),
    "orderAccepted": MessageLookupByLibrary.simpleMessage(
      "Order accepted. You can start preparing it.",
    ),
    "orderAssigned": MessageLookupByLibrary.simpleMessage("Rider assigned"),
    "orderCompleted": MessageLookupByLibrary.simpleMessage("Delivered"),
    "orderDetails": MessageLookupByLibrary.simpleMessage("View details"),
    "orderNumber": m17,
    "orderOnTheWay": MessageLookupByLibrary.simpleMessage("On the way"),
    "orderProgress": MessageLookupByLibrary.simpleMessage("Order status"),
    "orderReady": MessageLookupByLibrary.simpleMessage(
      "Order ready for the rider to pick up.",
    ),
    "orderReceived": MessageLookupByLibrary.simpleMessage("Order received"),
    "ordersEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "Once you place an order, you can track it here.",
    ),
    "ordersEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "Your orders will appear here",
    ),
    "ordersErrorMessage": MessageLookupByLibrary.simpleMessage(
      "Check your connection and try again.",
    ),
    "ordersErrorTitle": MessageLookupByLibrary.simpleMessage(
      "We couldn\'t load your orders",
    ),
    "ordersGuestMessage": MessageLookupByLibrary.simpleMessage(
      "Sign in to view and track your orders.",
    ),
    "photoOptional": MessageLookupByLibrary.simpleMessage("Optional photo"),
    "preparationMinutesLabel": m18,
    "preparationTime": MessageLookupByLibrary.simpleMessage("Preparation time"),
    "preparingOrders": MessageLookupByLibrary.simpleMessage("Preparing"),
    "privacyPolicy": MessageLookupByLibrary.simpleMessage("Privacy"),
    "productDescriptionError": MessageLookupByLibrary.simpleMessage(
      "Describe the product with at least 10 characters.",
    ),
    "productDescriptionLabel": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "productNameError": MessageLookupByLibrary.simpleMessage(
      "Enter a name with at least 4 characters.",
    ),
    "productNameLabel": MessageLookupByLibrary.simpleMessage("Product name"),
    "productPriceError": MessageLookupByLibrary.simpleMessage(
      "Enter a price greater than zero.",
    ),
    "productPriceLabel": MessageLookupByLibrary.simpleMessage("Price (USD)"),
    "quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "readyOrders": MessageLookupByLibrary.simpleMessage("Ready"),
    "removeFromCart": MessageLookupByLibrary.simpleMessage("Remove from cart"),
    "removeProduct": MessageLookupByLibrary.simpleMessage("Remove product"),
    "restaurantBusiness": MessageLookupByLibrary.simpleMessage("Business"),
    "restaurantInformation": MessageLookupByLibrary.simpleMessage(
      "Restaurant information",
    ),
    "restaurantMenu": MessageLookupByLibrary.simpleMessage("Menu"),
    "retry": MessageLookupByLibrary.simpleMessage("Try again"),
    "reviewOrder": MessageLookupByLibrary.simpleMessage("Review order"),
    "sFeatured": MessageLookupByLibrary.simpleMessage("People love them"),
    "sSlideApply": MessageLookupByLibrary.simpleMessage("Slide to apply"),
    "sTCategory": MessageLookupByLibrary.simpleMessage("Filter by category"),
    "sTCompanyPopular": MessageLookupByLibrary.simpleMessage(
      "You can\'t miss them",
    ),
    "sTCompanyTop": MessageLookupByLibrary.simpleMessage(
      "You have to try them",
    ),
    "sTOrders": MessageLookupByLibrary.simpleMessage(
      "Check the status of your deliveries",
    ),
    "saveProduct": MessageLookupByLibrary.simpleMessage("Save product"),
    "scheduleUpdated": MessageLookupByLibrary.simpleMessage(
      "Schedule updated.",
    ),
    "searchMenu": MessageLookupByLibrary.simpleMessage("Search this menu"),
    "selectOption": MessageLookupByLibrary.simpleMessage("Select an option"),
    "shippingAtCheckout": MessageLookupByLibrary.simpleMessage(
      "Delivery is calculated when you review your order.",
    ),
    "showPassword": MessageLookupByLibrary.simpleMessage("Show password"),
    "signOut": MessageLookupByLibrary.simpleMessage("Sign out"),
    "storeEmptyMessage": MessageLookupByLibrary.simpleMessage(
      "This store has no products available yet.",
    ),
    "storeEmptyTitle": MessageLookupByLibrary.simpleMessage(
      "The menu is on its way",
    ),
    "subtotal": MessageLookupByLibrary.simpleMessage("Subtotal"),
    "tAbout": MessageLookupByLibrary.simpleMessage("About"),
    "tAddress": MessageLookupByLibrary.simpleMessage("Address"),
    "tAddresses": MessageLookupByLibrary.simpleMessage("Addresses"),
    "tAppBarOrders": MessageLookupByLibrary.simpleMessage("Orders"),
    "tCartSummary": MessageLookupByLibrary.simpleMessage(
      "Summary & Address of delivery",
    ),
    "tCategories": MessageLookupByLibrary.simpleMessage("Categories"),
    "tCloseTo": m19,
    "tClosingTime": MessageLookupByLibrary.simpleMessage("CLOSING TIME"),
    "tCompanyPopular": MessageLookupByLibrary.simpleMessage("Most purchased"),
    "tCompanyTop": MessageLookupByLibrary.simpleMessage("The best rated"),
    "tDestination": MessageLookupByLibrary.simpleMessage("Destination"),
    "tFeatured": MessageLookupByLibrary.simpleMessage("Featured"),
    "tMyOrder": MessageLookupByLibrary.simpleMessage("My order"),
    "tNotifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "tOpeningTime": MessageLookupByLibrary.simpleMessage("OPENING TIME"),
    "tOrders": MessageLookupByLibrary.simpleMessage("Your orders"),
    "tPetitions": MessageLookupByLibrary.simpleMessage("Petitions"),
    "tPetitionsHistory": MessageLookupByLibrary.simpleMessage("History"),
    "tPickupLocation": MessageLookupByLibrary.simpleMessage("Pickup location"),
    "tRegisterStore": MessageLookupByLibrary.simpleMessage(
      "Register your store",
    ),
    "tRequestCab": MessageLookupByLibrary.simpleMessage("Request cab"),
    "tRequests": MessageLookupByLibrary.simpleMessage("Requests"),
    "tRequestsHistory": MessageLookupByLibrary.simpleMessage("History"),
    "tStore": MessageLookupByLibrary.simpleMessage("Products"),
    "tStores": MessageLookupByLibrary.simpleMessage("My stores"),
    "tTStore": MessageLookupByLibrary.simpleMessage("Only for you"),
    "tTopUpBalance": MessageLookupByLibrary.simpleMessage("Top up balance"),
    "tWelcome": MessageLookupByLibrary.simpleMessage(
      "Tell us from which location we show you the best restaurants",
    ),
    "tab1": MessageLookupByLibrary.simpleMessage("Explore"),
    "tab2": MessageLookupByLibrary.simpleMessage("Orders"),
    "termsOfService": MessageLookupByLibrary.simpleMessage("Terms of use"),
    "trackingLocationUpdated": MessageLookupByLibrary.simpleMessage(
      "Courier location received",
    ),
    "trackingMapUnavailable": MessageLookupByLibrary.simpleMessage(
      "The map is unavailable for now. You can follow your order status here.",
    ),
    "trackingWaitingLocation": MessageLookupByLibrary.simpleMessage(
      "Waiting for the courier\'s location",
    ),
    "viewActiveOrders": MessageLookupByLibrary.simpleMessage(
      "Back to active orders",
    ),
    "viewCart": MessageLookupByLibrary.simpleMessage("View cart"),
    "viewLocation": MessageLookupByLibrary.simpleMessage("View location"),
    "waitingForKitchen": MessageLookupByLibrary.simpleMessage(
      "Wait for the restaurant to mark the order ready.",
    ),
    "walletBalance": MessageLookupByLibrary.simpleMessage("Wallet balance"),
    "walletBalanceHint": MessageLookupByLibrary.simpleMessage(
      "This balance is applied when you pay with your wallet.",
    ),
    "welcomeAccess": MessageLookupByLibrary.simpleMessage(
      "Sign in or create an account",
    ),
    "welcomeDelivery": MessageLookupByLibrary.simpleMessage(
      "Order to your address",
    ),
    "welcomeDeliveryMessage": MessageLookupByLibrary.simpleMessage(
      "Choose your dishes and confirm your delivery.",
    ),
    "welcomeDescription": MessageLookupByLibrary.simpleMessage(
      "Explore restaurants and menus, order your favorite dishes and get them delivered to the address you choose.",
    ),
    "welcomeDiscover": MessageLookupByLibrary.simpleMessage(
      "Find your next meal",
    ),
    "welcomeDiscoverMessage": MessageLookupByLibrary.simpleMessage(
      "Explore your options and discover new flavors.",
    ),
    "welcomeExplore": MessageLookupByLibrary.simpleMessage(
      "Choose an address and explore",
    ),
    "welcomeTitle": MessageLookupByLibrary.simpleMessage(
      "Your restaurants,\nat your door.",
    ),
    "welcomeTracking": MessageLookupByLibrary.simpleMessage(
      "Follow your order",
    ),
    "welcomeTrackingMessage": MessageLookupByLibrary.simpleMessage(
      "From preparation until it reaches you.",
    ),
  };
}
