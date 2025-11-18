import 'package:equatable/equatable.dart';

class PhoneAuthEntity extends Equatable {
  final String phoneNumber;

  const PhoneAuthEntity({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}
