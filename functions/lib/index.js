"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onExecutionFinalized = exports.onOrderAssigned = void 0;
const admin = require("firebase-admin");
admin.initializeApp();
var onOrderAssigned_1 = require("./notifications/onOrderAssigned");
Object.defineProperty(exports, "onOrderAssigned", { enumerable: true, get: function () { return onOrderAssigned_1.onOrderAssigned; } });
var onExecutionFinalized_1 = require("./notifications/onExecutionFinalized");
Object.defineProperty(exports, "onExecutionFinalized", { enumerable: true, get: function () { return onExecutionFinalized_1.onExecutionFinalized; } });
//# sourceMappingURL=index.js.map