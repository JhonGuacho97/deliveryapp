// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Tell us from which location we show you the best restaurants`
  String get tWelcome {
    return Intl.message(
      'Tell us from which location we show you the best restaurants',
      name: 'tWelcome',
      desc: '',
      args: [],
    );
  }

  /// `either`
  String get mEither {
    return Intl.message('either', name: 'mEither', desc: '', args: []);
  }

  /// `Featured`
  String get tFeatured {
    return Intl.message('Featured', name: 'tFeatured', desc: '', args: []);
  }

  /// `People love them`
  String get sFeatured {
    return Intl.message(
      'People love them',
      name: 'sFeatured',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get tCategories {
    return Intl.message('Categories', name: 'tCategories', desc: '', args: []);
  }

  /// `Filter by category`
  String get sTCategory {
    return Intl.message(
      'Filter by category',
      name: 'sTCategory',
      desc: '',
      args: [],
    );
  }

  /// `The best rated`
  String get tCompanyTop {
    return Intl.message(
      'The best rated',
      name: 'tCompanyTop',
      desc: '',
      args: [],
    );
  }

  /// `You have to try them`
  String get sTCompanyTop {
    return Intl.message(
      'You have to try them',
      name: 'sTCompanyTop',
      desc: '',
      args: [],
    );
  }

  /// `Most purchased`
  String get tCompanyPopular {
    return Intl.message(
      'Most purchased',
      name: 'tCompanyPopular',
      desc: '',
      args: [],
    );
  }

  /// `You can't miss them`
  String get sTCompanyPopular {
    return Intl.message(
      'You can\'t miss them',
      name: 'sTCompanyPopular',
      desc: '',
      args: [],
    );
  }

  /// `Your orders`
  String get tOrders {
    return Intl.message('Your orders', name: 'tOrders', desc: '', args: []);
  }

  /// `Check the status of your deliveries`
  String get sTOrders {
    return Intl.message(
      'Check the status of your deliveries',
      name: 'sTOrders',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get tAddress {
    return Intl.message('Address', name: 'tAddress', desc: '', args: []);
  }

  /// `Addresses`
  String get tAddresses {
    return Intl.message('Addresses', name: 'tAddresses', desc: '', args: []);
  }

  /// `My stores`
  String get tStores {
    return Intl.message('My stores', name: 'tStores', desc: '', args: []);
  }

  /// `Register your store`
  String get tRegisterStore {
    return Intl.message(
      'Register your store',
      name: 'tRegisterStore',
      desc: '',
      args: [],
    );
  }

  /// `Top up balance`
  String get tTopUpBalance {
    return Intl.message(
      'Top up balance',
      name: 'tTopUpBalance',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get tNotifications {
    return Intl.message(
      'Notifications',
      name: 'tNotifications',
      desc: '',
      args: [],
    );
  }

  /// `You have no notifications yet.`
  String get noNotifications {
    return Intl.message(
      'You have no notifications yet.',
      name: 'noNotifications',
      desc: '',
      args: [],
    );
  }

  /// `Software licenses`
  String get softwareLicenses {
    return Intl.message(
      'Software licenses',
      name: 'softwareLicenses',
      desc: '',
      args: [],
    );
  }

  /// `Explore`
  String get tab1 {
    return Intl.message('Explore', name: 'tab1', desc: '', args: []);
  }

  /// `Orders`
  String get tab2 {
    return Intl.message('Orders', name: 'tab2', desc: '', args: []);
  }

  /// `Products`
  String get tStore {
    return Intl.message('Products', name: 'tStore', desc: '', args: []);
  }

  /// `Only for you`
  String get tTStore {
    return Intl.message('Only for you', name: 'tTStore', desc: '', args: []);
  }

  /// `Orders`
  String get tAppBarOrders {
    return Intl.message('Orders', name: 'tAppBarOrders', desc: '', args: []);
  }

  /// `About`
  String get tAbout {
    return Intl.message('About', name: 'tAbout', desc: '', args: []);
  }

  /// `Close to {alias}`
  String tCloseTo(Object alias) {
    return Intl.message(
      'Close to $alias',
      name: 'tCloseTo',
      desc: '',
      args: [alias],
    );
  }

  /// `Petitions`
  String get tPetitions {
    return Intl.message('Petitions', name: 'tPetitions', desc: '', args: []);
  }

  /// `History`
  String get tPetitionsHistory {
    return Intl.message(
      'History',
      name: 'tPetitionsHistory',
      desc: '',
      args: [],
    );
  }

  /// `Requests`
  String get tRequests {
    return Intl.message('Requests', name: 'tRequests', desc: '', args: []);
  }

  /// `History`
  String get tRequestsHistory {
    return Intl.message(
      'History',
      name: 'tRequestsHistory',
      desc: '',
      args: [],
    );
  }

  /// `Pickup location`
  String get tPickupLocation {
    return Intl.message(
      'Pickup location',
      name: 'tPickupLocation',
      desc: '',
      args: [],
    );
  }

  /// `Destination`
  String get tDestination {
    return Intl.message(
      'Destination',
      name: 'tDestination',
      desc: '',
      args: [],
    );
  }

  /// `Request cab`
  String get tRequestCab {
    return Intl.message('Request cab', name: 'tRequestCab', desc: '', args: []);
  }

  /// `OPENING TIME`
  String get tOpeningTime {
    return Intl.message(
      'OPENING TIME',
      name: 'tOpeningTime',
      desc: '',
      args: [],
    );
  }

  /// `CLOSING TIME`
  String get tClosingTime {
    return Intl.message(
      'CLOSING TIME',
      name: 'tClosingTime',
      desc: '',
      args: [],
    );
  }

  /// `Shipment`
  String get lDeliveryFee {
    return Intl.message('Shipment', name: 'lDeliveryFee', desc: '', args: []);
  }

  /// `Added to cart`
  String get lAddedCart {
    return Intl.message(
      'Added to cart',
      name: 'lAddedCart',
      desc: '',
      args: [],
    );
  }

  /// `Order by`
  String get lOrderBy {
    return Intl.message('Order by', name: 'lOrderBy', desc: '', args: []);
  }

  /// `Deliveryman`
  String get lDeliveryman {
    return Intl.message(
      'Deliveryman',
      name: 'lDeliveryman',
      desc: '',
      args: [],
    );
  }

  /// `Client`
  String get lClient {
    return Intl.message('Client', name: 'lClient', desc: '', args: []);
  }

  /// `Total`
  String get lTotal {
    return Intl.message('Total', name: 'lTotal', desc: '', args: []);
  }

  /// `Price`
  String get lPrice {
    return Intl.message('Price', name: 'lPrice', desc: '', args: []);
  }

  /// `Amount`
  String get lAmount {
    return Intl.message('Amount', name: 'lAmount', desc: '', args: []);
  }

  /// `Product`
  String get lProduct {
    return Intl.message('Product', name: 'lProduct', desc: '', args: []);
  }

  /// `Number`
  String get lNumber {
    return Intl.message('Number', name: 'lNumber', desc: '', args: []);
  }

  /// `Delivery address`
  String get lDeliveryAddress {
    return Intl.message(
      'Delivery address',
      name: 'lDeliveryAddress',
      desc: '',
      args: [],
    );
  }

  /// `Payment methods`
  String get lPaymentMethods {
    return Intl.message(
      'Payment methods',
      name: 'lPaymentMethods',
      desc: '',
      args: [],
    );
  }

  /// `New address`
  String get lNewAddress {
    return Intl.message('New address', name: 'lNewAddress', desc: '', args: []);
  }

  /// `Select`
  String get lSelect {
    return Intl.message('Select', name: 'lSelect', desc: '', args: []);
  }

  /// `Closed`
  String get lClosed {
    return Intl.message('Closed', name: 'lClosed', desc: '', args: []);
  }

  /// `Search`
  String get lSearch {
    return Intl.message('Search', name: 'lSearch', desc: '', args: []);
  }

  /// `Select a category`
  String get lselectCategory {
    return Intl.message(
      'Select a category',
      name: 'lselectCategory',
      desc: '',
      args: [],
    );
  }

  /// `Select a payment method`
  String get lselectPayment {
    return Intl.message(
      'Select a payment method',
      name: 'lselectPayment',
      desc: '',
      args: [],
    );
  }

  /// `Select a group`
  String get lselectGroup {
    return Intl.message(
      'Select a group',
      name: 'lselectGroup',
      desc: '',
      args: [],
    );
  }

  /// `Pay in cash`
  String get lPayCash {
    return Intl.message('Pay in cash', name: 'lPayCash', desc: '', args: []);
  }

  /// `Pay by credit card`
  String get lPayMoney {
    return Intl.message(
      'Pay by credit card',
      name: 'lPayMoney',
      desc: '',
      args: [],
    );
  }

  /// `Money. Valid only with credit card`
  String get lTMoneyValid {
    return Intl.message(
      'Money. Valid only with credit card',
      name: 'lTMoneyValid',
      desc: '',
      args: [],
    );
  }

  /// `This amount automatically reduces the payment`
  String get lHMoneyValid {
    return Intl.message(
      'This amount automatically reduces the payment',
      name: 'lHMoneyValid',
      desc: '',
      args: [],
    );
  }

  /// `Balance to be able to take orders`
  String get lHBalanceValid {
    return Intl.message(
      'Balance to be able to take orders',
      name: 'lHBalanceValid',
      desc: '',
      args: [],
    );
  }

  /// `Amount to be refunded by credit card`
  String get lHAmounValid {
    return Intl.message(
      'Amount to be refunded by credit card',
      name: 'lHAmounValid',
      desc: '',
      args: [],
    );
  }

  /// `My order`
  String get tMyOrder {
    return Intl.message('My order', name: 'tMyOrder', desc: '', args: []);
  }

  /// `Summary & Address of delivery`
  String get tCartSummary {
    return Intl.message(
      'Summary & Address of delivery',
      name: 'tCartSummary',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get bContinue {
    return Intl.message('Continue', name: 'bContinue', desc: '', args: []);
  }

  /// `Pay`
  String get bPay {
    return Intl.message('Pay', name: 'bPay', desc: '', args: []);
  }

  /// `Set location`
  String get bEstablishLocation {
    return Intl.message(
      'Set location',
      name: 'bEstablishLocation',
      desc: '',
      args: [],
    );
  }

  /// `Login`
  String get bLogin {
    return Intl.message('Login', name: 'bLogin', desc: '', args: []);
  }

  /// `Sign in`
  String get bSignin {
    return Intl.message('Sign in', name: 'bSignin', desc: '', args: []);
  }

  /// `Sign up`
  String get bSignup {
    return Intl.message('Sign up', name: 'bSignup', desc: '', args: []);
  }

  /// `Recover account`
  String get bRecoverAccount {
    return Intl.message(
      'Recover account',
      name: 'bRecoverAccount',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get bSaveChanges {
    return Intl.message('Save', name: 'bSaveChanges', desc: '', args: []);
  }

  /// `Upload`
  String get bUpload {
    return Intl.message('Upload', name: 'bUpload', desc: '', args: []);
  }

  /// `Cancel`
  String get bCancel {
    return Intl.message('Cancel', name: 'bCancel', desc: '', args: []);
  }

  /// `Confirm`
  String get bConfirm {
    return Intl.message('Confirm', name: 'bConfirm', desc: '', args: []);
  }

  /// `Finish`
  String get bFinish {
    return Intl.message('Finish', name: 'bFinish', desc: '', args: []);
  }

  /// `Route to the client`
  String get bRouteClient {
    return Intl.message(
      'Route to the client',
      name: 'bRouteClient',
      desc: '',
      args: [],
    );
  }

  /// `Route to the store`
  String get bRouteStore {
    return Intl.message(
      'Route to the store',
      name: 'bRouteStore',
      desc: '',
      args: [],
    );
  }

  /// `Qualify`
  String get bQualify {
    return Intl.message('Qualify', name: 'bQualify', desc: '', args: []);
  }

  /// `Online`
  String get bOnline {
    return Intl.message('Online', name: 'bOnline', desc: '', args: []);
  }

  /// `Offline`
  String get bOffline {
    return Intl.message('Offline', name: 'bOffline', desc: '', args: []);
  }

  /// `Add a new address`
  String get bNewAddress {
    return Intl.message(
      'Add a new address',
      name: 'bNewAddress',
      desc: '',
      args: [],
    );
  }

  /// `Accept`
  String get bAccept {
    return Intl.message('Accept', name: 'bAccept', desc: '', args: []);
  }

  /// `Done`
  String get bDone {
    return Intl.message('Done', name: 'bDone', desc: '', args: []);
  }

  /// `Change password`
  String get bChangePassword {
    return Intl.message(
      'Change password',
      name: 'bChangePassword',
      desc: '',
      args: [],
    );
  }

  /// `Select a photo`
  String get bSelectPhoto {
    return Intl.message(
      'Select a photo',
      name: 'bSelectPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Select an address`
  String get bSelectAddress {
    return Intl.message(
      'Select an address',
      name: 'bSelectAddress',
      desc: '',
      args: [],
    );
  }

  /// `New product`
  String get bNewProduct {
    return Intl.message('New product', name: 'bNewProduct', desc: '', args: []);
  }

  /// `Return`
  String get bReturn {
    return Intl.message('Return', name: 'bReturn', desc: '', args: []);
  }

  /// `Set pick-up point`
  String get bSetPickUpPoint {
    return Intl.message(
      'Set pick-up point',
      name: 'bSetPickUpPoint',
      desc: '',
      args: [],
    );
  }

  /// `Set destination point`
  String get bSetDestinationPoint {
    return Intl.message(
      'Set destination point',
      name: 'bSetDestinationPoint',
      desc: '',
      args: [],
    );
  }

  /// `Request cab`
  String get bRequestCabt {
    return Intl.message(
      'Request cab',
      name: 'bRequestCabt',
      desc: '',
      args: [],
    );
  }

  /// `Slide to apply`
  String get sSlideApply {
    return Intl.message(
      'Slide to apply',
      name: 'sSlideApply',
      desc: '',
      args: [],
    );
  }

  /// `Instructions for this product (optional)`
  String get hNoteProdcut {
    return Intl.message(
      'Instructions for this product (optional)',
      name: 'hNoteProdcut',
      desc: '',
      args: [],
    );
  }

  /// `Type your message`
  String get hChat {
    return Intl.message('Type your message', name: 'hChat', desc: '', args: []);
  }

  /// `Email`
  String get hEmail {
    return Intl.message('Email', name: 'hEmail', desc: '', args: []);
  }

  /// `Password`
  String get hPassword {
    return Intl.message('Password', name: 'hPassword', desc: '', args: []);
  }

  /// `Phone number`
  String get hPhone {
    return Intl.message('Phone number', name: 'hPhone', desc: '', args: []);
  }

  /// `Full name`
  String get hFullName {
    return Intl.message('Full name', name: 'hFullName', desc: '', args: []);
  }

  /// `Address`
  String get hAddress {
    return Intl.message('Address', name: 'hAddress', desc: '', args: []);
  }

  /// `Alias`
  String get hAlias {
    return Intl.message('Alias', name: 'hAlias', desc: '', args: []);
  }

  /// `Your phone number is: {phone}`
  String hYourPhoneNumber(Object phone) {
    return Intl.message(
      'Your phone number is: $phone',
      name: 'hYourPhoneNumber',
      desc: '',
      args: [phone],
    );
  }

  /// `Product name`
  String get hProductName {
    return Intl.message(
      'Product name',
      name: 'hProductName',
      desc: '',
      args: [],
    );
  }

  /// `Product description`
  String get hProductDescription {
    return Intl.message(
      'Product description',
      name: 'hProductDescription',
      desc: '',
      args: [],
    );
  }

  /// `What do you want to eat today?`
  String get hFilter {
    return Intl.message(
      'What do you want to eat today?',
      name: 'hFilter',
      desc: '',
      args: [],
    );
  }

  /// `The mail format is incorrect`
  String get eValidatoEmail {
    return Intl.message(
      'The mail format is incorrect',
      name: 'eValidatoEmail',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect Amount`
  String get eValidatoAmount {
    return Intl.message(
      'Incorrect Amount',
      name: 'eValidatoAmount',
      desc: '',
      args: [],
    );
  }

  /// `Minimum of characters {number}`
  String eValidatoCharacters(Object number) {
    return Intl.message(
      'Minimum of characters $number',
      name: 'eValidatoCharacters',
      desc: '',
      args: [number],
    );
  }

  /// `The phone number format is incorrect`
  String get eValidatoPhone {
    return Intl.message(
      'The phone number format is incorrect',
      name: 'eValidatoPhone',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect username or password`
  String get mIncorrectLogin {
    return Intl.message(
      'Incorrect username or password',
      name: 'mIncorrectLogin',
      desc: '',
      args: [],
    );
  }

  /// `Oops, something seems to have gone wrong, please try again later`
  String get errUnknown {
    return Intl.message(
      'Oops, something seems to have gone wrong, please try again later',
      name: 'errUnknown',
      desc: '',
      args: [],
    );
  }

  /// `The email {email} is already registered`
  String errEmailUnique(Object email) {
    return Intl.message(
      'The email $email is already registered',
      name: 'errEmailUnique',
      desc: '',
      args: [email],
    );
  }

  /// `The phone number {phone} is already registered`
  String errPhoneUnique(Object phone) {
    return Intl.message(
      'The phone number $phone is already registered',
      name: 'errPhoneUnique',
      desc: '',
      args: [phone],
    );
  }

  /// `The name {name} is already registered`
  String errNameUnique(Object name) {
    return Intl.message(
      'The name $name is already registered',
      name: 'errNameUnique',
      desc: '',
      args: [name],
    );
  }

  /// `The email address {email} is not in our records.`
  String errRecoverAccount(Object email) {
    return Intl.message(
      'The email address $email is not in our records.',
      name: 'errRecoverAccount',
      desc: '',
      args: [email],
    );
  }

  /// `You cannot delete all addresses. You must have at least one`
  String get errDeleteAllAddress {
    return Intl.message(
      'You cannot delete all addresses. You must have at least one',
      name: 'errDeleteAllAddress',
      desc: '',
      args: [],
    );
  }

  /// `Please add the phone number again`
  String get errPhoneNumberAgain {
    return Intl.message(
      'Please add the phone number again',
      name: 'errPhoneNumberAgain',
      desc: '',
      args: [],
    );
  }

  /// `Please upload an image`
  String get errPleaseUploadImage {
    return Intl.message(
      'Please upload an image',
      name: 'errPleaseUploadImage',
      desc: '',
      args: [],
    );
  }

  /// `Please add a phone number`
  String get errPhoneNumber {
    return Intl.message(
      'Please add a phone number',
      name: 'errPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `The minimum credit card purchase amount is {minPurchaseAmountCard} {coin}. Please add more products to the cart. Or pay cash`
  String errMinPurchaseAmountCard(Object minPurchaseAmountCard, Object coin) {
    return Intl.message(
      'The minimum credit card purchase amount is $minPurchaseAmountCard $coin. Please add more products to the cart. Or pay cash',
      name: 'errMinPurchaseAmountCard',
      desc: '',
      args: [minPurchaseAmountCard, coin],
    );
  }

  /// `The number I provide does not belong to any registered deliveryman`
  String get errDeliverymanNotFound {
    return Intl.message(
      'The number I provide does not belong to any registered deliveryman',
      name: 'errDeliverymanNotFound',
      desc: '',
      args: [],
    );
  }

  /// `The phone number I provide is assigned to a store (manager role) so it cannot deliveryman (deliveryman role)`
  String get errManagerCannotBeDeliveryman {
    return Intl.message(
      'The phone number I provide is assigned to a store (manager role) so it cannot deliveryman (deliveryman role)',
      name: 'errManagerCannotBeDeliveryman',
      desc: '',
      args: [],
    );
  }

  /// `The phone number I provide is assigned to a deliveryman (deliveryman role) so it cannot manager (manager role)`
  String get errdeliverymanCannotBeManager {
    return Intl.message(
      'The phone number I provide is assigned to a deliveryman (deliveryman role) so it cannot manager (manager role)',
      name: 'errdeliverymanCannotBeManager',
      desc: '',
      args: [],
    );
  }

  /// `👨🏼‍🍳 The restaurant is preparing your order`
  String get lStatusOrderStarted {
    return Intl.message(
      '👨🏼‍🍳 The restaurant is preparing your order',
      name: 'lStatusOrderStarted',
      desc: '',
      args: [],
    );
  }

  /// `🛵 The delivery man is on his way to pick up your order`
  String get lStatusOrderAssigned {
    return Intl.message(
      '🛵 The delivery man is on his way to pick up your order',
      name: 'lStatusOrderAssigned',
      desc: '',
      args: [],
    );
  }

  /// `💚 The driver has reported boarding the vehicle`
  String get lStatusOrderTaken {
    return Intl.message(
      '💚 The driver has reported boarding the vehicle',
      name: 'lStatusOrderTaken',
      desc: '',
      args: [],
    );
  }

  /// `🥳 Thank you for choosing us. Please rate your experience`
  String get lStatusOrderDelivered {
    return Intl.message(
      '🥳 Thank you for choosing us. Please rate your experience',
      name: 'lStatusOrderDelivered',
      desc: '',
      args: [],
    );
  }

  /// `🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience`
  String get lStatusOrderCancelled {
    return Intl.message(
      '🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience',
      name: 'lStatusOrderCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for choosing us`
  String get lStatusOrderQualified {
    return Intl.message(
      'Thank you for choosing us',
      name: 'lStatusOrderQualified',
      desc: '',
      args: [],
    );
  }

  /// `🔎 We are looking for a nearby unit`
  String get lStatusTaxiStarted {
    return Intl.message(
      '🔎 We are looking for a nearby unit',
      name: 'lStatusTaxiStarted',
      desc: '',
      args: [],
    );
  }

  /// `🚖 You have been assigned a cab. 🚕 The cab is heading to your location`
  String get lStatusTaxiAssigned {
    return Intl.message(
      '🚖 You have been assigned a cab. 🚕 The cab is heading to your location',
      name: 'lStatusTaxiAssigned',
      desc: '',
      args: [],
    );
  }

  /// `💚 The driver has reported boarding the vehicle.`
  String get lStatusTaxiTaken {
    return Intl.message(
      '💚 The driver has reported boarding the vehicle.',
      name: 'lStatusTaxiTaken',
      desc: '',
      args: [],
    );
  }

  /// `🥳 Thank you for choosing us. Please rate your experience`
  String get lStatusTaxiDelivered {
    return Intl.message(
      '🥳 Thank you for choosing us. Please rate your experience',
      name: 'lStatusTaxiDelivered',
      desc: '',
      args: [],
    );
  }

  /// `🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience`
  String get lStatusTaxiCancelled {
    return Intl.message(
      '🥺 Oops. Sorry, but the order has been cancelled. Please rate your experience',
      name: 'lStatusTaxiCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Thank you for choosing us`
  String get lStatusTaxiQualified {
    return Intl.message(
      'Thank you for choosing us',
      name: 'lStatusTaxiQualified',
      desc: '',
      args: [],
    );
  }

  /// `Confirm that you have picked up the order`
  String get mDConfirmOrder {
    return Intl.message(
      'Confirm that you have picked up the order',
      name: 'mDConfirmOrder',
      desc: '',
      args: [],
    );
  }

  /// `Cool. We notify that you have picked up the order`
  String get mRConfirmOrde {
    return Intl.message(
      'Cool. We notify that you have picked up the order',
      name: 'mRConfirmOrde',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations, you have successfully registered your store. Now create your products and start selling`
  String get mRStoreCongratulations {
    return Intl.message(
      'Congratulations, you have successfully registered your store. Now create your products and start selling',
      name: 'mRStoreCongratulations',
      desc: '',
      args: [],
    );
  }

  /// `Address removed`
  String get mRAddressRemoved {
    return Intl.message(
      'Address removed',
      name: 'mRAddressRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Changes made correctly`
  String get mRChangesMadeCorrectly {
    return Intl.message(
      'Changes made correctly',
      name: 'mRChangesMadeCorrectly',
      desc: '',
      args: [],
    );
  }

  /// `The recharge of\n\n{amount} {coin} to the number\n\n{phone}\n\nhas been successfully completed`
  String mRTopUpBalance(Object amount, Object coin, Object phone) {
    return Intl.message(
      'The recharge of\n\n$amount $coin to the number\n\n$phone\n\nhas been successfully completed',
      name: 'mRTopUpBalance',
      desc: '',
      args: [amount, coin, phone],
    );
  }

  /// `Please rate the client`
  String get mDFinish {
    return Intl.message(
      'Please rate the client',
      name: 'mDFinish',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to log out?`
  String get mDLogoutSession {
    return Intl.message(
      'Are you sure you want to log out?',
      name: 'mDLogoutSession',
      desc: '',
      args: [],
    );
  }

  /// `This store is closed, you can view their products but you will not be able to make a purchase until the store is open`
  String get mDStoreClosed {
    return Intl.message(
      'This store is closed, you can view their products but you will not be able to make a purchase until the store is open',
      name: 'mDStoreClosed',
      desc: '',
      args: [],
    );
  }

  /// `If you are sure you want to cancel the order, touch on the ({labelCancelButton}) button`
  String mDCancelOrder(Object labelCancelButton) {
    return Intl.message(
      'If you are sure you want to cancel the order, touch on the ($labelCancelButton) button',
      name: 'mDCancelOrder',
      desc: '',
      args: [labelCancelButton],
    );
  }

  /// `Password sent to {email}, if you don't see the email check your SPAM folder`
  String mRecoverAccount(Object email) {
    return Intl.message(
      'Password sent to $email, if you don\'t see the email check your SPAM folder',
      name: 'mRecoverAccount',
      desc: '',
      args: [email],
    );
  }

  /// `Oops, the request has already been fulfilled`
  String get mRorderFulfilled {
    return Intl.message(
      'Oops, the request has already been fulfilled',
      name: 'mRorderFulfilled',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient funds. Please top up your balance`
  String get mRinsufficientBalance {
    return Intl.message(
      'Insufficient funds. Please top up your balance',
      name: 'mRinsufficientBalance',
      desc: '',
      args: [],
    );
  }

  /// `The company {company}, does not ship units to your location. Please select another address on the main screen and select another company`
  String mMaximumDistanceStoreStartingPoint(Object company) {
    return Intl.message(
      'The company $company, does not ship units to your location. Please select another address on the main screen and select another company',
      name: 'mMaximumDistanceStoreStartingPoint',
      desc: '',
      args: [company],
    );
  }

  /// `The minimum distance of the route cannot be less than {distance} meters`
  String mMinimumTravelDistance(Object distance) {
    return Intl.message(
      'The minimum distance of the route cannot be less than $distance meters',
      name: 'mMinimumTravelDistance',
      desc: '',
      args: [distance],
    );
  }

  /// `You have does not pending orders`
  String get emptyTab2 {
    return Intl.message(
      'You have does not pending orders',
      name: 'emptyTab2',
      desc: '',
      args: [],
    );
  }

  /// `Monday`
  String get lMonday {
    return Intl.message('Monday', name: 'lMonday', desc: '', args: []);
  }

  /// `Tuesday`
  String get lTuesday {
    return Intl.message('Tuesday', name: 'lTuesday', desc: '', args: []);
  }

  /// `Wednesday`
  String get lWednesday {
    return Intl.message('Wednesday', name: 'lWednesday', desc: '', args: []);
  }

  /// `Thursday`
  String get lThursday {
    return Intl.message('Thursday', name: 'lThursday', desc: '', args: []);
  }

  /// `Friday`
  String get lFriday {
    return Intl.message('Friday', name: 'lFriday', desc: '', args: []);
  }

  /// `Saturday`
  String get lSaturday {
    return Intl.message('Saturday', name: 'lSaturday', desc: '', args: []);
  }

  /// `Sunday`
  String get lSunday {
    return Intl.message('Sunday', name: 'lSunday', desc: '', args: []);
  }

  /// `Explore`
  String get explore {
    return Intl.message('Explore', name: 'explore', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Deliver to`
  String get deliverTo {
    return Intl.message('Deliver to', name: 'deliverTo', desc: '', args: []);
  }

  /// `What sounds good today?`
  String get homeGreeting {
    return Intl.message(
      'What sounds good today?',
      name: 'homeGreeting',
      desc: '',
      args: [],
    );
  }

  /// `Find something delicious nearby.`
  String get homeSubtitle {
    return Intl.message(
      'Find something delicious nearby.',
      name: 'homeSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Nearby`
  String get nearbyStores {
    return Intl.message('Nearby', name: 'nearbyStores', desc: '', args: []);
  }

  /// `Discover something new`
  String get featuredProducts {
    return Intl.message(
      'Discover something new',
      name: 'featuredProducts',
      desc: '',
      args: [],
    );
  }

  /// `Search for a dish or restaurant`
  String get catalogSearchHint {
    return Intl.message(
      'Search for a dish or restaurant',
      name: 'catalogSearchHint',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get allCategories {
    return Intl.message('All', name: 'allCategories', desc: '', args: []);
  }

  /// `No stores nearby yet`
  String get noStoresTitle {
    return Intl.message(
      'No stores nearby yet',
      name: 'noStoresTitle',
      desc: '',
      args: [],
    );
  }

  /// `Try a different delivery address or check back later.`
  String get noStoresMessage {
    return Intl.message(
      'Try a different delivery address or check back later.',
      name: 'noStoresMessage',
      desc: '',
      args: [],
    );
  }

  /// `No matches found`
  String get noResultsTitle {
    return Intl.message(
      'No matches found',
      name: 'noResultsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Try another search or choose a different category.`
  String get noResultsMessage {
    return Intl.message(
      'Try another search or choose a different category.',
      name: 'noResultsMessage',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't load the stores`
  String get catalogErrorTitle {
    return Intl.message(
      'We couldn\'t load the stores',
      name: 'catalogErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Check your connection and try again.`
  String get catalogErrorMessage {
    return Intl.message(
      'Check your connection and try again.',
      name: 'catalogErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get retry {
    return Intl.message('Try again', name: 'retry', desc: '', args: []);
  }

  /// `Where should we deliver?`
  String get chooseAddressTitle {
    return Intl.message(
      'Where should we deliver?',
      name: 'chooseAddressTitle',
      desc: '',
      args: [],
    );
  }

  /// `Choose an address to see available stores.`
  String get chooseAddressMessage {
    return Intl.message(
      'Choose an address to see available stores.',
      name: 'chooseAddressMessage',
      desc: '',
      args: [],
    );
  }

  /// `Clear search`
  String get clearSearch {
    return Intl.message(
      'Clear search',
      name: 'clearSearch',
      desc: '',
      args: [],
    );
  }

  /// `View cart`
  String get viewCart {
    return Intl.message('View cart', name: 'viewCart', desc: '', args: []);
  }

  /// `Your cart`
  String get cartTitle {
    return Intl.message('Your cart', name: 'cartTitle', desc: '', args: []);
  }

  /// `Your cart is waiting`
  String get cartEmptyTitle {
    return Intl.message(
      'Your cart is waiting',
      name: 'cartEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Explore stores and add your favorite products.`
  String get cartEmptyMessage {
    return Intl.message(
      'Explore stores and add your favorite products.',
      name: 'cartEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Subtotal`
  String get subtotal {
    return Intl.message('Subtotal', name: 'subtotal', desc: '', args: []);
  }

  /// `Delivery is calculated when you review your order.`
  String get shippingAtCheckout {
    return Intl.message(
      'Delivery is calculated when you review your order.',
      name: 'shippingAtCheckout',
      desc: '',
      args: [],
    );
  }

  /// `Review order`
  String get reviewOrder {
    return Intl.message(
      'Review order',
      name: 'reviewOrder',
      desc: '',
      args: [],
    );
  }

  /// `Add to cart`
  String get addToCart {
    return Intl.message('Add to cart', name: 'addToCart', desc: '', args: []);
  }

  /// `Remove from cart`
  String get removeFromCart {
    return Intl.message(
      'Remove from cart',
      name: 'removeFromCart',
      desc: '',
      args: [],
    );
  }

  /// `Increase quantity`
  String get increaseQuantity {
    return Intl.message(
      'Increase quantity',
      name: 'increaseQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Decrease quantity`
  String get decreaseQuantity {
    return Intl.message(
      'Decrease quantity',
      name: 'decreaseQuantity',
      desc: '',
      args: [],
    );
  }

  /// `Remove product`
  String get removeProduct {
    return Intl.message(
      'Remove product',
      name: 'removeProduct',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message('Quantity', name: 'quantity', desc: '', args: []);
  }

  /// `Order #{id}`
  String orderNumber(Object id) {
    return Intl.message(
      'Order #$id',
      name: 'orderNumber',
      desc: '',
      args: [id],
    );
  }

  /// `{count, plural, one{1 product} other{{count} products}}`
  String cartItemCount(num count) {
    return Intl.plural(
      count,
      one: '1 product',
      other: '$count products',
      name: 'cartItemCount',
      desc: '',
      args: [count],
    );
  }

  /// `Your orders will appear here`
  String get ordersEmptyTitle {
    return Intl.message(
      'Your orders will appear here',
      name: 'ordersEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Once you place an order, you can track it here.`
  String get ordersEmptyMessage {
    return Intl.message(
      'Once you place an order, you can track it here.',
      name: 'ordersEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Sign in to view and track your orders.`
  String get ordersGuestMessage {
    return Intl.message(
      'Sign in to view and track your orders.',
      name: 'ordersGuestMessage',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't load your orders`
  String get ordersErrorTitle {
    return Intl.message(
      'We couldn\'t load your orders',
      name: 'ordersErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `Check your connection and try again.`
  String get ordersErrorMessage {
    return Intl.message(
      'Check your connection and try again.',
      name: 'ordersErrorMessage',
      desc: '',
      args: [],
    );
  }

  /// `Ready for your next order`
  String get accountGuestTitle {
    return Intl.message(
      'Ready for your next order',
      name: 'accountGuestTitle',
      desc: '',
      args: [],
    );
  }

  /// `Sign in to save addresses and track orders.`
  String get accountGuestMessage {
    return Intl.message(
      'Sign in to save addresses and track orders.',
      name: 'accountGuestMessage',
      desc: '',
      args: [],
    );
  }

  /// `Edit profile`
  String get editProfile {
    return Intl.message(
      'Edit profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Your preferences`
  String get accountPreferences {
    return Intl.message(
      'Your preferences',
      name: 'accountPreferences',
      desc: '',
      args: [],
    );
  }

  /// `Your business`
  String get accountBusiness {
    return Intl.message(
      'Your business',
      name: 'accountBusiness',
      desc: '',
      args: [],
    );
  }

  /// `Order status`
  String get orderProgress {
    return Intl.message(
      'Order status',
      name: 'orderProgress',
      desc: '',
      args: [],
    );
  }

  /// `Order received`
  String get orderReceived {
    return Intl.message(
      'Order received',
      name: 'orderReceived',
      desc: '',
      args: [],
    );
  }

  /// `Rider assigned`
  String get orderAssigned {
    return Intl.message(
      'Rider assigned',
      name: 'orderAssigned',
      desc: '',
      args: [],
    );
  }

  /// `On the way`
  String get orderOnTheWay {
    return Intl.message(
      'On the way',
      name: 'orderOnTheWay',
      desc: '',
      args: [],
    );
  }

  /// `Delivered`
  String get orderCompleted {
    return Intl.message(
      'Delivered',
      name: 'orderCompleted',
      desc: '',
      args: [],
    );
  }

  /// `The menu is on its way`
  String get storeEmptyTitle {
    return Intl.message(
      'The menu is on its way',
      name: 'storeEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `This store has no products available yet.`
  String get storeEmptyMessage {
    return Intl.message(
      'This store has no products available yet.',
      name: 'storeEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get openStore {
    return Intl.message('Open', name: 'openStore', desc: '', args: []);
  }

  /// `Your kitchen`
  String get kitchenTitle {
    return Intl.message(
      'Your kitchen',
      name: 'kitchenTitle',
      desc: '',
      args: [],
    );
  }

  /// `Every order, at the right time.`
  String get kitchenSubtitle {
    return Intl.message(
      'Every order, at the right time.',
      name: 'kitchenSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Menu`
  String get restaurantMenu {
    return Intl.message('Menu', name: 'restaurantMenu', desc: '', args: []);
  }

  /// `Business`
  String get restaurantBusiness {
    return Intl.message(
      'Business',
      name: 'restaurantBusiness',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get newOrders {
    return Intl.message('New', name: 'newOrders', desc: '', args: []);
  }

  /// `Preparing`
  String get preparingOrders {
    return Intl.message(
      'Preparing',
      name: 'preparingOrders',
      desc: '',
      args: [],
    );
  }

  /// `Ready`
  String get readyOrders {
    return Intl.message('Ready', name: 'readyOrders', desc: '', args: []);
  }

  /// `On delivery`
  String get dispatchedOrders {
    return Intl.message(
      'On delivery',
      name: 'dispatchedOrders',
      desc: '',
      args: [],
    );
  }

  /// `Accept and prepare`
  String get acceptOrder {
    return Intl.message(
      'Accept and prepare',
      name: 'acceptOrder',
      desc: '',
      args: [],
    );
  }

  /// `Mark ready for pickup`
  String get markReady {
    return Intl.message(
      'Mark ready for pickup',
      name: 'markReady',
      desc: '',
      args: [],
    );
  }

  /// `Preparation time`
  String get preparationTime {
    return Intl.message(
      'Preparation time',
      name: 'preparationTime',
      desc: '',
      args: [],
    );
  }

  /// `{minutes} min`
  String preparationMinutesLabel(Object minutes) {
    return Intl.message(
      '$minutes min',
      name: 'preparationMinutesLabel',
      desc: '',
      args: [minutes],
    );
  }

  /// `All caught up`
  String get kitchenEmptyTitle {
    return Intl.message(
      'All caught up',
      name: 'kitchenEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Orders at this stage will appear here.`
  String get kitchenEmptyMessage {
    return Intl.message(
      'Orders at this stage will appear here.',
      name: 'kitchenEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't load the orders`
  String get kitchenErrorTitle {
    return Intl.message(
      'We couldn\'t load the orders',
      name: 'kitchenErrorTitle',
      desc: '',
      args: [],
    );
  }

  /// `The order changed. Check its updated status.`
  String get kitchenConflict {
    return Intl.message(
      'The order changed. Check its updated status.',
      name: 'kitchenConflict',
      desc: '',
      args: [],
    );
  }

  /// `We couldn't save the change. Please try again.`
  String get kitchenActionError {
    return Intl.message(
      'We couldn\'t save the change. Please try again.',
      name: 'kitchenActionError',
      desc: '',
      args: [],
    );
  }

  /// `Order accepted. You can start preparing it.`
  String get orderAccepted {
    return Intl.message(
      'Order accepted. You can start preparing it.',
      name: 'orderAccepted',
      desc: '',
      args: [],
    );
  }

  /// `Order ready for the rider to pick up.`
  String get orderReady {
    return Intl.message(
      'Order ready for the rider to pick up.',
      name: 'orderReady',
      desc: '',
      args: [],
    );
  }

  /// `No kitchen status recorded`
  String get legacyKitchen {
    return Intl.message(
      'No kitchen status recorded',
      name: 'legacyKitchen',
      desc: '',
      args: [],
    );
  }

  /// `View details`
  String get orderDetails {
    return Intl.message(
      'View details',
      name: 'orderDetails',
      desc: '',
      args: [],
    );
  }

  /// `Order history`
  String get openHistory {
    return Intl.message(
      'Order history',
      name: 'openHistory',
      desc: '',
      args: [],
    );
  }

  /// `Back to active orders`
  String get viewActiveOrders {
    return Intl.message(
      'Back to active orders',
      name: 'viewActiveOrders',
      desc: '',
      args: [],
    );
  }

  /// `Select your store`
  String get chooseStore {
    return Intl.message(
      'Select your store',
      name: 'chooseStore',
      desc: '',
      args: [],
    );
  }

  /// `No stores assigned yet`
  String get managerStoresEmpty {
    return Intl.message(
      'No stores assigned yet',
      name: 'managerStoresEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Stores linked to your account will appear here.`
  String get managerStoresEmptyMessage {
    return Intl.message(
      'Stores linked to your account will appear here.',
      name: 'managerStoresEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Your menu starts here`
  String get menuEmptyTitle {
    return Intl.message(
      'Your menu starts here',
      name: 'menuEmptyTitle',
      desc: '',
      args: [],
    );
  }

  /// `Add your first product with a name, description and price.`
  String get menuEmptyMessage {
    return Intl.message(
      'Add your first product with a name, description and price.',
      name: 'menuEmptyMessage',
      desc: '',
      args: [],
    );
  }

  /// `Business hours`
  String get manageHours {
    return Intl.message(
      'Business hours',
      name: 'manageHours',
      desc: '',
      args: [],
    );
  }

  /// `Store details`
  String get businessDetails {
    return Intl.message(
      'Store details',
      name: 'businessDetails',
      desc: '',
      args: [],
    );
  }

  /// `Manage your business's products.`
  String get menuDescription {
    return Intl.message(
      'Manage your business\'s products.',
      name: 'menuDescription',
      desc: '',
      args: [],
    );
  }

  /// `Optional photo`
  String get photoOptional {
    return Intl.message(
      'Optional photo',
      name: 'photoOptional',
      desc: '',
      args: [],
    );
  }

  /// `Product name`
  String get productNameLabel {
    return Intl.message(
      'Product name',
      name: 'productNameLabel',
      desc: '',
      args: [],
    );
  }

  /// `Description`
  String get productDescriptionLabel {
    return Intl.message(
      'Description',
      name: 'productDescriptionLabel',
      desc: '',
      args: [],
    );
  }

  /// `Price (USD)`
  String get productPriceLabel {
    return Intl.message(
      'Price (USD)',
      name: 'productPriceLabel',
      desc: '',
      args: [],
    );
  }

  /// `Save product`
  String get saveProduct {
    return Intl.message(
      'Save product',
      name: 'saveProduct',
      desc: '',
      args: [],
    );
  }

  /// `Edit product`
  String get editProduct {
    return Intl.message(
      'Edit product',
      name: 'editProduct',
      desc: '',
      args: [],
    );
  }

  /// `Enter a name with at least 4 characters.`
  String get productNameError {
    return Intl.message(
      'Enter a name with at least 4 characters.',
      name: 'productNameError',
      desc: '',
      args: [],
    );
  }

  /// `Describe the product with at least 10 characters.`
  String get productDescriptionError {
    return Intl.message(
      'Describe the product with at least 10 characters.',
      name: 'productDescriptionError',
      desc: '',
      args: [],
    );
  }

  /// `Enter a price greater than zero.`
  String get productPriceError {
    return Intl.message(
      'Enter a price greater than zero.',
      name: 'productPriceError',
      desc: '',
      args: [],
    );
  }

  /// `Customer instructions`
  String get customerNotes {
    return Intl.message(
      'Customer instructions',
      name: 'customerNotes',
      desc: '',
      args: [],
    );
  }

  /// `This store has no business hours yet.`
  String get hoursEmpty {
    return Intl.message(
      'This store has no business hours yet.',
      name: 'hoursEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Schedule updated.`
  String get scheduleUpdated {
    return Intl.message(
      'Schedule updated.',
      name: 'scheduleUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Change opening time`
  String get editOpening {
    return Intl.message(
      'Change opening time',
      name: 'editOpening',
      desc: '',
      args: [],
    );
  }

  /// `Change closing time`
  String get editClosing {
    return Intl.message(
      'Change closing time',
      name: 'editClosing',
      desc: '',
      args: [],
    );
  }

  /// `Wait for the restaurant to mark the order ready.`
  String get waitingForKitchen {
    return Intl.message(
      'Wait for the restaurant to mark the order ready.',
      name: 'waitingForKitchen',
      desc: '',
      args: [],
    );
  }

  /// `The restaurant is about to accept your order.`
  String get kitchenPendingClient {
    return Intl.message(
      'The restaurant is about to accept your order.',
      name: 'kitchenPendingClient',
      desc: '',
      args: [],
    );
  }

  /// `The restaurant is preparing your order.`
  String get kitchenPreparingClient {
    return Intl.message(
      'The restaurant is preparing your order.',
      name: 'kitchenPreparingClient',
      desc: '',
      args: [],
    );
  }

  /// `Your order is ready for pickup.`
  String get kitchenReadyClient {
    return Intl.message(
      'Your order is ready for pickup.',
      name: 'kitchenReadyClient',
      desc: '',
      args: [],
    );
  }

  /// `View location`
  String get viewLocation {
    return Intl.message(
      'View location',
      name: 'viewLocation',
      desc: '',
      args: [],
    );
  }

  /// `Estimated preparation: {minutes} min`
  String kitchenPrepEstimate(Object minutes) {
    return Intl.message(
      'Estimated preparation: $minutes min',
      name: 'kitchenPrepEstimate',
      desc: '',
      args: [minutes],
    );
  }

  /// `Deliveries`
  String get courierDeliveries {
    return Intl.message(
      'Deliveries',
      name: 'courierDeliveries',
      desc: '',
      args: [],
    );
  }

  /// `Earnings`
  String get courierEarnings {
    return Intl.message(
      'Earnings',
      name: 'courierEarnings',
      desc: '',
      args: [],
    );
  }

  /// `Account`
  String get courierAccount {
    return Intl.message('Account', name: 'courierAccount', desc: '', args: []);
  }

  /// `Available`
  String get courierOnline {
    return Intl.message('Available', name: 'courierOnline', desc: '', args: []);
  }

  /// `Unavailable`
  String get courierOffline {
    return Intl.message(
      'Unavailable',
      name: 'courierOffline',
      desc: '',
      args: [],
    );
  }

  /// `You will receive new delivery offers.`
  String get courierOnlineHint {
    return Intl.message(
      'You will receive new delivery offers.',
      name: 'courierOnlineHint',
      desc: '',
      args: [],
    );
  }

  /// `Go available to see new offers.`
  String get courierOfflineHint {
    return Intl.message(
      'Go available to see new offers.',
      name: 'courierOfflineHint',
      desc: '',
      args: [],
    );
  }

  /// `No new offers. Continue your active deliveries.`
  String get courierOfflineActive {
    return Intl.message(
      'No new offers. Continue your active deliveries.',
      name: 'courierOfflineActive',
      desc: '',
      args: [],
    );
  }

  /// `In progress`
  String get courierActive {
    return Intl.message(
      'In progress',
      name: 'courierActive',
      desc: '',
      args: [],
    );
  }

  /// `Available deliveries`
  String get courierOffers {
    return Intl.message(
      'Available deliveries',
      name: 'courierOffers',
      desc: '',
      args: [],
    );
  }

  /// `All caught up`
  String get courierEmpty {
    return Intl.message(
      'All caught up',
      name: 'courierEmpty',
      desc: '',
      args: [],
    );
  }

  /// `New deliveries will appear here. You can refresh the list.`
  String get courierEmptyHint {
    return Intl.message(
      'New deliveries will appear here. You can refresh the list.',
      name: 'courierEmptyHint',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get courierRefresh {
    return Intl.message('Refresh', name: 'courierRefresh', desc: '', args: []);
  }

  /// `Pickup`
  String get courierPickup {
    return Intl.message('Pickup', name: 'courierPickup', desc: '', args: []);
  }

  /// `Drop-off`
  String get courierDropoff {
    return Intl.message('Drop-off', name: 'courierDropoff', desc: '', args: []);
  }

  /// `Your earnings`
  String get courierGain {
    return Intl.message(
      'Your earnings',
      name: 'courierGain',
      desc: '',
      args: [],
    );
  }

  /// `Approximate straight-line distances. Open the map for directions.`
  String get courierApprox {
    return Intl.message(
      'Approximate straight-line distances. Open the map for directions.',
      name: 'courierApprox',
      desc: '',
      args: [],
    );
  }

  /// `Cash`
  String get courierCash {
    return Intl.message('Cash', name: 'courierCash', desc: '', args: []);
  }

  /// `Paid in app`
  String get courierPaid {
    return Intl.message('Paid in app', name: 'courierPaid', desc: '', args: []);
  }

  /// `Unavailable`
  String get courierUnknown {
    return Intl.message(
      'Unavailable',
      name: 'courierUnknown',
      desc: '',
      args: [],
    );
  }

  /// `Accept delivery`
  String get courierAccept {
    return Intl.message(
      'Accept delivery',
      name: 'courierAccept',
      desc: '',
      args: [],
    );
  }

  /// `Confirm pickup`
  String get courierCollect {
    return Intl.message(
      'Confirm pickup',
      name: 'courierCollect',
      desc: '',
      args: [],
    );
  }

  /// `Confirm delivery`
  String get courierDeliver {
    return Intl.message(
      'Confirm delivery',
      name: 'courierDeliver',
      desc: '',
      args: [],
    );
  }

  /// `The restaurant is preparing the order.`
  String get courierPreparing {
    return Intl.message(
      'The restaurant is preparing the order.',
      name: 'courierPreparing',
      desc: '',
      args: [],
    );
  }

  /// `Ready for pickup`
  String get courierReady {
    return Intl.message(
      'Ready for pickup',
      name: 'courierReady',
      desc: '',
      args: [],
    );
  }

  /// `Go to the restaurant`
  String get courierHeading {
    return Intl.message(
      'Go to the restaurant',
      name: 'courierHeading',
      desc: '',
      args: [],
    );
  }

  /// `On the way to the customer`
  String get courierOnWay {
    return Intl.message(
      'On the way to the customer',
      name: 'courierOnWay',
      desc: '',
      args: [],
    );
  }

  /// `Delivery completed`
  String get courierDone {
    return Intl.message(
      'Delivery completed',
      name: 'courierDone',
      desc: '',
      args: [],
    );
  }

  /// `Order cancelled`
  String get courierCancelled {
    return Intl.message(
      'Order cancelled',
      name: 'courierCancelled',
      desc: '',
      args: [],
    );
  }

  /// `Did you complete the delivery?`
  String get courierConfirmTitle {
    return Intl.message(
      'Did you complete the delivery?',
      name: 'courierConfirmTitle',
      desc: '',
      args: [],
    );
  }

  /// `Confirm you handed over the order and collected the full amount from the customer.`
  String get courierConfirmCash {
    return Intl.message(
      'Confirm you handed over the order and collected the full amount from the customer.',
      name: 'courierConfirmCash',
      desc: '',
      args: [],
    );
  }

  /// `Confirm you handed over the order to the customer. The order is already paid.`
  String get courierConfirmPaid {
    return Intl.message(
      'Confirm you handed over the order to the customer. The order is already paid.',
      name: 'courierConfirmPaid',
      desc: '',
      args: [],
    );
  }

  /// `Cancel order`
  String get courierCancel {
    return Intl.message(
      'Cancel order',
      name: 'courierCancel',
      desc: '',
      args: [],
    );
  }

  /// `This cancels the customer's order and reverses the corresponding balances. It does not reassign the courier.`
  String get courierCancelMessage {
    return Intl.message(
      'This cancels the customer\'s order and reverses the corresponding balances. It does not reassign the courier.',
      name: 'courierCancelMessage',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get courierBack {
    return Intl.message('Back', name: 'courierBack', desc: '', args: []);
  }

  /// `Order total`
  String get courierTotal {
    return Intl.message(
      'Order total',
      name: 'courierTotal',
      desc: '',
      args: [],
    );
  }

  /// `Order`
  String get courierProducts {
    return Intl.message('Order', name: 'courierProducts', desc: '', args: []);
  }

  /// `Open directions`
  String get courierRoute {
    return Intl.message(
      'Open directions',
      name: 'courierRoute',
      desc: '',
      args: [],
    );
  }

  /// `Call`
  String get courierCall {
    return Intl.message('Call', name: 'courierCall', desc: '', args: []);
  }

  /// `Chat`
  String get courierChat {
    return Intl.message('Chat', name: 'courierChat', desc: '', args: []);
  }

  /// `Daily earnings`
  String get courierDayGain {
    return Intl.message(
      'Daily earnings',
      name: 'courierDayGain',
      desc: '',
      args: [],
    );
  }

  /// `Completed deliveries`
  String get courierCompleted {
    return Intl.message(
      'Completed deliveries',
      name: 'courierCompleted',
      desc: '',
      args: [],
    );
  }

  /// `Balance for accepting deliveries`
  String get courierCredit {
    return Intl.message(
      'Balance for accepting deliveries',
      name: 'courierCredit',
      desc: '',
      args: [],
    );
  }

  /// `Covers the commission on cash orders.`
  String get courierCreditHint {
    return Intl.message(
      'Covers the commission on cash orders.',
      name: 'courierCreditHint',
      desc: '',
      args: [],
    );
  }

  /// `Recorded settlement`
  String get courierSettlement {
    return Intl.message(
      'Recorded settlement',
      name: 'courierSettlement',
      desc: '',
      args: [],
    );
  }

  /// `Amount recorded by the system; it does not represent a bank transfer.`
  String get courierSettlementHint {
    return Intl.message(
      'Amount recorded by the system; it does not represent a bank transfer.',
      name: 'courierSettlementHint',
      desc: '',
      args: [],
    );
  }

  /// `Delivery day uses Ecuador time. Older orders without a delivery timestamp are available in history.`
  String get courierIncomeHint {
    return Intl.message(
      'Delivery day uses Ecuador time. Older orders without a delivery timestamp are available in history.',
      name: 'courierIncomeHint',
      desc: '',
      args: [],
    );
  }

  /// `Some deliveries have no recorded earnings and are excluded from the amount.`
  String get courierUnpriced {
    return Intl.message(
      'Some deliveries have no recorded earnings and are excluded from the amount.',
      name: 'courierUnpriced',
      desc: '',
      args: [],
    );
  }

  /// `View order history`
  String get courierHistory {
    return Intl.message(
      'View order history',
      name: 'courierHistory',
      desc: '',
      args: [],
    );
  }

  /// `No completed deliveries on this day.`
  String get courierIncomeEmpty {
    return Intl.message(
      'No completed deliveries on this day.',
      name: 'courierIncomeEmpty',
      desc: '',
      args: [],
    );
  }

  /// `Enable location and grant permission to receive deliveries.`
  String get courierGpsError {
    return Intl.message(
      'Enable location and grant permission to receive deliveries.',
      name: 'courierGpsError',
      desc: '',
      args: [],
    );
  }

  /// `Your operating balance is insufficient for this delivery.`
  String get courierBalanceError {
    return Intl.message(
      'Your operating balance is insufficient for this delivery.',
      name: 'courierBalanceError',
      desc: '',
      args: [],
    );
  }

  /// `This order changed or is no longer available. Refresh to see its status.`
  String get courierChangedError {
    return Intl.message(
      'This order changed or is no longer available. Refresh to see its status.',
      name: 'courierChangedError',
      desc: '',
      args: [],
    );
  }

  /// `The operation could not be confirmed. Check your connection and try again.`
  String get courierNetworkError {
    return Intl.message(
      'The operation could not be confirmed. Check your connection and try again.',
      name: 'courierNetworkError',
      desc: '',
      args: [],
    );
  }

  /// `Your session is unavailable. Please sign in again.`
  String get courierSessionError {
    return Intl.message(
      'Your session is unavailable. Please sign in again.',
      name: 'courierSessionError',
      desc: '',
      args: [],
    );
  }

  /// `Courier`
  String get courierLabel {
    return Intl.message('Courier', name: 'courierLabel', desc: '', args: []);
  }

  /// `Today`
  String get courierToday {
    return Intl.message('Today', name: 'courierToday', desc: '', args: []);
  }

  /// `Show password`
  String get showPassword {
    return Intl.message(
      'Show password',
      name: 'showPassword',
      desc: '',
      args: [],
    );
  }

  /// `Hide password`
  String get hidePassword {
    return Intl.message(
      'Hide password',
      name: 'hidePassword',
      desc: '',
      args: [],
    );
  }

  /// `Wallet balance`
  String get walletBalance {
    return Intl.message(
      'Wallet balance',
      name: 'walletBalance',
      desc: '',
      args: [],
    );
  }

  /// `This balance is applied when you pay with your wallet.`
  String get walletBalanceHint {
    return Intl.message(
      'This balance is applied when you pay with your wallet.',
      name: 'walletBalanceHint',
      desc: '',
      args: [],
    );
  }

  /// `Edit image`
  String get editImage {
    return Intl.message('Edit image', name: 'editImage', desc: '', args: []);
  }

  /// `Sign out`
  String get signOut {
    return Intl.message('Sign out', name: 'signOut', desc: '', args: []);
  }

  /// `Select an option`
  String get selectOption {
    return Intl.message(
      'Select an option',
      name: 'selectOption',
      desc: '',
      args: [],
    );
  }

  /// `Your favorite food,\ncloser to you.`
  String get authWelcome {
    return Intl.message(
      'Your favorite food,\ncloser to you.',
      name: 'authWelcome',
      desc: '',
      args: [],
    );
  }

  /// `Sign in and find something delicious for today.`
  String get authWelcomeMessage {
    return Intl.message(
      'Sign in and find something delicious for today.',
      name: 'authWelcomeMessage',
      desc: '',
      args: [],
    );
  }

  /// `A great order\nstarts here.`
  String get authCreateTitle {
    return Intl.message(
      'A great order\nstarts here.',
      name: 'authCreateTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create your account and discover the flavors of your city.`
  String get authCreateMessage {
    return Intl.message(
      'Create your account and discover the flavors of your city.',
      name: 'authCreateMessage',
      desc: '',
      args: [],
    );
  }

  /// `Matching dishes`
  String get matchingDishes {
    return Intl.message(
      'Matching dishes',
      name: 'matchingDishes',
      desc: '',
      args: [],
    );
  }

  /// `Related restaurants`
  String get matchingRestaurants {
    return Intl.message(
      'Related restaurants',
      name: 'matchingRestaurants',
      desc: '',
      args: [],
    );
  }

  /// `Your restaurants,\nat your door.`
  String get welcomeTitle {
    return Intl.message(
      'Your restaurants,\nat your door.',
      name: 'welcomeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Explore restaurants and menus, order your favorite dishes and get them delivered to the address you choose.`
  String get welcomeDescription {
    return Intl.message(
      'Explore restaurants and menus, order your favorite dishes and get them delivered to the address you choose.',
      name: 'welcomeDescription',
      desc: '',
      args: [],
    );
  }

  /// `Find your next meal`
  String get welcomeDiscover {
    return Intl.message(
      'Find your next meal',
      name: 'welcomeDiscover',
      desc: '',
      args: [],
    );
  }

  /// `Explore your options and discover new flavors.`
  String get welcomeDiscoverMessage {
    return Intl.message(
      'Explore your options and discover new flavors.',
      name: 'welcomeDiscoverMessage',
      desc: '',
      args: [],
    );
  }

  /// `Order to your address`
  String get welcomeDelivery {
    return Intl.message(
      'Order to your address',
      name: 'welcomeDelivery',
      desc: '',
      args: [],
    );
  }

  /// `Choose your dishes and confirm your delivery.`
  String get welcomeDeliveryMessage {
    return Intl.message(
      'Choose your dishes and confirm your delivery.',
      name: 'welcomeDeliveryMessage',
      desc: '',
      args: [],
    );
  }

  /// `Follow your order`
  String get welcomeTracking {
    return Intl.message(
      'Follow your order',
      name: 'welcomeTracking',
      desc: '',
      args: [],
    );
  }

  /// `From preparation until it reaches you.`
  String get welcomeTrackingMessage {
    return Intl.message(
      'From preparation until it reaches you.',
      name: 'welcomeTrackingMessage',
      desc: '',
      args: [],
    );
  }

  /// `Choose an address and explore`
  String get welcomeExplore {
    return Intl.message(
      'Choose an address and explore',
      name: 'welcomeExplore',
      desc: '',
      args: [],
    );
  }

  /// `Sign in or create an account`
  String get welcomeAccess {
    return Intl.message(
      'Sign in or create an account',
      name: 'welcomeAccess',
      desc: '',
      args: [],
    );
  }

  /// `Privacy`
  String get privacyPolicy {
    return Intl.message('Privacy', name: 'privacyPolicy', desc: '', args: []);
  }

  /// `Terms of use`
  String get termsOfService {
    return Intl.message(
      'Terms of use',
      name: 'termsOfService',
      desc: '',
      args: [],
    );
  }

  /// `The map is unavailable for now. You can follow your order status here.`
  String get trackingMapUnavailable {
    return Intl.message(
      'The map is unavailable for now. You can follow your order status here.',
      name: 'trackingMapUnavailable',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for the courier's location`
  String get trackingWaitingLocation {
    return Intl.message(
      'Waiting for the courier\'s location',
      name: 'trackingWaitingLocation',
      desc: '',
      args: [],
    );
  }

  /// `Courier location received`
  String get trackingLocationUpdated {
    return Intl.message(
      'Courier location received',
      name: 'trackingLocationUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Dish details`
  String get dishDetails {
    return Intl.message(
      'Dish details',
      name: 'dishDetails',
      desc: '',
      args: [],
    );
  }

  /// `Restaurant information`
  String get restaurantInformation {
    return Intl.message(
      'Restaurant information',
      name: 'restaurantInformation',
      desc: '',
      args: [],
    );
  }

  /// `Search this menu`
  String get searchMenu {
    return Intl.message(
      'Search this menu',
      name: 'searchMenu',
      desc: '',
      args: [],
    );
  }

  /// `Full menu`
  String get fullMenu {
    return Intl.message('Full menu', name: 'fullMenu', desc: '', args: []);
  }

  /// `Up to {amount}`
  String menuUpTo(Object amount) {
    return Intl.message(
      'Up to $amount',
      name: 'menuUpTo',
      desc: '',
      args: [amount],
    );
  }

  /// `Over {amount}`
  String menuAbove(Object amount) {
    return Intl.message(
      'Over $amount',
      name: 'menuAbove',
      desc: '',
      args: [amount],
    );
  }

  /// `1 option`
  String get menuSingleItem {
    return Intl.message('1 option', name: 'menuSingleItem', desc: '', args: []);
  }

  /// `{count} options`
  String menuItems(Object count) {
    return Intl.message(
      '$count options',
      name: 'menuItems',
      desc: '',
      args: [count],
    );
  }

  /// `Complete your payment`
  String get paymentCheckoutTitle {
    return Intl.message(
      'Complete your payment',
      name: 'paymentCheckoutTitle',
      desc: '',
      args: [],
    );
  }

  /// `Pay with your card or PayPhone in your browser. When finished, return here to continue your order.`
  String get paymentCheckoutHelp {
    return Intl.message(
      'Pay with your card or PayPhone in your browser. When finished, return here to continue your order.',
      name: 'paymentCheckoutHelp',
      desc: '',
      args: [],
    );
  }

  /// `Open PayPhone`
  String get paymentOpenBrowser {
    return Intl.message(
      'Open PayPhone',
      name: 'paymentOpenBrowser',
      desc: '',
      args: [],
    );
  }

  /// `I paid, check status`
  String get paymentCheckStatus {
    return Intl.message(
      'I paid, check status',
      name: 'paymentCheckStatus',
      desc: '',
      args: [],
    );
  }

  /// `Back to cart`
  String get paymentBackToCart {
    return Intl.message(
      'Back to cart',
      name: 'paymentBackToCart',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for PayPhone confirmation.`
  String get paymentPending {
    return Intl.message(
      'Waiting for PayPhone confirmation.',
      name: 'paymentPending',
      desc: '',
      args: [],
    );
  }

  /// `If you have paid, we will check your balance before continuing. You can resume the payment from your cart.`
  String get paymentResumeHelp {
    return Intl.message(
      'If you have paid, we will check your balance before continuing. You can resume the payment from your cart.',
      name: 'paymentResumeHelp',
      desc: '',
      args: [],
    );
  }

  /// `PayPhone did not approve this payment. No balance was added. Return to your cart to try again.`
  String get paymentDeclined {
    return Intl.message(
      'PayPhone did not approve this payment. No balance was added. Return to your cart to try again.',
      name: 'paymentDeclined',
      desc: '',
      args: [],
    );
  }

  /// `We could not check your payment. Check your connection and try again.`
  String get paymentConnectionError {
    return Intl.message(
      'We could not check your payment. Check your connection and try again.',
      name: 'paymentConnectionError',
      desc: '',
      args: [],
    );
  }

  /// `We could not open the payment. Return to your cart to try again.`
  String get paymentBrowserError {
    return Intl.message(
      'We could not open the payment. Return to your cart to try again.',
      name: 'paymentBrowserError',
      desc: '',
      args: [],
    );
  }

  /// `Available balance`
  String get paymentWallet {
    return Intl.message(
      'Available balance',
      name: 'paymentWallet',
      desc: '',
      args: [],
    );
  }

  /// `Card or PayPhone / balance`
  String get paymentPayphone {
    return Intl.message(
      'Card or PayPhone / balance',
      name: 'paymentPayphone',
      desc: '',
      args: [],
    );
  }

  /// `Electronic payment is currently unavailable. Choose cash or use your available balance.`
  String get paymentUnavailable {
    return Intl.message(
      'Electronic payment is currently unavailable. Choose cash or use your available balance.',
      name: 'paymentUnavailable',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
