import 'package:dartz/dartz.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/core/network/network_info.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/call_model.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/firebase/conversations/call_service.dart';
import 'package:flutter_whatsapp_clon/src/data/sources/webrtc/webrtc_service.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/call_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/repositories/conversations/call_repository.dart';

class CallRepositoryImpl implements CallRepository {
  final WebRTCService webrtcService;
  final FirebaseCallService callService;
  final NetworkInfo networkInfo;

  CallRepositoryImpl({
    required this.webrtcService,
    required this.callService,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Unit>> initializePeerConnection() async {
    try {
      await webrtcService.initializePeerConnection();
      return const Right(unit);
    } catch (e) {
      return Left(WebRTCNotInitializedFailure());
    }
  }

  @override
  Future<Either<Failure, MediaStream>> getUserMedia({
    required bool isAudioEnable,
    required bool isVideoEnable,
  }) async {
    try {
      final stream = await webrtcService.getUserMedia(
        isAudioEnable: isAudioEnable,
        isVideoEnable: isVideoEnable,
      );
      return Right(stream);
    } catch (e) {
      return Left(MediaPermissionDeniedFailure());
    }
  }

  @override
  Future<Either<Failure, CallEntity>> createCall({
    required String callerId,
    required String receiverId,
    required CallType type,
    String? conversationId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      // Crear registro de llamada en Firestore
      final call = CallModel(
        id: '',
        callUuid: '',
        callerId: callerId,
        receiverId: receiverId,
        type: type,
        status: CallStatus.ringing,
        createdAt: DateTime.now(),
        conversationId: conversationId,
        isGroup: false,
      );

      final createdCall = await callService.createCall(call);

      // Inicializar WebRTC
      final callUuid = await webrtcService.createCall(
        callerUid: callerId,
        receiverUid: receiverId,
        isVideoCall: type == CallType.video,
      );

      // Actualizar con el callUuid de WebRTC si es diferente
      if (callUuid != createdCall.id) {
        await callService.updateCallUuId(createdCall.id, callUuid);
      }

      return Right(createdCall.toEntity());
    } on CallAlreadyActiveException {
      return Left(CallAlreadyActiveFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(CallConnectionFailedFailure());
    }
  }

  @override
  Future<Either<Failure, CallEntity>> createGroupCall({
    required String callerId,
    required String groupId,
    required List<String> participants,
    required CallType type,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      // Crear registro de llamada grupal en Firestore
      final call = CallModel(
        id: '',
        callUuid: '',
        callerId: callerId,
        receiverId: groupId, // El groupId actúa como receiverId
        type: type,
        status: CallStatus.ringing,
        createdAt: DateTime.now(),
        conversationId: groupId,
        isGroup: true,
        participants: participants,
      );

      final createdCall = await callService.createCall(call);

      // Para llamadas grupales, se creará una conexión peer-to-peer con cada participante
      // Esto se manejará en la capa de presentación

      return Right(createdCall.toEntity());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(CallConnectionFailedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> answerCall({
    required String callId,
    required bool withVideo,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      // Obtener información de la llamada
      final call = await callService.getCallById(callId);

      // Responder con WebRTC
      await webrtcService.createAnswer(
        callUuid: call.callUuid,
        receiverUid: call.receiverId,
        isVideoCall: withVideo,
      );

      // Actualizar estado en Firestore
      await callService.updateCallStatus(
        callId: callId,
        status: CallStatus.inCall,
        answeredAt: DateTime.now(),
      );

      return const Right(unit);
    } on CallNotFoundException {
      return Left(CallNotFoundFailure());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(CallConnectionFailedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> rejectCall({
    required String callId,
    required String callUuid,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await callService.updateCallStatus(
        callId: callId,
        status: CallStatus.rejected,
        endedAt: DateTime.now(),
      );

      // Finalizar WebRTC si estaba inicializado
      if (webrtcService.currentCallUuid == callUuid) {
        await webrtcService.hangUp(deleteCallFromServer: false);
      }

      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(CallOperationFailedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> endCall({
    required String callId,
    required String callUuid,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      await callService.updateCallStatus(
        callId: callId,
        status: CallStatus.ended,
        endedAt: DateTime.now(),
      );

      // Finalizar WebRTC
      if (webrtcService.currentCallUuid == callUuid) {
        await webrtcService.hangUp(deleteCallFromServer: false);
      }

      return const Right(unit);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(CallOperationFailedFailure());
    }
  }

  @override
  Stream<Either<Failure, MediaStream>> getRemoteStream() async* {
    try {
      await for (final stream in webrtcService.remoteStreamStream) {
        yield Right(stream);
      }
    } catch (e) {
      yield Left(WebRTCNotInitializedFailure());
    }
  }

  @override
  Stream<Either<Failure, MediaStream?>> getLocalStream() async* {
    try {
      await for (final stream in webrtcService.localStreamStream) {
        yield Right(stream);
      }
    } catch (e) {
      yield Left(WebRTCNotInitializedFailure());
    }
  }

  @override
  Stream<Either<Failure, CallStatus>> getCallStateStream() async* {
    try {
      await for (final state in webrtcService.onCallState) {
        yield Right(_mapWebRTCStateToCallStatus(state));
      }
    } catch (e) {
      yield Left(WebRTCNotInitializedFailure());
    }
  }

  CallStatus _mapWebRTCStateToCallStatus(WebRTCCallState state) {
    switch (state) {
      case WebRTCCallState.idle:
        return CallStatus.ended;
      case WebRTCCallState.ringing:
        return CallStatus.ringing;
      case WebRTCCallState.connecting:
        return CallStatus.connecting;
      case WebRTCCallState.inCall:
        return CallStatus.inCall;
      case WebRTCCallState.ended:
        return CallStatus.ended;
      case WebRTCCallState.error:
        return CallStatus.failed;
    }
  }

  @override
  Stream<Either<Failure, CallEntity>> listenForIncomingCalls(
    String userId,
  ) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }
    try {
      await for (final calls in callService.listenForIncomingCalls(userId)) {
        if (calls.isNotEmpty) {
          // Emitir la primera llamada entrante
          yield Right(calls.first.toEntity());
        }
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (!errorMsg.contains('bad state') && !errorMsg.contains('no element')) {
        yield Left(ServerFailure());
      }
    }
  }

  @override
  Stream<Either<Failure, CallEntity>> listenToCall(String callId) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final call in callService.listenToCall(callId)) {
        yield Right(call.toEntity());
      }
    } on CallNotFoundException {
      yield Left(CallNotFoundFailure());
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (!errorMsg.contains('bad state') && !errorMsg.contains('no element')) {
        yield Left(ServerFailure());
      }
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleMute() async {
    try {
      webrtcService.toggleMute();
      return const Right(unit);
    } catch (e) {
      return Left(CallOperationFailedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleVideo() async {
    try {
      webrtcService.toggleVideo();
      return const Right(unit);
    } catch (e) {
      return Left(CallOperationFailedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> switchCamera() async {
    try {
      await webrtcService.switchCamera();
      return const Right(unit);
    } catch (e) {
      return Left(CallOperationFailedFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleSpeaker(bool enable) async {
    try {
      await webrtcService.toggleSpeaker(enable);
      return const Right(unit);
    } catch (e) {
      return Left(CallOperationFailedFailure());
    }
  }

  @override
  Future<Either<Failure, CallEntity?>> getCallById(String callId) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final call = await callService.getCallById(callId);
      return Right(call.toEntity());
    } on CallNotFoundException {
      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<CallEntity>>> getCallHistory({
    required String userId,
    int limit = 50,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }

    try {
      final calls = await callService.getCallHistory(
        userId: userId,
        limit: limit,
      );
      return Right(calls.map((c) => c.toEntity()).toList());
    } on ServerException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<CallEntity>>> getCallHistoryStream({
    required String userId,
    int limit = 50,
  }) async* {
    if (!await networkInfo.isConnected) {
      yield Left(NetworkFailure());
      return;
    }

    try {
      await for (final calls in callService.getCallHistoryStream(
        userId: userId,
        limit: limit,
      )) {
        yield Right(calls.map((c) => c.toEntity()).toList());
      }
    } on ServerException {
      yield Left(ServerFailure());
    } catch (e) {
      yield Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> dispose() async {
    try {
      await webrtcService.dispose();
      return const Right(unit);
    } catch (e) {
      return Left(CallOperationFailedFailure());
    }
  }
}
