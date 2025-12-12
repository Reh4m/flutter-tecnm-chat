import 'package:equatable/equatable.dart';

enum CallType { audio, video }

enum CallStatus { ringing, connecting, inCall, ended, rejected, missed, failed }

enum CallDirection { incoming, outgoing }

class CallEntity extends Equatable {
  final String id;
  final String callUuid;
  final String callerId;
  final String receiverId;
  final CallType type;
  final CallStatus status;
  final DateTime createdAt;
  final DateTime? answeredAt;
  final DateTime? endedAt;
  final String? conversationId;
  final bool isGroup;
  final List<String>? participants;

  const CallEntity({
    required this.id,
    required this.callUuid,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.status,
    required this.createdAt,
    this.answeredAt,
    this.endedAt,
    this.conversationId,
    this.isGroup = false,
    this.participants,
  });

  @override
  List<Object?> get props => [
    id,
    callUuid,
    callerId,
    receiverId,
    type,
    status,
    createdAt,
    answeredAt,
    endedAt,
    conversationId,
    isGroup,
    participants,
  ];

  Duration? get duration {
    if (answeredAt == null || endedAt == null) return null;
    return endedAt!.difference(answeredAt!);
  }

  bool get isActive =>
      status == CallStatus.ringing ||
      status == CallStatus.connecting ||
      status == CallStatus.inCall;

  bool get isEnded =>
      status == CallStatus.ended ||
      status == CallStatus.rejected ||
      status == CallStatus.missed ||
      status == CallStatus.failed;

  bool get isVideoCall => type == CallType.video;
  bool get isAudioCall => type == CallType.audio;

  CallDirection getCallDirection(String currentUserId) {
    return receiverId == currentUserId
        ? CallDirection.incoming
        : CallDirection.outgoing;
  }

  CallEntity copyWith({
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
    return CallEntity(
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
