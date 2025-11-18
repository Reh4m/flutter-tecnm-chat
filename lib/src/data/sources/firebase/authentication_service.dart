import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';

class FirebaseAuthenticationService {
  final FirebaseAuth firebaseAuth;

  FirebaseAuthenticationService({required this.firebaseAuth});

  Future<bool> isRegistrationComplete() async {
    try {
      final User? user = firebaseAuth.currentUser;

      if (user == null) {
        throw UserNotFoundException();
      }

      final hasName = user.displayName != null && user.displayName!.isNotEmpty;
      final hasEmail = user.email != null && user.email!.isNotEmpty;

      return hasName && hasEmail;
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<void> updateUserProfile({String? displayName}) async {
    try {
      final User? user = firebaseAuth.currentUser;

      if (user == null) {
        throw UserNotFoundException();
      }

      if (displayName != null && displayName.isNotEmpty) {
        await user.updateDisplayName(displayName);
      }

      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw UnauthorizedUserOperationException();
      }
      throw ServerException();
    } catch (e) {
      if (e is UserNotFoundException ||
          e is UnauthorizedUserOperationException) {
        rethrow;
      }
      throw ServerException();
    }
  }

  Future<UserCredential> linkEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final User? user = firebaseAuth.currentUser;

      if (user == null) {
        throw UserNotFoundException();
      }

      final AuthCredential credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      final UserCredential userCredential = await user.linkWithCredential(
        credential,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw ExistingEmailException();
      } else if (e.code == 'invalid-email') {
        throw InvalidUserDataException();
      } else if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'provider-already-linked') {
        throw UserAlreadyExistsException();
      }
      throw ServerException();
    } catch (e) {
      if (e is UserNotFoundException) rethrow;
      throw ServerException();
    }
  }
}
