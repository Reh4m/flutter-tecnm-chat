import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/group_chat_model.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/message_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/storage/storage_service.dart';

class FirebaseGroupChatService {
  final FirebaseFirestore firestore;
  final FirebaseStorageService storageService;

  FirebaseGroupChatService({
    required this.firestore,
    required this.storageService,
  });

  static const String _groupsCollection = 'groups';
  static const String _messagesCollection = 'messages';
  static const int maxGroupMembers = 256;

  Future<GroupChatModel> createGroup(GroupChatModel group) async {
    try {
      final docRef = await firestore
          .collection(_groupsCollection)
          .add(group.toFirestore());

      final createdDoc = await docRef.get();
      return GroupChatModel.fromFirestore(createdDoc);
    } catch (e) {
      throw ServerException();
    }
  }

  Future<GroupChatModel> getGroupById(String groupId) async {
    try {
      final doc =
          await firestore.collection(_groupsCollection).doc(groupId).get();

      if (!doc.exists) {
        throw GroupNotFoundException();
      }

      return GroupChatModel.fromFirestore(doc);
    } catch (e) {
      if (e is GroupNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Stream<List<GroupChatModel>> getUserGroupsStream(String userId) {
    try {
      return firestore
          .collection(_groupsCollection)
          .where('participantIds', arrayContains: userId)
          .orderBy('updatedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => GroupChatModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<List<GroupChatModel>> getUserGroups(String userId) async {
    try {
      final querySnapshot =
          await firestore
              .collection(_groupsCollection)
              .where('participantIds', arrayContains: userId)
              .orderBy('updatedAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => GroupChatModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<GroupChatModel> updateGroup(GroupChatModel group) async {
    try {
      await firestore
          .collection(_groupsCollection)
          .doc(group.id)
          .update(group.toFirestore());

      final updatedDoc =
          await firestore.collection(_groupsCollection).doc(group.id).get();

      return GroupChatModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw GroupOperationFailedException();
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await firestore.collection(_groupsCollection).doc(groupId).delete();
    } catch (e) {
      throw GroupOperationFailedException();
    }
  }

  Future<String> uploadProfileImage(File image, String groupId) async {
    try {
      return await storageService.uploadGroupProfileImage(image, groupId);
    } catch (e) {
      throw ProfileImageUploadException();
    }
  }

  Future<GroupChatModel> updateProfileImage(
    String groupId,
    String imageUrl,
  ) async {
    try {
      await firestore.collection(_groupsCollection).doc(groupId).update({
        'avatarUrl': imageUrl,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      // Retornar el grupo actualizado
      return await getGroupById(groupId);
    } catch (e) {
      throw GroupOperationFailedException();
    }
  }

  Future<GroupChatModel> addMember({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    try {
      final group = await getGroupById(groupId);

      if (!group.isAdmin(requestingUserId)) {
        throw NotGroupAdminException();
      }

      if (group.participantIds.contains(userId)) {
        return group;
      }

      if (group.participantIds.length >= maxGroupMembers) {
        throw MaxGroupMembersExceededException();
      }

      await firestore.collection(_groupsCollection).doc(groupId).update({
        'participantIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return await getGroupById(groupId);
    } catch (e) {
      if (e is NotGroupAdminException ||
          e is MaxGroupMembersExceededException) {
        rethrow;
      }
      throw GroupOperationFailedException();
    }
  }

  Future<GroupChatModel> removeMember({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    try {
      final group = await getGroupById(groupId);

      if (group.createdBy == userId) {
        throw CannotRemoveGroupCreatorException();
      }

      if (!group.isAdmin(requestingUserId) && requestingUserId != userId) {
        throw NotGroupAdminException();
      }

      await firestore.collection(_groupsCollection).doc(groupId).update({
        'participantIds': FieldValue.arrayRemove([userId]),
        'adminIds': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return await getGroupById(groupId);
    } catch (e) {
      if (e is NotGroupAdminException ||
          e is CannotRemoveGroupCreatorException) {
        rethrow;
      }
      throw GroupOperationFailedException();
    }
  }

  Future<GroupChatModel> addAdmin({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    try {
      final group = await getGroupById(groupId);

      if (!group.isCreator(requestingUserId)) {
        throw NotGroupAdminException();
      }

      if (!group.isMember(userId)) {
        throw NotGroupMemberException();
      }

      await firestore.collection(_groupsCollection).doc(groupId).update({
        'adminIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return await getGroupById(groupId);
    } catch (e) {
      if (e is NotGroupAdminException || e is NotGroupMemberException) {
        rethrow;
      }
      throw GroupOperationFailedException();
    }
  }

  Future<GroupChatModel> removeAdmin({
    required String groupId,
    required String userId,
    required String requestingUserId,
  }) async {
    try {
      final group = await getGroupById(groupId);

      if (!group.isCreator(requestingUserId)) {
        throw NotGroupAdminException();
      }

      if (group.createdBy == userId) {
        throw CannotRemoveGroupCreatorException();
      }

      await firestore.collection(_groupsCollection).doc(groupId).update({
        'adminIds': FieldValue.arrayRemove([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return await getGroupById(groupId);
    } catch (e) {
      if (e is NotGroupAdminException ||
          e is CannotRemoveGroupCreatorException) {
        rethrow;
      }
      throw GroupOperationFailedException();
    }
  }

  Future<GroupChatModel> updateGroupPrivacy({
    required String groupId,
    required bool hidePhoneNumbers,
    required String requestingUserId,
  }) async {
    try {
      final group = await getGroupById(groupId);

      if (!group.isAdmin(requestingUserId)) {
        throw NotGroupAdminException();
      }

      await firestore.collection(_groupsCollection).doc(groupId).update({
        'hidePhoneNumbers': hidePhoneNumbers,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return await getGroupById(groupId);
    } catch (e) {
      if (e is NotGroupAdminException) rethrow;
      throw GroupOperationFailedException();
    }
  }

  Future<GroupChatModel> updateGroupInfo({
    required String groupId,
    String? name,
    String? description,
    String? avatarUrl,
    required String requestingUserId,
  }) async {
    try {
      final group = await getGroupById(groupId);

      if (!group.isAdmin(requestingUserId)) {
        throw NotGroupAdminException();
      }

      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (avatarUrl != null) updates['avatarUrl'] = avatarUrl;

      await firestore
          .collection(_groupsCollection)
          .doc(groupId)
          .update(updates);

      return await getGroupById(groupId);
    } catch (e) {
      if (e is NotGroupAdminException) rethrow;
      throw GroupOperationFailedException();
    }
  }

  Future<void> markChatAsRead({
    required String chatId,
    required String userId,
  }) async {
    try {
      final chatDoc =
          await firestore.collection(_groupsCollection).doc(chatId).get();

      if (!chatDoc.exists) return;

      await firestore.collection(_groupsCollection).doc(chatId).update({
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
          .collection(_groupsCollection)
          .doc(message.conversationId);

      final chatDoc = await chatRef.get();
      if (!chatDoc.exists) return;

      final chat = GroupChatModel.fromFirestore(chatDoc);

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
        'lastMessageTime': message.timestamp,
        'unreadCount': newUnreadCount,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw ServerException();
    }
  }
}
