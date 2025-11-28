import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/message_model.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/message_entity.dart';

class FirebaseMessageService {
  final FirebaseFirestore firestore;

  FirebaseMessageService({required this.firestore});

  static const String _messagesCollection = 'messages';

  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      final docRef = await firestore
          .collection(_messagesCollection)
          .add(message.toFirestore());

      final createdDoc = await docRef.get();
      return MessageModel.fromFirestore(createdDoc);
    } catch (e) {
      throw MessageSendFailedException();
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
