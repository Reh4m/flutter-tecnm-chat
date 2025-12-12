import 'package:dartz/dartz.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/call_entity.dart';

abstract class CallRepository {
  Future<Either<Failure, Unit>> initializePeerConnection();

  Future<Either<Failure, MediaStream>> getUserMedia({
    required bool isAudioEnable,
    required bool isVideoEnable,
  });

  Future<Either<Failure, CallEntity>> createCall({
    required String callerId,
    required String receiverId,
    required CallType type,
    String? conversationId,
  });

  Future<Either<Failure, CallEntity>> createGroupCall({
    required String callerId,
    required String groupId,
    required List<String> participants,
    required CallType type,
  });

  Future<Either<Failure, Unit>> answerCall({
    required String callId,
    required bool withVideo,
  });

  Future<Either<Failure, Unit>> rejectCall({
    required String callId,
    required String callUuid,
  });

  Future<Either<Failure, Unit>> endCall({
    required String callId,
    required String callUuid,
  });

  Stream<Either<Failure, MediaStream>> getRemoteStream();

  Stream<Either<Failure, MediaStream?>> getLocalStream();

  Stream<Either<Failure, CallEntity>> listenToCall(String callId);

  Stream<Either<Failure, CallStatus>> getCallStateStream();

  Stream<Either<Failure, CallEntity>> listenForIncomingCalls(String userId);

  Future<Either<Failure, Unit>> toggleMute();

  Future<Either<Failure, Unit>> toggleVideo();

  Future<Either<Failure, Unit>> switchCamera();

  Future<Either<Failure, Unit>> toggleSpeaker(bool enable);

  Future<Either<Failure, CallEntity?>> getCallById(String callId);

  Future<Either<Failure, List<CallEntity>>> getCallHistory({
    required String userId,
    int limit = 50,
  });

  Stream<Either<Failure, List<CallEntity>>> getCallHistoryStream({
    required String userId,
    int limit = 50,
  });

  Future<Either<Failure, Unit>> dispose();
}
