import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF35695A);
const kSecondaryColor = Color(0xFF49675B);

const kContentColorLightTheme = Color(0xFF202A25);
const kContentColorDarkTheme = Color(0xFFEBF1ED);

const kWarninngColor = Color(0xFF816123);
const kErrorColor = Color(0xFFB34343);
const kDefaultPadding = 20.0;

const kVersionn = '2.50.501';
const kNameApp = 'Lili';

const kImageDeliveryManDefault =
    'https://firebasestorage.googleapis.com/v0/b/resources-a24a1.appspot.com/o/category%2F113.png?alt=media';
const kImageClientDefault =
    'https://firebasestorage.googleapis.com/v0/b/resources-a24a1.appspot.com/o/category%2F113.png?alt=media';

const kImageCategoryAll =
    'https://firebasestorage.googleapis.com/v0/b/resources-a24a1.appspot.com/o/category%2F113.png?alt=media';

const kSokect = String.fromEnvironment(
  'SOCKET_URL',
  defaultValue: 'https://api-lili.planck.biz',
);
const kDomain = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://api-lili.planck.biz/api/',
);
const kExternalServicesEnabled = bool.fromEnvironment(
  'EXTERNAL_SERVICES_ENABLED',
  defaultValue: true,
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
const kStripePublishableKey = 'pk_test_uM6MQGwNS1zFSEwGkdwOOjUd00Q6ikG9Ih';

const klatitudeMap = -4.0236715;
const klongitudeMap = -79.1978733;

const kTargetWidthUser = 220;
const kTargetWidthStore = 470;
const kTargetWidthProduct = 440;

const kMaximumDistanceStoreStartingPoint = 11111;
const kMinimumTravelDistance = 300;
