import 'package:flutter_whatsapp_clon/src/domain/entities/auth/sign_up_entity.dart';

class SignUpModel extends SignUpEntity {
  const SignUpModel({
    required super.name,
    required super.email,
    required super.password,
    required super.confirmPassword,
  });
}
