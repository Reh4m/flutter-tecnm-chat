import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/direct_chat_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/message_model.dart';

class FirebaseDirectChatService {
  final FirebaseFirestore firestore;

  FirebaseDirectChatService({required this.firestore});

  static const String _chatsCollection = 'chats';
  static const String _messagesCollection = 'messages';

  Future<DirectChatModel> createChat(DirectChatModel chat) async {
    try {
      final docRef = await firestore
          .collection(_chatsCollection)
          .add(chat.toFirestore());

      final createdDoc = await docRef.get();
      return DirectChatModel.fromFirestore(createdDoc);
    } catch (e) {
      throw ServerException();
    }
  }

  Future<DirectChatModel?> findChatByParticipants({
    required String userId1,
    required String userId2,
  }) async {
    try {
      final querySnapshot =
          await firestore
              .collection(_chatsCollection)
              .where('participantIds', arrayContains: userId1)
              .get();

      for (var doc in querySnapshot.docs) {
        final chat = DirectChatModel.fromFirestore(doc);
        if (chat.participantIds.contains(userId2)) {
          return chat;
        }
      }

      return null;
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<DirectChatModel>> getUserChatsStream(String userId) {
    try {
      return firestore
          .collection(_chatsCollection)
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => DirectChatModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<DirectChatModel> getChatById(String chatId) async {
    try {
      final doc =
          await firestore.collection(_chatsCollection).doc(chatId).get();

      if (!doc.exists) {
        throw ConversationNotFoundException();
      }

      return DirectChatModel.fromFirestore(doc);
    } catch (e) {
      if (e is ConversationNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<DirectChatModel> updateChat(DirectChatModel chat) async {
    try {
      await firestore
          .collection(_chatsCollection)
          .doc(chat.id)
          .update(chat.toFirestore());

      final updatedDoc =
          await firestore.collection(_chatsCollection).doc(chat.id).get();

      return DirectChatModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw ConversationOperationFailedException();
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await firestore.collection(_chatsCollection).doc(chatId).delete();
    } catch (e) {
      throw ConversationOperationFailedException();
    }
  }

  Future<void> markChatAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      final chatDoc =
          await firestore.collection(_chatsCollection).doc(chatId).get();

      if (!chatDoc.exists) return;

      await firestore.collection(_chatsCollection).doc(chatId).update({
        'unreadCount.$userId': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final messagesSnapshot =
          await firestore
              .collection(_messagesCollection)
              .where('conversationId', isEqualTo: chatId)
              .where('senderId', isNotEqualTo: userId)
              .where('status', whereIn: ['sent', 'delivered'])
              .get();

      if (messagesSnapshot.docs.isNotEmpty) {
        final batch = firestore.batch();
        for (var doc in messagesSnapshot.docs) {
          batch.update(doc.reference, {
            'status': 'read',
            'readBy': FieldValue.arrayUnion([userId]),
          });
        }
        await batch.commit();
      }
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> updateChatLastMessage(MessageModel message) async {
    try {
      final chatRef = firestore
          .collection(_chatsCollection)
          .doc(message.conversationId);

      final chatDoc = await chatRef.get();
      if (!chatDoc.exists) return;

      final chat = DirectChatModel.fromFirestore(chatDoc);

      Map<String, int> newUnreadCount = Map.from(chat.unreadCount);
      for (var participantId in chat.participantIds) {
        if (participantId != message.senderId) {
          newUnreadCount[participantId] =
              (newUnreadCount[participantId] ?? 0) + 1;
        } else {
          // El remitente siempre tiene contador en 0
          newUnreadCount[participantId] = 0;
        }
      }

      await chatRef.update({
        'lastMessage': message.content,
        'lastMessageSenderId': message.senderId,
        'lastMessageType': message.type.name,
        'lastMessageTime': message.timestamp,
        'unreadCount': newUnreadCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException();
    }
  }
}
