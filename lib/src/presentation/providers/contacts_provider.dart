import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/contact_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/contact_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/user_usecases.dart';

enum ContactsState { initial, loading, success, error }

class ContactsProvider extends ChangeNotifier {
  final GetUserContactsStreamUseCase _getContactsStreamUseCase =
      sl<GetUserContactsStreamUseCase>();
  final AddContactUseCase _addContactUseCase = sl<AddContactUseCase>();
  final RemoveContactUseCase _removeContactUseCase = sl<RemoveContactUseCase>();
  final SearchUserByPhoneNumberUseCase _searchByPhoneUseCase =
      sl<SearchUserByPhoneNumberUseCase>();
  final SearchUserByEmailUseCase _searchByEmailUseCase =
      sl<SearchUserByEmailUseCase>();
  final ToggleFavoriteContactUseCase _toggleFavoriteUseCase =
      sl<ToggleFavoriteContactUseCase>();
  final ToggleBlockContactUseCase _toggleBlockUseCase =
      sl<ToggleBlockContactUseCase>();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();

  ContactsState _contactsState = ContactsState.initial;
  List<ContactEntity> _contacts = [];
  final Map<String, UserEntity> _contactUsers = {};
  String? _contactsError;
  StreamSubscription? _contactsSubscription;

  ContactsState _operationState = ContactsState.initial;
  String? _operationError;

  ContactsState _searchState = ContactsState.initial;
  UserEntity? _searchedUser;
  String? _searchError;

  ContactsState get contactsState => _contactsState;
  List<ContactEntity> get contacts => _contacts;
  Map<String, UserEntity> get contactUsers => _contactUsers;
  String? get contactsError => _contactsError;

  ContactsState get operationState => _operationState;
  String? get operationError => _operationError;

  ContactsState get searchState => _searchState;
  UserEntity? get searchedUser => _searchedUser;
  String? get searchError => _searchError;

  List<ContactEntity> get favoriteContacts =>
      _contacts.where((c) => c.isFavorite).toList();

  void startContactsListener(String userId) {
    _setContactsState(ContactsState.loading);

    _contactsSubscription = _getContactsStreamUseCase(userId).listen(
      (either) {
        either.fold(
          (failure) => _setContactsError(_mapFailureToMessage(failure)),
          (contacts) async {
            _contacts = contacts;
            await _loadContactUsers(contacts);
            _setContactsState(ContactsState.success);
          },
        );
      },
      onError: (error) {
        _setContactsError('Error de conexión: $error');
      },
    );
  }

  Future<void> _loadContactUsers(List<ContactEntity> contacts) async {
    for (final contact in contacts) {
      if (!_contactUsers.containsKey(contact.contactUserId)) {
        final result = await _getUserByIdUseCase(contact.contactUserId);
        result.fold(
          (_) => null,
          (user) => _contactUsers[contact.contactUserId] = user,
        );
      }
    }
  }

  void stopContactsListener() {
    _contactsSubscription?.cancel();
    _contactsSubscription = null;
  }

  Future<bool> addContact({
    required String userId,
    required String contactUserId,
  }) async {
    _setOperationState(ContactsState.loading);

    final result = await _addContactUseCase(
      userId: userId,
      contactUserId: contactUserId,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (contact) {
        _setOperationState(ContactsState.success);
        return true;
      },
    );
  }

  Future<bool> removeContact(String contactId) async {
    _setOperationState(ContactsState.loading);

    final result = await _removeContactUseCase(contactId);

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setOperationState(ContactsState.success);
        return true;
      },
    );
  }

  Future<UserEntity?> searchUserByPhone(String phoneNumber) async {
    _setSearchState(ContactsState.loading);

    final result = await _searchByPhoneUseCase(phoneNumber);

    return result.fold(
      (failure) {
        _setSearchError(_mapFailureToMessage(failure));
        return null;
      },
      (user) {
        _searchedUser = user;
        _setSearchState(ContactsState.success);
        return user;
      },
    );
  }

  Future<UserEntity?> searchUserByEmail(String email) async {
    _setSearchState(ContactsState.loading);

    final result = await _searchByEmailUseCase(email);

    return result.fold(
      (failure) {
        _setSearchError(_mapFailureToMessage(failure));
        return null;
      },
      (user) {
        _searchedUser = user;
        _setSearchState(ContactsState.success);
        return user;
      },
    );
  }

  Future<bool> toggleFavorite(String contactId, bool isFavorite) async {
    _setOperationState(ContactsState.loading);

    final result = await _toggleFavoriteUseCase(
      contactId: contactId,
      isFavorite: isFavorite,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setOperationState(ContactsState.success);
        return true;
      },
    );
  }

  Future<bool> toggleBlock(String contactId, bool isBlocked) async {
    _setOperationState(ContactsState.loading);

    final result = await _toggleBlockUseCase(
      contactId: contactId,
      isBlocked: isBlocked,
    );

    return result.fold(
      (failure) {
        _setOperationError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setOperationState(ContactsState.success);
        return true;
      },
    );
  }

  UserEntity? getContactUser(String userId) {
    return _contactUsers[userId];
  }

  void clearSearch() {
    _searchedUser = null;
    _searchError = null;
    _searchState = ContactsState.initial;
    notifyListeners();
  }

  void _setContactsState(ContactsState newState) {
    _contactsState = newState;
    if (newState != ContactsState.error) {
      _contactsError = null;
    }
    notifyListeners();
  }

  void _setContactsError(String message) {
    _contactsError = message;
    _setContactsState(ContactsState.error);
  }

  void _setOperationState(ContactsState newState) {
    _operationState = newState;
    if (newState != ContactsState.error) {
      _operationError = null;
    }
    notifyListeners();
  }

  void _setOperationError(String message) {
    _operationError = message;
    _setOperationState(ContactsState.error);
  }

  void _setSearchState(ContactsState newState) {
    _searchState = newState;
    if (newState != ContactsState.error) {
      _searchError = null;
    }
    notifyListeners();
  }

  void _setSearchError(String message) {
    _searchError = message;
    _setSearchState(ContactsState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (ContactAlreadyExistsFailure):
        return ErrorMessages.contactAlreadyExists;
      case const (ContactNotFoundFailure):
        return ErrorMessages.contactNotFound;
      case const (CannotAddSelfAsContactFailure):
        return ErrorMessages.cannotAddSelfAsContact;
      case const (UserNotFoundFailure):
        return ErrorMessages.userNotFoundByPhone;
      default:
        return ErrorMessages.serverError;
    }
  }

  void clearOperationError() {
    _operationError = null;
    notifyListeners();
  }

  void clearContactsError() {
    _contactsError = null;
    notifyListeners();
  }

  void clearSearchError() {
    _searchError = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopContactsListener();
    super.dispose();
  }
}
