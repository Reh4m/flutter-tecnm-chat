import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  const ContactModel({
    required super.id,
    required super.userId,
    required super.contactUserId,
    required super.addedAt,
    super.isFavorite,
    super.isBlocked,
  });

  factory ContactModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ContactModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      contactUserId: data['contactUserId'] ?? '',
      addedAt: (data['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isFavorite: data['isFavorite'] ?? false,
      isBlocked: data['isBlocked'] ?? false,
    );
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      contactUserId: map['contactUserId'] ?? '',
      addedAt:
          map['addedAt'] is Timestamp
              ? (map['addedAt'] as Timestamp).toDate()
              : DateTime.tryParse(map['addedAt'] ?? '') ?? DateTime.now(),
      isFavorite: map['isFavorite'] ?? false,
      isBlocked: map['isBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'contactUserId': contactUserId,
      'addedAt': Timestamp.fromDate(addedAt),
      'isFavorite': isFavorite,
      'isBlocked': isBlocked,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'contactUserId': contactUserId,
      'addedAt': addedAt.toIso8601String(),
      'isFavorite': isFavorite,
      'isBlocked': isBlocked,
    };
  }

  factory ContactModel.fromEntity(ContactEntity entity) {
    return ContactModel(
      id: entity.id,
      userId: entity.userId,
      contactUserId: entity.contactUserId,
      addedAt: entity.addedAt,
      isFavorite: entity.isFavorite,
      isBlocked: entity.isBlocked,
    );
  }

  ContactEntity toEntity() {
    return ContactEntity(
      id: id,
      userId: userId,
      contactUserId: contactUserId,
      addedAt: addedAt,
      isFavorite: isFavorite,
      isBlocked: isBlocked,
    );
  }

  @override
  ContactModel copyWith({
    String? id,
    String? userId,
    String? contactUserId,
    DateTime? addedAt,
    bool? isFavorite,
    bool? isBlocked,
  }) {
    return ContactModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      contactUserId: contactUserId ?? this.contactUserId,
      addedAt: addedAt ?? this.addedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }
}
