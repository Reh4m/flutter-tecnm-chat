import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/user/contact_model.dart';

class FirebaseContactService {
  final FirebaseFirestore firestore;

  FirebaseContactService({required this.firestore});

  static const String _contactsCollection = 'contacts';

  Future<ContactModel> addContact({
    required String userId,
    required String contactUserId,
  }) async {
    try {
      if (userId == contactUserId) {
        throw CannotAddSelfAsContactException();
      }

      // Verificar si el contacto ya existe
      final existingContact =
          await firestore
              .collection(_contactsCollection)
              .where('userId', isEqualTo: userId)
              .where('contactUserId', isEqualTo: contactUserId)
              .limit(1)
              .get();

      if (existingContact.docs.isNotEmpty) {
        throw ContactAlreadyExistsException();
      }

      final contact = ContactModel(
        id: '',
        userId: userId,
        contactUserId: contactUserId,
        addedAt: DateTime.now(),
      );

      final docRef = await firestore
          .collection(_contactsCollection)
          .add(contact.toFirestore());

      final createdDoc = await docRef.get();
      return ContactModel.fromFirestore(createdDoc);
    } catch (e) {
      if (e is ContactAlreadyExistsException ||
          e is CannotAddSelfAsContactException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  Future<List<ContactModel>> getUserContacts(String userId) async {
    try {
      final querySnapshot =
          await firestore
              .collection(_contactsCollection)
              .where('userId', isEqualTo: userId)
              .where('isBlocked', isEqualTo: false)
              .orderBy('addedAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ContactModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<ContactModel>> getUserContactsStream(String userId) {
    try {
      return firestore
          .collection(_contactsCollection)
          .where('userId', isEqualTo: userId)
          .where('isBlocked', isEqualTo: false)
          .orderBy('addedAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => ContactModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw ServerException();
    }
  }

  Future<ContactModel?> getContactByUserId({
    required String userId,
    required String contactUserId,
  }) async {
    try {
      final querySnapshot =
          await firestore
              .collection(_contactsCollection)
              .where('userId', isEqualTo: userId)
              .where('contactUserId', isEqualTo: contactUserId)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return ContactModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw ServerException();
    }
  }

  Future<void> removeContact(String contactId) async {
    try {
      await firestore.collection(_contactsCollection).doc(contactId).delete();
    } catch (e) {
      throw ContactOperationFailedException();
    }
  }

  Future<ContactModel> updateContact(ContactModel contact) async {
    try {
      await firestore
          .collection(_contactsCollection)
          .doc(contact.id)
          .update(contact.toFirestore());

      final updatedDoc =
          await firestore.collection(_contactsCollection).doc(contact.id).get();

      if (!updatedDoc.exists) {
        throw ContactNotFoundException();
      }

      return ContactModel.fromFirestore(updatedDoc);
    } catch (e) {
      if (e is ContactNotFoundException) rethrow;
      throw ContactOperationFailedException();
    }
  }

  Future<ContactModel> toggleFavorite({
    required String contactId,
    required bool isFavorite,
  }) async {
    try {
      await firestore.collection(_contactsCollection).doc(contactId).update({
        'isFavorite': isFavorite,
      });

      final updatedDoc =
          await firestore.collection(_contactsCollection).doc(contactId).get();

      return ContactModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw ContactOperationFailedException();
    }
  }

  Future<ContactModel> toggleBlock({
    required String contactId,
    required bool isBlocked,
  }) async {
    try {
      await firestore.collection(_contactsCollection).doc(contactId).update({
        'isBlocked': isBlocked,
      });

      final updatedDoc =
          await firestore.collection(_contactsCollection).doc(contactId).get();

      return ContactModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw ContactOperationFailedException();
    }
  }

  Future<bool> checkContactExists({
    required String userId,
    required String contactUserId,
  }) async {
    try {
      final querySnapshot =
          await firestore
              .collection(_contactsCollection)
              .where('userId', isEqualTo: userId)
              .where('contactUserId', isEqualTo: contactUserId)
              .limit(1)
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw ServerException();
    }
  }

  Future<List<ContactModel>> getFavoriteContacts(String userId) async {
    try {
      final querySnapshot =
          await firestore
              .collection(_contactsCollection)
              .where('userId', isEqualTo: userId)
              .where('isFavorite', isEqualTo: true)
              .where('isBlocked', isEqualTo: false)
              .orderBy('addedAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ContactModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }

  Future<List<ContactModel>> getBlockedContacts(String userId) async {
    try {
      final querySnapshot =
          await firestore
              .collection(_contactsCollection)
              .where('userId', isEqualTo: userId)
              .where('isBlocked', isEqualTo: true)
              .orderBy('addedAt', descending: true)
              .get();

      return querySnapshot.docs
          .map((doc) => ContactModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ServerException();
    }
  }
}
