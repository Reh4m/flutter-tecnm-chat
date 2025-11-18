import 'package:equatable/equatable.dart';

class UserRegistrationEntity extends Equatable {
  final String name;
  final String email;
  final String? photoUrl;

  const UserRegistrationEntity({
    required this.name,
    required this.email,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [name, email, photoUrl];
}
