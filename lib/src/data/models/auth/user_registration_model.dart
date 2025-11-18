import 'package:flutter_whatsapp_clon/src/domain/entities/auth/user_registration_entity.dart';

class UserRegistrationModel extends UserRegistrationEntity {
  const UserRegistrationModel({
    required super.name,
    required super.email,
    super.photoUrl,
  });
}
