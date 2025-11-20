import 'package:equatable/equatable.dart';

class ContactEntity extends Equatable {
  final String id;
  final String userId;
  final String contactUserId;
  final DateTime addedAt;
  final bool isFavorite;
  final bool isBlocked;

  const ContactEntity({
    required this.id,
    required this.userId,
    required this.contactUserId,
    required this.addedAt,
    this.isFavorite = false,
    this.isBlocked = false,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    contactUserId,
    addedAt,
    isFavorite,
    isBlocked,
  ];

  ContactEntity copyWith({
    String? id,
    String? userId,
    String? contactUserId,
    DateTime? addedAt,
    bool? isFavorite,
    bool? isBlocked,
  }) {
    return ContactEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contactUserId: contactUserId ?? this.contactUserId,
      addedAt: addedAt ?? this.addedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
