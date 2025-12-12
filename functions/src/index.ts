import * as admin from "firebase-admin";
import { onDocumentCreated } from "firebase-functions/v2/firestore";

// Inicializar Firebase Admin
admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Interfaces
interface MessageData {
  conversationId: string;
  senderId: string;
  type: string;
  content: string;
  mediaUrl?: string;
  timestamp: admin.firestore.Timestamp;
}

interface UserData {
  id: string;
  name: string;
  fcmTokens?: string[];
}

interface DirectChatData {
  participantIds: string[];
  type: string;
}

interface GroupChatData {
  participantIds: string[];
  name: string;
  type: string;
}

/**
 * Cloud Function que se dispara cuando se crea un nuevo mensaje.
 * Envía notificaciones push a los destinatarios.
 */
export const onMessageCreated = onDocumentCreated(
  "messages/{messageId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) {
      console.log("No hay datos en el snapshot");
      return;
    }

    const messageData = snapshot.data() as MessageData;
    const { conversationId, senderId, type, content } = messageData;

    try {
      // Obtener información del remitente
      const senderDoc = await db.collection("users").doc(senderId).get();
      if (!senderDoc.exists) {
        console.log("Remitente no encontrado");
        return;
      }
      const senderData = senderDoc.data() as UserData;

      // Determinar si es chat directo o grupal
      const isGroupChat = await checkIfGroupChat(conversationId);

      let recipientTokens: string[] = [];
      let notificationTitle: string;
      let notificationBody: string;

      if (isGroupChat) {
        // Es un chat grupal
        const groupResult = await handleGroupNotification(
          conversationId,
          senderId,
          senderData.name,
          type,
          content
        );
        recipientTokens = groupResult.tokens;
        notificationTitle = groupResult.title;
        notificationBody = groupResult.body;
      } else {
        // Es un chat directo
        const directResult = await handleDirectNotification(
          conversationId,
          senderId,
          senderData.name,
          type,
          content
        );
        recipientTokens = directResult.tokens;
        notificationTitle = directResult.title;
        notificationBody = directResult.body;
      }

      if (recipientTokens.length === 0) {
        console.log("No hay tokens de destinatarios");
        return;
      }

      // Construir y enviar la notificación
      const message: admin.messaging.MulticastMessage = {
        tokens: recipientTokens,
        notification: {
          title: notificationTitle,
          body: notificationBody,
        },
        data: {
          conversationId: conversationId,
          senderId: senderId,
          isGroup: isGroupChat.toString(),
          type: type,
          click_action: "FLUTTER_NOTIFICATION_CLICK",
        },
        android: {
          notification: {
            channelId: "tecchat_messages_channel",
            priority: "high",
            defaultSound: true,
            defaultVibrateTimings: true,
          },
        },
      };

      const response = await messaging.sendEachForMulticast(message);

      console.log(
        `Notificaciones enviadas: ${response.successCount} exitosas, ` +
          `${response.failureCount} fallidas`
      );

      // Limpiar tokens inválidos
      await cleanupInvalidTokens(recipientTokens, response);
    } catch (error) {
      console.error("Error al enviar notificación:", error);
    }
  }
);

/**
 * Verifica si la conversación es un grupo
 */
async function checkIfGroupChat(conversationId: string): Promise<boolean> {
  // Primero buscar en la colección de grupos
  const groupDoc = await db.collection("groups").doc(conversationId).get();
  return groupDoc.exists;
}

/**
 * Maneja notificaciones para chats directos
 */
async function handleDirectNotification(
  conversationId: string,
  senderId: string,
  senderName: string,
  messageType: string,
  content: string
): Promise<{ tokens: string[]; title: string; body: string }> {
  // Obtener el chat directo
  const chatDoc = await db.collection("chats").doc(conversationId).get();
  if (!chatDoc.exists) {
    return { tokens: [], title: "", body: "" };
  }

  const chatData = chatDoc.data() as DirectChatData;
  const recipientId = chatData.participantIds.find((id) => id !== senderId);

  if (!recipientId) {
    return { tokens: [], title: "", body: "" };
  }

  // Obtener tokens del destinatario
  const recipientDoc = await db.collection("users").doc(recipientId).get();
  if (!recipientDoc.exists) {
    return { tokens: [], title: "", body: "" };
  }

  const recipientData = recipientDoc.data() as UserData;
  const tokens = recipientData.fcmTokens || [];

  const body = formatMessageContent(messageType, content);

  return {
    tokens,
    title: senderName,
    body,
  };
}

/**
 * Maneja notificaciones para chats grupales
 */
async function handleGroupNotification(
  groupId: string,
  senderId: string,
  senderName: string,
  messageType: string,
  content: string
): Promise<{ tokens: string[]; title: string; body: string }> {
  // Obtener el grupo
  const groupDoc = await db.collection("groups").doc(groupId).get();
  if (!groupDoc.exists) {
    return { tokens: [], title: "", body: "" };
  }

  const groupData = groupDoc.data() as GroupChatData;

  // Obtener tokens de todos los participantes excepto el remitente
  const recipientIds = groupData.participantIds.filter((id) => id !== senderId);

  const tokens: string[] = [];

  for (const recipientId of recipientIds) {
    const userDoc = await db.collection("users").doc(recipientId).get();
    if (userDoc.exists) {
      const userData = userDoc.data() as UserData;
      if (userData.fcmTokens) {
        tokens.push(...userData.fcmTokens);
      }
    }
  }

  const body = formatMessageContent(messageType, content, senderName);

  return {
    tokens,
    title: groupData.name,
    body,
  };
}

/**
 * Formatea el contenido del mensaje para la notificación
 */
function formatMessageContent(
  type: string,
  content: string,
  senderName?: string
): string {
  const prefix = senderName ? `${senderName}: ` : "";

  switch (type) {
    case "text":
      // Truncar mensajes largos
      return (
        prefix +
        (content.length > 100 ? content.substring(0, 100) + "..." : content)
      );
    case "image":
      return prefix + "📷 Foto";
    case "video":
      return prefix + "🎥 Video";
    case "audio":
      return prefix + "🎵 Audio";
    case "document":
      return prefix + "📄 Documento";
    case "emoji":
      return prefix + content;
    default:
      return prefix + "Nuevo mensaje";
  }
}

/**
 * Limpia tokens inválidos de la base de datos
 */
async function cleanupInvalidTokens(
  tokens: string[],
  response: admin.messaging.BatchResponse
): Promise<void> {
  const invalidTokens: string[] = [];

  response.responses.forEach((resp, idx) => {
    if (!resp.success) {
      const error = resp.error;
      if (
        error?.code === "messaging/invalid-registration-token" ||
        error?.code === "messaging/registration-token-not-registered"
      ) {
        invalidTokens.push(tokens[idx]);
      }
    }
  });

  if (invalidTokens.length === 0) return;

  console.log(`Limpiando ${invalidTokens.length} tokens inválidos`);

  // Buscar y actualizar usuarios con tokens inválidos
  const usersSnapshot = await db
    .collection("users")
    .where("fcmTokens", "array-contains-any", invalidTokens)
    .get();

  const batch = db.batch();

  usersSnapshot.docs.forEach((doc) => {
    const userData = doc.data() as UserData;
    const validTokens = (userData.fcmTokens || []).filter(
      (token) => !invalidTokens.includes(token)
    );

    batch.update(doc.ref, { fcmTokens: validTokens });
  });

  await batch.commit();
}
