import 'package:equatable/equatable.dart';

class PhoneVerificationEntity extends Equatable {
  final String verificationId;
  final String verificationCode;

  const PhoneVerificationEntity({
    required this.verificationId,
    required this.verificationCode,
  });

  @override
  List<Object?> get props => [verificationId, verificationCode];
}
