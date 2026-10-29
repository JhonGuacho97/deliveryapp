const { accessSync } = require('node:fs');
const { resolve } = require('node:path');

// Catch empty incremental builds and incompatible runtime imports without starting services.
accessSync(resolve(__dirname, '../dist/main.js'));
require('../dist/auth/auth.controller.js');
require('../dist/client/market/market.controller.js');
