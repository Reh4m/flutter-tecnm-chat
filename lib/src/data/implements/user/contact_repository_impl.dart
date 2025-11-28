import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/user/contact_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/user/contact_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/user/user_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/contact_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/user/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  final FirebaseContactService contactService;
  final FirebaseUserService userService;
  final NetworkInfo networkInfo;

  ContactRepositoryImpl({
    required this.contactService,
    required this.userService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, ContactEntity>> addContact({
    required String userId,
    required String contactUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      // Verificar que el usuario contacto existe
      final contactUser = await userService.getUserById(contactUserId);

      if (contactUser.id.isEmpty) {
        return Left(UserNotFoundFailure());
      }

      final contact = await contactService.addContact(
        userId: userId,
        contactUserId: contactUserId,
      );

      return Right(contact.toEntity());
    } on CannotAddSelfAsContactException {
      return Left(CannotAddSelfAsContactFailure());
    } on ContactAlreadyExistsException {
      return Left(ContactAlreadyExistsFailure());
    } on UserNotFoundException {
      return Left(UserNotFoundFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ContactEntity>>> getUserContacts(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final contacts = await contactService.getUserContacts(userId);
      return Right(contacts.map((c) => c.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<ContactEntity>>> getUserContactsStream(
    String userId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final contacts in contactService.getUserContactsStream(
        userId,
      )) {
        yield Right(contacts.map((c) => c.toEntity()).toList());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ContactEntity?>> getContactByUserId({
    required String userId,
    required String contactUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final contact = await contactService.getContactByUserId(
        userId: userId,
        contactUserId: contactUserId,
      );

      return Right(contact?.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeContact(String contactId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await contactService.removeContact(contactId);
      return const Right(unit);
    } on ContactOperationFailedException {
      return Left(ContactOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ContactEntity>> updateContact(
    ContactEntity contact,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final contactModel = ContactModel.fromEntity(contact);
      final updatedContact = await contactService.updateContact(contactModel);
      return Right(updatedContact.toEntity());
    } on ContactNotFoundException {
      return Left(ContactNotFoundFailure());
    } on ContactOperationFailedException {
      return Left(ContactOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ContactEntity>> toggleFavorite({
    required String contactId,
    required bool isFavorite,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final updatedContact = await contactService.toggleFavorite(
        contactId: contactId,
        isFavorite: isFavorite,
      );
      return Right(updatedContact.toEntity());
    } on ContactOperationFailedException {
      return Left(ContactOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ContactEntity>> toggleBlock({
    required String contactId,
    required bool isBlocked,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final updatedContact = await contactService.toggleBlock(
        contactId: contactId,
        isBlocked: isBlocked,
      );
      return Right(updatedContact.toEntity());
    } on ContactOperationFailedException {
      return Left(ContactOperationFailedFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> checkContactExists({
    required String userId,
    required String contactUserId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final exists = await contactService.checkContactExists(
        userId: userId,
        contactUserId: contactUserId,
      );
      return Right(exists);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> searchUserByPhoneNumber(
    String phoneNumber,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final querySnapshot =
          await userService.firestore
              .collection('users')
              .where('phoneNumber', isEqualTo: phoneNumber)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return const Right(null);
      }

      final user = await userService.getUserById(querySnapshot.docs.first.id);
      return Right(user.toEntity());
    } on UserNotFoundException {
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> searchUserByEmail(String email) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final querySnapshot =
          await userService.firestore
              .collection('users')
              .where('email', isEqualTo: email.toLowerCase())
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) {
        return const Right(null);
      }

      final user = await userService.getUserById(querySnapshot.docs.first.id);
      return Right(user.toEntity());
    } on UserNotFoundException {
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ContactEntity>>> getFavoriteContacts(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final contacts = await contactService.getFavoriteContacts(userId);
      return Right(contacts.map((c) => c.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ContactEntity>>> getBlockedContacts(
    String userId,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final contacts = await contactService.getBlockedContacts(userId);
      return Right(contacts.map((c) => c.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
