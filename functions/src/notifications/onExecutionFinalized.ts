import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import * as admin from "firebase-admin";

export const onExecutionFinalized = onDocumentUpdated(
    "companies/{companyId}/serviceOrders/{orderId}/executions/{execId}",
    async (event) => {
        const newData = event.data?.after.data();
        const previousData = event.data?.before.data();

        if (!newData || !previousData) return;

        // Trigger only if status changed to COMPLETED
        if (newData.status === "COMPLETED" && previousData.status !== "COMPLETED") {
            const db = admin.firestore();
            const companyId = event.params.companyId;

            // 1. Find Company Manager (assuming ownerId or searching users by companyId + role)
            const usersSnap = await db.collection("users")
                .where("companyId", "==", companyId)
                .where("role", "==", "ADMIN")
                .limit(5)
                .get();

            if (usersSnap.empty) {
                console.log(`No managers found for company ${companyId}`);
                return;
            }

            const techName = newData.technicianName || "Um técnico";
            const title = "OS Finalizada";
            const body = `A OS ${event.params.orderId.substring(0, 6).toUpperCase()} foi concluída por ${techName}`;

            // 2. Notify all found managers
            const notifications = usersSnap.docs.map(async (doc) => {
                const managerData = doc.data();
                const fcmToken = managerData.fcmToken;

                if (fcmToken) {
                    const message = {
                        notification: { title, body },
                        token: fcmToken,
                        data: {
                            click_action: "FLUTTER_NOTIFICATION_CLICK",
                            orderId: event.params.orderId,
                            executionId: event.params.execId,
                        },
                    };

                    try {
                        await admin.messaging().send(message);
                    } catch (e) {
                        console.error(`Error sending to manager ${doc.id}:`, e);
                    }
                }

                // Save to notification collection
                return db.collection("notifications").add({
                    userId: doc.id,
                    title,
                    body,
                    read: false,
                    createdAt: admin.firestore.FieldValue.serverTimestamp(),
                    type: "EXECUTION_COMPLETED",
                    relatedId: event.params.orderId,
                });
            });

            await Promise.all(notifications);
        }
    }
);
