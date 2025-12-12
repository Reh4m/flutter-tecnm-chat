import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_whatsapp_clon/src/core/constants/error_messages.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart';
import 'package:flutter_whatsapp_clon/src/core/di/index.dart' as di;
import 'package:flutter_whatsapp_clon/src/core/errors/failures.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/call_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/user/user_entity.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/conversations/call_usecases.dart';
import 'package:flutter_whatsapp_clon/src/domain/usecases/user/user_usecases.dart';

enum CallProviderState { initial, loading, calling, inCall, ended, error }

enum CallHistoryState { initial, loading, success, error }

class CallProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = di.sl<FirebaseAuth>();

  final InitializePeerConnectionUseCase _initializePeerConnectionUseCase =
      sl<InitializePeerConnectionUseCase>();
  final GetUserMediaUseCase _getUserMediaUseCase = sl<GetUserMediaUseCase>();
  final CreateCallUseCase _createCallUseCase = sl<CreateCallUseCase>();
  final CreateGroupCallUseCase _createGroupCallUseCase =
      sl<CreateGroupCallUseCase>();
  final AnswerCallUseCase _answerCallUseCase = sl<AnswerCallUseCase>();
  final RejectCallUseCase _rejectCallUseCase = sl<RejectCallUseCase>();
  final EndCallUseCase _endCallUseCase = sl<EndCallUseCase>();
  final GetRemoteStreamUseCase _getRemoteStreamUseCase =
      sl<GetRemoteStreamUseCase>();
  final GetLocalStreamUseCase _getLocalStreamUseCase =
      sl<GetLocalStreamUseCase>();
  final GetCallStateStreamUseCase _getCallStateStreamUseCase =
      sl<GetCallStateStreamUseCase>();
  final ListenForIncomingCallsUseCase _listenForIncomingCallsUseCase =
      sl<ListenForIncomingCallsUseCase>();
  final ToggleMuteUseCase _toggleMuteUseCase = sl<ToggleMuteUseCase>();
  final ToggleVideoUseCase _toggleVideoUseCase = sl<ToggleVideoUseCase>();
  final SwitchCameraUseCase _switchCameraUseCase = sl<SwitchCameraUseCase>();
  final ToggleSpeakerUseCase _toggleSpeakerUseCase = sl<ToggleSpeakerUseCase>();
  final GetCallHistoryStreamUseCase _getCallHistoryStreamUseCase =
      sl<GetCallHistoryStreamUseCase>();
  final DisposeWebRTCUseCase _disposeWebRTCUseCase = sl<DisposeWebRTCUseCase>();
  final GetUserByIdUseCase _getUserByIdUseCase = sl<GetUserByIdUseCase>();

  // State
  CallProviderState _callState = CallProviderState.initial;
  CallEntity? _currentCall;
  String? _callErrorMesssage;

  // Media Streams
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  // Stream Subscriptions
  StreamSubscription? _remoteStreamSubscription;
  StreamSubscription? _localStreamSubscription;
  StreamSubscription? _callStateSubscription;
  StreamSubscription? _incomingCallsSubscription;
  StreamSubscription? _callDocumentSubscription;
  StreamSubscription? _callHistorySubscription;

  // Call Controls State
  bool _isMuted = false;
  bool _isVideoEnable = true;
  bool _isSpeakerEnabled = false;

  // Call History
  List<CallEntity> _callHistory = [];
  final Map<String, UserEntity> _callHistoryUsers = {};
  CallHistoryState _historyState = CallHistoryState.initial;
  String? _historyErrorMessage;

  // Getters
  CallProviderState get state => _callState;
  CallEntity? get currentCall => _currentCall;
  String? get callErrorMessage => _callErrorMesssage;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  bool get isMuted => _isMuted;
  bool get isVideoEnable => _isVideoEnable;
  bool get isSpeakerEnabled => _isSpeakerEnabled;
  List<CallEntity> get callHistory => _callHistory;
  Map<String, UserEntity> get callHistoryUsers => _callHistoryUsers;
  CallHistoryState get callHistoryState => _historyState;
  String? get callHistoryErrorMessage => _historyErrorMessage;

  bool get isInCall =>
      _callState == CallProviderState.calling ||
      _callState == CallProviderState.inCall;

  void initialize() {
    final currentUserId = firebaseAuth.currentUser?.uid;

    if (currentUserId != null) {
      _startIncomingCallsListener(currentUserId);
    }
  }

  void _startIncomingCallsListener(String userId) {
    _incomingCallsSubscription?.cancel();

    _incomingCallsSubscription = _listenForIncomingCallsUseCase(userId).listen((
      either,
    ) {
      either.fold(
        (failure) {
          _setCallError(_mapFailureToMessage(failure));
        },
        (call) {
          // Solo notificar si no hay una llamada activa
          if (!isInCall) {
            _currentCall = call;
            _setCallState(CallProviderState.calling);
          }
        },
      );
    });
  }

  void startCallHistoryListener(String userId) {
    _setHistoryState(CallHistoryState.loading);

    _callHistorySubscription?.cancel();

    _callHistorySubscription = _getCallHistoryStreamUseCase(
      userId: userId,
      limit: 50,
    ).listen((either) {
      either.fold(
        (failure) {
          _historyErrorMessage = _mapFailureToMessage(failure);
        },
        (calls) async {
          _callHistory = calls;

          await _loadCallHistoryUsers(calls);

          _setHistoryState(CallHistoryState.success);
        },
      );
    });
  }

  Future<void> _loadCallHistoryUsers(List<CallEntity> calls) async {
    final currentUserId = firebaseAuth.currentUser?.uid;

    if (currentUserId == null) return;

    for (final call in calls) {
      final otherUserId =
          call.callerId == currentUserId ? call.receiverId : call.callerId;

      final result = await _getUserByIdUseCase(otherUserId);

      result.fold((_) => null, (user) => _callHistoryUsers[call.id] = user);
    }
  }

  void stopCallHistoryListener() {
    _callHistorySubscription?.cancel();
    _callHistorySubscription = null;
  }

  Future<bool> createCall({
    required String receiverId,
    required CallType type,
    String? conversationId,
  }) async {
    _setCallState(CallProviderState.loading);

    final currentUserId = firebaseAuth.currentUser?.uid;
    if (currentUserId == null) {
      _setCallError('Usuario no autenticado');
      return false;
    }

    // Inicializar peer connection
    final initResult = await _initializePeerConnectionUseCase();
    if (initResult.isLeft()) {
      _setCallError('Error al inicializar la conexión');
      return false;
    }

    // Obtener medios locales
    final mediaResult = await _getUserMediaUseCase(
      isAudioEnable: true,
      isVideoEnable: type == CallType.video,
    );

    final mediaSuccess = mediaResult.fold(
      (failure) {
        _setCallError(_mapFailureToMessage(failure));
        return false;
      },
      (stream) {
        _localStream = stream;
        return true;
      },
    );

    if (!mediaSuccess) return false;

    // Crear la llamada
    final result = await _createCallUseCase(
      callerId: currentUserId,
      receiverId: receiverId,
      type: type,
      conversationId: conversationId,
    );

    return result.fold(
      (failure) {
        _setCallError(_mapFailureToMessage(failure));
        return false;
      },
      (call) {
        _currentCall = call;
        _setCallState(CallProviderState.calling);
        _startMediaStreamsListeners();
        _startCallStateListener();
        // _startCallDocumentListener(call.id);
        return true;
      },
    );
  }

  Future<bool> createGroupCall({
    required String groupId,
    required List<String> participants,
    required CallType type,
  }) async {
    _setCallState(CallProviderState.loading);

    final currentUserId = firebaseAuth.currentUser?.uid;
    if (currentUserId == null) {
      _setCallError('Usuario no autenticado');
      return false;
    }

    // Inicializar peer connection
    final initResult = await _initializePeerConnectionUseCase();
    if (initResult.isLeft()) {
      _setCallError('Error al inicializar la conexión');
      return false;
    }

    // Obtener medios locales
    final mediaResult = await _getUserMediaUseCase(
      isAudioEnable: true,
      isVideoEnable: type == CallType.video,
    );

    final mediaSuccess = mediaResult.fold(
      (failure) {
        _setCallError(_mapFailureToMessage(failure));
        return false;
      },
      (stream) {
        _localStream = stream;
        return true;
      },
    );

    if (!mediaSuccess) return false;

    // Crear la llamada grupal
    final result = await _createGroupCallUseCase(
      callerId: currentUserId,
      groupId: groupId,
      participants: participants,
      type: type,
    );

    return result.fold(
      (failure) {
        _setCallError(_mapFailureToMessage(failure));
        return false;
      },
      (call) {
        _currentCall = call;
        _setCallState(CallProviderState.calling);
        _startMediaStreamsListeners();
        _startCallStateListener();
        // _startCallDocumentListener(call.id);
        return true;
      },
    );
  }

  Future<bool> answerCall({required bool withVideo}) async {
    if (_currentCall == null) return false;

    _setCallState(CallProviderState.loading);

    // Inicializar peer connection
    final initResult = await _initializePeerConnectionUseCase();
    if (initResult.isLeft()) {
      _setCallError('Error al inicializar la conexión');
      return false;
    }

    // Obtener medios locales
    final mediaResult = await _getUserMediaUseCase(
      isAudioEnable: true,
      isVideoEnable: withVideo,
    );

    final mediaSuccess = mediaResult.fold(
      (failure) {
        _setCallError(_mapFailureToMessage(failure));
        return false;
      },
      (stream) {
        _localStream = stream;
        _isVideoEnable = withVideo;
        return true;
      },
    );

    if (!mediaSuccess) return false;

    // Responder la llamada
    final result = await _answerCallUseCase(
      callId: _currentCall!.id,
      withVideo: withVideo,
    );

    return result.fold(
      (failure) {
        _setCallError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _setCallState(CallProviderState.inCall);
        _startMediaStreamsListeners();
        _startCallStateListener();
        // _startCallDocumentListener(_currentCall!.id);
        return true;
      },
    );
  }

  void _startMediaStreamsListeners() {
    // Remote stream
    _remoteStreamSubscription?.cancel();
    _remoteStreamSubscription = _getRemoteStreamUseCase().listen((either) {
      either.fold((failure) => _setCallError(_mapFailureToMessage(failure)), (
        stream,
      ) {
        _remoteStream = stream;
        notifyListeners();
      });
    });

    // Local stream
    _localStreamSubscription?.cancel();
    _localStreamSubscription = _getLocalStreamUseCase().listen((either) {
      either.fold((failure) => _setCallError(_mapFailureToMessage(failure)), (
        stream,
      ) {
        _localStream = stream;
        notifyListeners();
      });
    });
  }

  void _startCallStateListener() {
    _callStateSubscription?.cancel();
    _callStateSubscription = _getCallStateStreamUseCase().listen((either) {
      either.fold((failure) => _setCallError(_mapFailureToMessage(failure)), (
        status,
      ) {
        switch (status) {
          case CallStatus.ringing:
            _setCallState(CallProviderState.calling);
            break;
          case CallStatus.connecting:
            _setCallState(CallProviderState.calling);
            break;
          case CallStatus.inCall:
            _setCallState(CallProviderState.inCall);
            break;
          case CallStatus.ended:
          case CallStatus.rejected:
          case CallStatus.missed:
          case CallStatus.failed:
            _cleanupCall();
            break;
        }
      });
    });
  }

  Future<bool> rejectCall() async {
    if (_currentCall == null) return false;

    final result = await _rejectCallUseCase(
      callId: _currentCall!.id,
      callUuid: _currentCall!.callUuid,
    );

    return result.fold(
      (failure) {
        _setCallError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _cleanupCall();
        return true;
      },
    );
  }

  Future<bool> endCall() async {
    if (_currentCall == null) return false;

    final result = await _endCallUseCase(
      callId: _currentCall!.id,
      callUuid: _currentCall!.callUuid,
    );

    return result.fold(
      (failure) {
        _setCallError(_mapFailureToMessage(failure));
        return false;
      },
      (_) {
        _cleanupCall();
        return true;
      },
    );
  }

  Future<void> toggleMute() async {
    final result = await _toggleMuteUseCase();

    result.fold((failure) => _setCallError(_mapFailureToMessage(failure)), (_) {
      _isMuted = !_isMuted;
      notifyListeners();
    });
  }

  Future<void> toggleVideo() async {
    final result = await _toggleVideoUseCase();

    result.fold((failure) => _setCallError(_mapFailureToMessage(failure)), (_) {
      _isVideoEnable = !_isVideoEnable;
      notifyListeners();
    });
  }

  Future<void> switchCamera() async {
    final result = await _switchCameraUseCase();

    result.fold(
      (failure) => _setCallError(_mapFailureToMessage(failure)),
      (_) => notifyListeners(),
    );
  }

  Future<void> toggleSpeaker() async {
    final newState = !_isSpeakerEnabled;
    final result = await _toggleSpeakerUseCase(newState);

    result.fold((failure) => _setCallError(_mapFailureToMessage(failure)), (_) {
      _isSpeakerEnabled = newState;
      notifyListeners();
    });
  }

  void _cleanupCall() {
    _remoteStreamSubscription?.cancel();
    _localStreamSubscription?.cancel();
    _callStateSubscription?.cancel();
    _callDocumentSubscription?.cancel();

    _localStream = null;
    _remoteStream = null;
    _currentCall = null;
    _isMuted = false;
    _isVideoEnable = true;
    _isSpeakerEnabled = false;

    _setCallState(CallProviderState.ended);

    // Dispose WebRTC
    _disposeWebRTCUseCase();
  }

  void _setCallState(CallProviderState newState) {
    _callState = newState;
    if (newState != CallProviderState.error) {
      _callErrorMesssage = null;
    }
    notifyListeners();
  }

  void _setHistoryState(CallHistoryState newState) {
    _historyState = newState;
    if (newState != CallHistoryState.error) {
      _historyErrorMessage = null;
    }
    notifyListeners();
  }

  void _setCallError(String message) {
    _callErrorMesssage = message;
    _setCallState(CallProviderState.error);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (NetworkFailure):
        return ErrorMessages.networkError;
      case const (CallNotFoundFailure):
        return ErrorMessages.callNotFound;
      case const (CallAlreadyActiveFailure):
        return ErrorMessages.callAlreadyActive;
      case const (CallConnectionFailedFailure):
        return ErrorMessages.callConnectionFailed;
      case const (MediaPermissionDeniedFailure):
        return ErrorMessages.mediaPermissionDenied;
      case const (WebRTCNotInitializedFailure):
        return ErrorMessages.webrtcNotInitialized;
      case const (CallOperationFailedFailure):
        return ErrorMessages.callOperationFailed;
      default:
        return ErrorMessages.serverError;
    }
  }

  @override
  void dispose() {
    _incomingCallsSubscription?.cancel();
    _remoteStreamSubscription?.cancel();
    _localStreamSubscription?.cancel();
    _callStateSubscription?.cancel();
    _callHistorySubscription?.cancel();
    _callDocumentSubscription?.cancel();
    _cleanupCall();
    super.dispose();
  }
}
