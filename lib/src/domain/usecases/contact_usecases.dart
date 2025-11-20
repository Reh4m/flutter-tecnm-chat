import 'package:dartz/dartz.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/contact_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/contact_repository.dart';

class AddContactUseCase {
  final ContactRepository repository;

  AddContactUseCase(this.repository);

  Future<Either<Failure, ContactEntity>> call({
    required String userId,
    required String contactUserId,
  }) async {
    return await repository.addContact(
      userId: userId,
      contactUserId: contactUserId,
    );
  }
}

class GetUserContactsUseCase {
  final ContactRepository repository;

  GetUserContactsUseCase(this.repository);

  Future<Either<Failure, List<ContactEntity>>> call(String userId) async {
    return await repository.getUserContacts(userId);
  }
}

class GetUserContactsStreamUseCase {
  final ContactRepository repository;

  GetUserContactsStreamUseCase(this.repository);

  Stream<Either<Failure, List<ContactEntity>>> call(String userId) {
    return repository.getUserContactsStream(userId);
  }
}

class GetContactByUserIdUseCase {
  final ContactRepository repository;

  GetContactByUserIdUseCase(this.repository);

  Future<Either<Failure, ContactEntity?>> call({
    required String userId,
    required String contactUserId,
  }) async {
    return await repository.getContactByUserId(
      userId: userId,
      contactUserId: contactUserId,
    );
  }
}

class RemoveContactUseCase {
  final ContactRepository repository;

  RemoveContactUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String contactId) async {
    return await repository.removeContact(contactId);
  }
}

class UpdateContactUseCase {
  final ContactRepository repository;

  UpdateContactUseCase(this.repository);

  Future<Either<Failure, ContactEntity>> call(ContactEntity contact) async {
    return await repository.updateContact(contact);
  }
}

class ToggleFavoriteContactUseCase {
  final ContactRepository repository;

  ToggleFavoriteContactUseCase(this.repository);

  Future<Either<Failure, ContactEntity>> call({
    required String contactId,
    required bool isFavorite,
  }) async {
    return await repository.toggleFavorite(
      contactId: contactId,
      isFavorite: isFavorite,
    );
  }
}

class ToggleBlockContactUseCase {
  final ContactRepository repository;

  ToggleBlockContactUseCase(this.repository);

  Future<Either<Failure, ContactEntity>> call({
    required String contactId,
    required bool isBlocked,
  }) async {
    return await repository.toggleBlock(
      contactId: contactId,
      isBlocked: isBlocked,
    );
  }
}

class CheckContactExistsUseCase {
  final ContactRepository repository;

  CheckContactExistsUseCase(this.repository);

  Future<Either<Failure, bool>> call({
    required String userId,
    required String contactUserId,
  }) async {
    return await repository.checkContactExists(
      userId: userId,
      contactUserId: contactUserId,
    );
  }
}

class SearchUserByPhoneNumberUseCase {
  final ContactRepository repository;

  SearchUserByPhoneNumberUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call(String phoneNumber) async {
    return await repository.searchUserByPhoneNumber(phoneNumber);
  }
}

class SearchUserByEmailUseCase {
  final ContactRepository repository;

  SearchUserByEmailUseCase(this.repository);

  Future<Either<Failure, UserEntity?>> call(String email) async {
    return await repository.searchUserByEmail(email);
  }
}

class GetFavoriteContactsUseCase {
  final ContactRepository repository;

  GetFavoriteContactsUseCase(this.repository);

  Future<Either<Failure, List<ContactEntity>>> call(String userId) async {
    return await repository.getFavoriteContacts(userId);
  }
}

class GetBlockedContactsUseCase {
  final ContactRepository repository;

  GetBlockedContactsUseCase(this.repository);

  Future<Either<Failure, List<ContactEntity>>> call(String userId) async {
    return await repository.getBlockedContacts(userId);
  }
}
