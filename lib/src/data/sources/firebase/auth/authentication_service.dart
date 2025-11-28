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
}
