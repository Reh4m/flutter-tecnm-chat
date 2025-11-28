import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/message_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/direct_chat_model.dart';

class FirebaseDirectChatService {
  final FirebaseFirestore firestore;

  FirebaseDirectChatService({required this.firestore});

  static const String _conversationsCollection = 'conversations';
  static const String _messagesCollection = 'messages';

  Future<DirectChatModel> createConversation(
    DirectChatModel conversation,
  ) async {
    try {
      final docRef = await firestore
          .collection(_conversationsCollection)
          .add(conversation.toFirestore());

      final createdDoc = await docRef.get();
      return DirectChatModel.fromFirestore(createdDoc);
    } catch (e) {
      throw ServerException();
    }
  }

  Future<DirectChatModel?> findDirectConversation({
    required String userId1,
    required String userId2,
  }) async {
    try {
      final querySnapshot =
          await firestore
              .collection(_conversationsCollection)
              .where('type', isEqualTo: 'direct')
              .where('participantIds', arrayContains: userId1)
              .get();

      for (var doc in querySnapshot.docs) {
        final conversation = DirectChatModel.fromFirestore(doc);
        if (conversation.participantIds.contains(userId2)) {
          return conversation;
        }
      }

      return null;
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<DirectChatModel>> getUserConversationsStream(String userId) {
    try {
      return firestore
          .collection(_conversationsCollection)
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

  Future<DirectChatModel> getConversationById(String conversationId) async {
    try {
      final doc =
          await firestore
              .collection(_conversationsCollection)
              .doc(conversationId)
              .get();

      if (!doc.exists) {
        throw ConversationNotFoundException();
      }

      return DirectChatModel.fromFirestore(doc);
    } catch (e) {
      if (e is ConversationNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<DirectChatModel> updateConversation(
    DirectChatModel conversation,
  ) async {
    try {
      await firestore
          .collection(_conversationsCollection)
          .doc(conversation.id)
          .update(conversation.toFirestore());

      final updatedDoc =
          await firestore
              .collection(_conversationsCollection)
              .doc(conversation.id)
              .get();

      return DirectChatModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw ConversationOperationFailedException();
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    try {
      await firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .delete();
    } catch (e) {
      throw ConversationOperationFailedException();
    }
  }

  Future<void> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    try {
      final conversationDoc =
          await firestore
              .collection(_conversationsCollection)
              .doc(conversationId)
              .get();

      if (!conversationDoc.exists) return;

      await firestore
          .collection(_conversationsCollection)
          .doc(conversationId)
          .update({
            'unreadCount.$userId': 0,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      final messagesSnapshot =
          await firestore
              .collection(_messagesCollection)
              .where('conversationId', isEqualTo: conversationId)
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

  Future<void> updateConversationLastMessage(MessageModel message) async {
    try {
      final conversationRef = firestore
          .collection(_conversationsCollection)
          .doc(message.conversationId);

      final conversationDoc = await conversationRef.get();
      if (!conversationDoc.exists) return;

      final conversation = DirectChatModel.fromFirestore(conversationDoc);

      Map<String, int> newUnreadCount = Map.from(conversation.unreadCount);
      for (var participantId in conversation.participantIds) {
        if (participantId != message.senderId) {
          newUnreadCount[participantId] =
              (newUnreadCount[participantId] ?? 0) + 1;
        } else {
          // El remitente siempre tiene contador en 0
          newUnreadCount[participantId] = 0;
        }
      }

      await conversationRef.update({
        'lastMessage': message.content,
        'lastMessageSenderId': message.senderId,
        'lastMessageTime': message.timestamp,
        'unreadCount': newUnreadCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException();
    }
  }
}
