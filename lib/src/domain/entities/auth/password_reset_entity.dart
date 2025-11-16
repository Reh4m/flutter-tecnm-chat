import 'package:equatable/equatable.dart';

class PasswordResetEntity extends Equatable {
  final String email;

  const PasswordResetEntity({required this.email});

  @override
  List<Object?> get props => [email];
}
