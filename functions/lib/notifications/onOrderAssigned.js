"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onOrderAssigned = void 0;
const firestore_1 = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");
exports.onOrderAssigned = (0, firestore_1.onDocumentUpdated)("companies/{companyId}/serviceOrders/{orderId}", async (event) => {
    const newData = event.data?.after.data();
    const previousData = event.data?.before.data();
    if (!newData || !previousData)
        return;
    const newTechId = newData.tecnicoId;
    const oldTechId = previousData.tecnicoId;
    // Trigger only if technician changed and is not null
    if (newTechId && newTechId !== oldTechId) {
        const db = admin.firestore();
        // 1. Get Technician's FCM Token
        const userDoc = await db.collection("users").doc(newTechId).get();
        const fcmToken = userDoc.data()?.fcmToken;
        if (!fcmToken) {
            console.log(`No FCM token for technician ${newTechId}`);
            return;
        }
        // 2. Prepare Notification
        const title = "Nova OS Atribuída";
        const body = `Você é o responsável pela OS ${event.params.orderId.substring(0, 6).toUpperCase()}`;
        const message = {
            notification: { title, body },
            token: fcmToken,
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                orderId: event.params.orderId,
                companyId: event.params.companyId,
            },
        };
        // 3. Send via FCM
        try {
            await admin.messaging().send(message);
            // 4. Save to user's notifications collection
            await db.collection("notifications").add({
                userId: newTechId,
                title,
                body,
                read: false,
                createdAt: admin.firestore.FieldValue.serverTimestamp(),
                type: "ORDER_ASSIGNED",
                relatedId: event.params.orderId,
            });
        }
        catch (error) {
            console.error("Error sending notification:", error);
        }
    }
});
//# sourceMappingURL=onOrderAssigned.js.map