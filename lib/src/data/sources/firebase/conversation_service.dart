import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversation_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/message_model.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/message_entity.dart';

class FirebaseConversationService {
  final FirebaseFirestore firestore;

  FirebaseConversationService({required this.firestore});

  static const String _conversationsCollection = 'conversations';
  static const String _messagesCollection = 'messages';

  Future<ConversationModel> createConversation(
    ConversationModel conversation,
  ) async {
    try {
      final docRef = await firestore
          .collection(_conversationsCollection)
          .add(conversation.toFirestore());

      final createdDoc = await docRef.get();
      return ConversationModel.fromFirestore(createdDoc);
    } catch (e) {
      throw ServerException();
    }
  }

  Future<ConversationModel?> findDirectConversation({
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
        final conversation = ConversationModel.fromFirestore(doc);
        if (conversation.participantIds.contains(userId2)) {
          return conversation;
        }
      }

      return null;
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<ConversationModel>> getUserConversationsStream(String userId) {
    try {
      return firestore
          .collection(_conversationsCollection)
          .where('participantIds', arrayContains: userId)
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ConversationModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<ConversationModel> getConversationById(String conversationId) async {
    try {
      final doc =
          await firestore
              .collection(_conversationsCollection)
              .doc(conversationId)
              .get();

      if (!doc.exists) {
        throw ConversationNotFoundException();
      }

      return ConversationModel.fromFirestore(doc);
    } catch (e) {
      if (e is ConversationNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<ConversationModel> updateConversation(
    ConversationModel conversation,
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

      return ConversationModel.fromFirestore(updatedDoc);
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

  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      final docRef = await firestore
          .collection(_messagesCollection)
          .add(message.toFirestore());

      await _updateConversationLastMessage(message);

      final createdDoc = await docRef.get();
      return MessageModel.fromFirestore(createdDoc);
    } catch (e) {
      throw MessageSendFailedException();
    }
  }

  Stream<List<MessageModel>> getConversationMessagesStream({
    required String conversationId,
    int limit = 50,
  }) {
    try {
      return firestore
          .collection(_messagesCollection)
          .where('conversationId', isEqualTo: conversationId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => MessageModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<List<MessageModel>> getConversationMessages({
    required String conversationId,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = firestore
          .collection(_messagesCollection)
          .where('conversationId', isEqualTo: conversationId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> markMessageAsRead({
    required String messageId,
    required String userId,
  }) async {
    try {
      await firestore.collection(_messagesCollection).doc(messageId).update({
        'readBy': FieldValue.arrayUnion([userId]),
        'status': 'read',
      });
    } catch (e) {
      throw ServerException();
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

  Future<void> deleteMessage(String messageId) async {
    try {
      await firestore.collection(_messagesCollection).doc(messageId).update({
        'isDeleted': true,
        'content': 'Mensaje eliminado',
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> _updateConversationLastMessage(MessageModel message) async {
    try {
      final conversationRef = firestore
          .collection(_conversationsCollection)
          .doc(message.conversationId);

      final conversationDoc = await conversationRef.get();
      if (!conversationDoc.exists) return;

      final conversation = ConversationModel.fromFirestore(conversationDoc);

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

  Future<MessageModel> getMessageById(String messageId) async {
    try {
      final doc =
          await firestore.collection(_messagesCollection).doc(messageId).get();

      if (!doc.exists) {
        throw MessageNotFoundException();
      }

      return MessageModel.fromFirestore(doc);
    } catch (e) {
      if (e is MessageNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<void> updateMessageStatus({
    required String messageId,
    required MessageStatus status,
  }) async {
    try {
      await firestore.collection(_messagesCollection).doc(messageId).update({
        'status': _messageStatusToString(status),
      });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> markAllMessagesAsDelivered({
    required String conversationId,
    required String userId,
  }) async {
    try {
      // Obtener todos los mensajes no leídos que no son del usuario actual
      final querySnapshot =
          await firestore
              .collection(_messagesCollection)
              .where('conversationId', isEqualTo: conversationId)
              .where('senderId', isNotEqualTo: userId)
              .where('status', whereIn: ['sending', 'sent'])
              .get();

      // Actualizar en batch
      final batch = firestore.batch();

      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'status': 'delivered'});
      }

      await batch.commit();
    } catch (e) {
      throw ServerException();
    }
  }

  static String _messageStatusToString(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return 'sending';
      case MessageStatus.sent:
        return 'sent';
      case MessageStatus.delivered:
        return 'delivered';
      case MessageStatus.read:
        return 'read';
      case MessageStatus.failed:
        return 'failed';
    }
  }
}
