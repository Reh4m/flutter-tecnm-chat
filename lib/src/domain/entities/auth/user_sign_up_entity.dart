import 'package:equatable/equatable.dart';

class UserSignUpEntity extends Equatable {
  final String name;
  final String email;
  final String? photoUrl;
  final String password;
  final String confirmPassword;

  const UserSignUpEntity({
    required this.name,
    required this.email,
    this.photoUrl,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [name, email, photoUrl, password, confirmPassword];
}
