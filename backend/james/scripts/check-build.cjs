const { accessSync, copyFileSync } = require('node:fs');
const { resolve } = require('node:path');

// Catch empty incremental builds and incompatible runtime imports without starting services.
accessSync(resolve(__dirname, '../dist/main.js'));
require('../dist/auth/auth.controller.js');
require('../dist/client/market/market.controller.js');

// Keep the shared notices with standalone distributions of the compiled API.
copyFileSync(
  resolve(__dirname, '../../../THIRD_PARTY_NOTICES.txt'),
  resolve(__dirname, '../dist/THIRD_PARTY_NOTICES.txt'),
);
