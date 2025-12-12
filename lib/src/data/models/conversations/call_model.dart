import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/call_entity.dart';

class CallModel extends CallEntity {
  const CallModel({
    required super.id,
    required super.callUuid,
    required super.callerId,
    required super.receiverId,
    required super.type,
    required super.status,
    required super.createdAt,
    super.answeredAt,
    super.endedAt,
    super.conversationId,
    super.isGroup,
    super.participants,
  });

  factory CallModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CallModel(
      id: doc.id,
      callUuid: data['callUuid'] ?? '',
      callerId: data['callerId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      type: _parseCallType(data['type']),
      status: _parseCallStatus(data['status']),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      answeredAt: (data['answeredAt'] as Timestamp?)?.toDate(),
      endedAt: (data['endedAt'] as Timestamp?)?.toDate(),
      conversationId: data['conversationId'],
      isGroup: data['isGroup'] ?? false,
      participants:
          data['participants'] != null
              ? List<String>.from(data['participants'])
              : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'callUuid': callUuid,
      'callerId': callerId,
      'receiverId': receiverId,
      'type': _callTypeToString(type),
      'status': _callStatusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'answeredAt': answeredAt != null ? Timestamp.fromDate(answeredAt!) : null,
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'conversationId': conversationId,
      'isGroup': isGroup,
      'participants': participants,
    };
  }

  static CallType _parseCallType(String? type) {
    switch (type) {
      case 'audio':
        return CallType.audio;
      case 'video':
        return CallType.video;
      default:
        return CallType.video;
    }
  }

  static String _callTypeToString(CallType type) {
    switch (type) {
      case CallType.audio:
        return 'audio';
      case CallType.video:
        return 'video';
    }
  }

  static CallStatus _parseCallStatus(String? status) {
    switch (status) {
      case 'ringing':
        return CallStatus.ringing;
      case 'connecting':
        return CallStatus.connecting;
      case 'inCall':
        return CallStatus.inCall;
      case 'ended':
        return CallStatus.ended;
      case 'rejected':
        return CallStatus.rejected;
      case 'missed':
        return CallStatus.missed;
      case 'failed':
        return CallStatus.failed;
      default:
        return CallStatus.ringing;
    }
  }

  static String _callStatusToString(CallStatus status) {
    switch (status) {
      case CallStatus.ringing:
        return 'ringing';
      case CallStatus.connecting:
        return 'connecting';
      case CallStatus.inCall:
        return 'inCall';
      case CallStatus.ended:
        return 'ended';
      case CallStatus.rejected:
        return 'rejected';
      case CallStatus.missed:
        return 'missed';
      case CallStatus.failed:
        return 'failed';
    }
  }

  factory CallModel.fromEntity(CallEntity entity) {
    return CallModel(
      id: entity.id,
      callUuid: entity.callUuid,
      callerId: entity.callerId,
      receiverId: entity.receiverId,
      type: entity.type,
      status: entity.status,
      createdAt: entity.createdAt,
      answeredAt: entity.answeredAt,
      endedAt: entity.endedAt,
      conversationId: entity.conversationId,
      isGroup: entity.isGroup,
      participants: entity.participants,
    );
  }

  CallEntity toEntity() {
    return CallEntity(
      id: id,
      callUuid: callUuid,
      callerId: callerId,
      receiverId: receiverId,
      type: type,
      status: status,
      createdAt: createdAt,
      answeredAt: answeredAt,
      endedAt: endedAt,
      conversationId: conversationId,
      isGroup: isGroup,
      participants: participants,
    );
  }

  @override
  CallModel copyWith({
    String? id,
    String? callUuid,
    String? callerId,
    String? receiverId,
    CallType? type,
    CallStatus? status,
    CallDirection? direction,
    DateTime? createdAt,
    DateTime? answeredAt,
    DateTime? endedAt,
    String? conversationId,
    bool? isGroup,
    List<String>? participants,
  }) {
    return CallModel(
      id: id ?? this.id,
      callUuid: callUuid ?? this.callUuid,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      answeredAt: answeredAt ?? this.answeredAt,
      endedAt: endedAt ?? this.endedAt,
      conversationId: conversationId ?? this.conversationId,
      isGroup: isGroup ?? this.isGroup,
      participants: participants ?? this.participants,
    );
  }
}
