import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/group_chat_model.dart';

class FirebaseGroupChatService {
  final FirebaseFirestore firestore;

  FirebaseGroupChatService({required this.firestore});

  static const String _groupsCollection = 'groups';
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
          .where('memberIds', arrayContains: userId)
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
              .where('memberIds', arrayContains: userId)
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

      if (group.memberIds.contains(userId)) {
        return group;
      }

      if (group.memberIds.length >= maxGroupMembers) {
        throw MaxGroupMembersExceededException();
      }

      await firestore.collection(_groupsCollection).doc(groupId).update({
        'memberIds': FieldValue.arrayUnion([userId]),
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
        'memberIds': FieldValue.arrayRemove([userId]),
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
}
