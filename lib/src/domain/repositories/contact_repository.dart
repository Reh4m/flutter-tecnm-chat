import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/contact_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user_entity.dart';

abstract class ContactRepository {
  Future<Either<Failure, ContactEntity>> addContact({
    required String userId,
    required String contactUserId,
  });
  Future<Either<Failure, List<ContactEntity>>> getUserContacts(String userId);
  Stream<Either<Failure, List<ContactEntity>>> getUserContactsStream(
    String userId,
  );
  Future<Either<Failure, ContactEntity?>> getContactByUserId({
    required String userId,
    required String contactUserId,
  });
  Future<Either<Failure, Unit>> removeContact(String contactId);
  Future<Either<Failure, ContactEntity>> updateContact(ContactEntity contact);
  Future<Either<Failure, ContactEntity>> toggleFavorite({
    required String contactId,
    required bool isFavorite,
  });
  Future<Either<Failure, ContactEntity>> toggleBlock({
    required String contactId,
    required bool isBlocked,
  });
  Future<Either<Failure, bool>> checkContactExists({
    required String userId,
    required String contactUserId,
  });
  Future<Either<Failure, UserEntity?>> searchUserByPhoneNumber(
    String phoneNumber,
  );
  Future<Either<Failure, UserEntity?>> searchUserByEmail(String email);
  Future<Either<Failure, List<ContactEntity>>> getFavoriteContacts(
    String userId,
  );
  Future<Either<Failure, List<ContactEntity>>> getBlockedContacts(
    String userId,
  );
}
