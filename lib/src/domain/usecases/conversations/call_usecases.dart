import 'package:dartz/dartz.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/call_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/call_repository.dart';

class InitializePeerConnectionUseCase {
  final CallRepository repository;

  InitializePeerConnectionUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.initializePeerConnection();
  }
}

class GetUserMediaUseCase {
  final CallRepository repository;

  GetUserMediaUseCase(this.repository);

  Future<Either<Failure, MediaStream>> call({
    required bool isAudioEnable,
    required bool isVideoEnable,
  }) async {
    return await repository.getUserMedia(
      isAudioEnable: isAudioEnable,
      isVideoEnable: isVideoEnable,
    );
  }
}

class CreateCallUseCase {
  final CallRepository repository;

  CreateCallUseCase(this.repository);

  Future<Either<Failure, CallEntity>> call({
    required String callerId,
    required String receiverId,
    required CallType type,
    String? conversationId,
  }) async {
    return await repository.createCall(
      callerId: callerId,
      receiverId: receiverId,
      type: type,
      conversationId: conversationId,
    );
  }
}

class CreateGroupCallUseCase {
  final CallRepository repository;

  CreateGroupCallUseCase(this.repository);

  Future<Either<Failure, CallEntity>> call({
    required String callerId,
    required String groupId,
    required List<String> participants,
    required CallType type,
  }) async {
    return await repository.createGroupCall(
      callerId: callerId,
      groupId: groupId,
      participants: participants,
      type: type,
    );
  }
}

class AnswerCallUseCase {
  final CallRepository repository;

  AnswerCallUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String callId,
    required bool withVideo,
  }) async {
    return await repository.answerCall(callId: callId, withVideo: withVideo);
  }
}

class RejectCallUseCase {
  final CallRepository repository;

  RejectCallUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String callId,
    required String callUuid,
  }) async {
    return await repository.rejectCall(callId: callId, callUuid: callUuid);
  }
}

class EndCallUseCase {
  final CallRepository repository;

  EndCallUseCase(this.repository);

  Future<Either<Failure, Unit>> call({
    required String callId,
    required String callUuid,
  }) async {
    return await repository.endCall(callId: callId, callUuid: callUuid);
  }
}

class GetRemoteStreamUseCase {
  final CallRepository repository;

  GetRemoteStreamUseCase(this.repository);

  Stream<Either<Failure, MediaStream>> call() {
    return repository.getRemoteStream();
  }
}

class GetLocalStreamUseCase {
  final CallRepository repository;

  GetLocalStreamUseCase(this.repository);

  Stream<Either<Failure, MediaStream?>> call() {
    return repository.getLocalStream();
  }
}

class GetCallStateStreamUseCase {
  final CallRepository repository;

  GetCallStateStreamUseCase(this.repository);

  Stream<Either<Failure, CallStatus>> call() {
    return repository.getCallStateStream();
  }
}

class ListenForIncomingCallsUseCase {
  final CallRepository repository;

  ListenForIncomingCallsUseCase(this.repository);

  Stream<Either<Failure, CallEntity>> call(String userId) {
    return repository.listenForIncomingCalls(userId);
  }
}

class ListenToCallUseCase {
  final CallRepository repository;

  ListenToCallUseCase(this.repository);

  Stream<Either<Failure, CallEntity>> call(String callId) {
    return repository.listenToCall(callId);
  }
}

class ToggleMuteUseCase {
  final CallRepository repository;

  ToggleMuteUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.toggleMute();
  }
}

class ToggleVideoUseCase {
  final CallRepository repository;

  ToggleVideoUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.toggleVideo();
  }
}

class SwitchCameraUseCase {
  final CallRepository repository;

  SwitchCameraUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.switchCamera();
  }
}

class ToggleSpeakerUseCase {
  final CallRepository repository;

  ToggleSpeakerUseCase(this.repository);

  Future<Either<Failure, Unit>> call(bool enable) async {
    return await repository.toggleSpeaker(enable);
  }
}

class GetCallByIdUseCase {
  final CallRepository repository;

  GetCallByIdUseCase(this.repository);

  Future<Either<Failure, CallEntity?>> call(String callId) async {
    return await repository.getCallById(callId);
  }
}

class GetCallHistoryUseCase {
  final CallRepository repository;

  GetCallHistoryUseCase(this.repository);

  Future<Either<Failure, List<CallEntity>>> call({
    required String userId,
    int limit = 50,
  }) async {
    return await repository.getCallHistory(userId: userId, limit: limit);
  }
}

class GetCallHistoryStreamUseCase {
  final CallRepository repository;

  GetCallHistoryStreamUseCase(this.repository);

  Stream<Either<Failure, List<CallEntity>>> call({
    required String userId,
    int limit = 50,
  }) {
    return repository.getCallHistoryStream(userId: userId, limit: limit);
  }
}

class DisposeWebRTCUseCase {
  final CallRepository repository;

  DisposeWebRTCUseCase(this.repository);

  Future<Either<Failure, Unit>> call() async {
    return await repository.dispose();
  }
}
