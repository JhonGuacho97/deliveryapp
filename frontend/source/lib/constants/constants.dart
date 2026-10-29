import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF35695A);
const kSecondaryColor = Color(0xFF49675B);

const kContentColorLightTheme = Color(0xFF202A25);
const kContentColorDarkTheme = Color(0xFFEBF1ED);

const kWarninngColor = Color(0xFF816123);
const kErrorColor = Color(0xFFB34343);
const kDefaultPadding = 20.0;

const kVersionn = '2.50.501';
const kNameApp = 'Delivery App';

const kImageDeliveryManDefault = '';
const kImageClientDefault = '';

const kImageCategoryAll = '';

const kSokect = String.fromEnvironment(
  'SOCKET_URL',
  defaultValue: 'http://10.0.2.2:3000',
);
const kDomain = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000/api/',
);
const kExternalServicesEnabled = bool.fromEnvironment(
  'EXTERNAL_SERVICES_ENABLED',
  defaultValue: false,
);
// Order tracking maps can run without Firebase, Google Sign-In or Stripe.
const kOrderMapEnabled = bool.fromEnvironment(
  'ORDER_MAP_ENABLED',
  defaultValue: kExternalServicesEnabled,
);
const kPrivacyUrl = String.fromEnvironment('APP_PRIVACY_URL');
const kTermsUrl = String.fromEnvironment('APP_TERMS_URL');

const kCountryCode = 'EC';
const kCoin = 'USD';
const kCoinDecimals = 2;

//minimum purchase amount with card
const kMinPurchaseAmountCard = 1;
const kStripePublishableKey = String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');
const kStripeEnabled = bool.fromEnvironment(
  'STRIPE_ENABLED',
  defaultValue: false,
);

const klatitudeMap = -4.0236715;
const klongitudeMap = -79.1978733;

const kTargetWidthUser = 220;
const kTargetWidthStore = 470;
const kTargetWidthProduct = 440;

const kMaximumDistanceStoreStartingPoint = 11111;
const kMinimumTravelDistance = 300;
