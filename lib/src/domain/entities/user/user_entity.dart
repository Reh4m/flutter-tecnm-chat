import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String? phoneNumber;
  final String? bio;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Configuraciones
  final bool notificationsEnabled;
  final bool emailNotificationsEnabled;

  // Estado del usuario
  final bool isActive;
  final bool isVerified;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phoneNumber,
    this.bio,
    required this.createdAt,
    this.updatedAt,
    this.notificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.isActive = true,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    photoUrl,
    phoneNumber,
    bio,
    createdAt,
    updatedAt,
    notificationsEnabled,
    emailNotificationsEnabled,
    isActive,
    isVerified,
  ];

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get hasPhone => phoneNumber != null && phoneNumber!.isNotEmpty;
  bool get hasBio => bio != null && bio!.isNotEmpty;

  String get displayName {
    if (name.isNotEmpty) return name;
    return email.split('@').first;
  }

  String get initials {
    final nameParts = displayName.split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
    String? phoneNumber,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? isActive,
    bool? isVerified,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
