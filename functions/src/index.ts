import * as admin from "firebase-admin";

admin.initializeApp();

export { onOrderAssigned } from "./notifications/onOrderAssigned";
export { onExecutionFinalized } from "./notifications/onExecutionFinalized";
