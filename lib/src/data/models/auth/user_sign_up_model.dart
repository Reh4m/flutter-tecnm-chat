import 'package:flutter_whatsapp_clon/src/domain/entities/auth/user_sign_up_entity.dart';

class UserSignUpModel extends UserSignUpEntity {
  const UserSignUpModel({
    required super.name,
    required super.email,
    super.photoUrl,
    required super.password,
    required super.confirmPassword,
  });
}
