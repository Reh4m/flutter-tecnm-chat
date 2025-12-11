import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:uuid/uuid.dart';

enum CallRole { caller, receiver }

enum CallState { idle, ringing, connecting, inCall, ended, error }

class WebRTCService {
  final FirebaseDatabase firebaseDatabase;

  final Map<String, dynamic> _configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302',
        ],
      },
    ],
  };

  final Map<String, dynamic> _constraints = {
    'mandatory': {'OfferToReceiveAudio': true, 'OfferToReceiveVideo': true},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  DatabaseReference? _callRef;
  DatabaseReference? _callerCandidatesRef;
  DatabaseReference? _receiverCandidatesRef;

  final _remoteStreamController = StreamController<MediaStream>.broadcast();
  final _localStreamController = StreamController<MediaStream?>.broadcast();
  final _callStateController = StreamController<CallState>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  String? _callId;
  CallRole? _role;

  WebRTCService({required this.firebaseDatabase}) {
    _callStateController.add(CallState.idle);
  }

  Stream<MediaStream> get remoteStreamStream => _remoteStreamController.stream;
  Stream<MediaStream?> get localStreamStream => _localStreamController.stream;
  Stream<CallState> get onCallState => _callStateController.stream;
  Stream<String> get onError => _errorController.stream;

  String? get currentCallId => _callId;
  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;
  RTCPeerConnection? get peerConnection => _peerConnection;

  Future<void> initializePeerConnection() async {
    try {
      _peerConnection = await createPeerConnection(
        _configuration,
        _constraints,
      );

      _peerConnection!.onTrack = (RTCTrackEvent event) async {
        if (event.streams.isNotEmpty) {
          _remoteStream = event.streams[0];
          _remoteStreamController.add(_remoteStream!);
        } else {
          if (_remoteStream == null) {
            _remoteStream = await createLocalMediaStream(
              'remote-${const Uuid().v4()}',
            );
          }
          _remoteStream!.addTrack(event.track);
          _remoteStreamController.add(_remoteStream!);
        }
      };

      _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) async {
        try {
          final Map<String, dynamic> json = {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          };
          if (_role == CallRole.caller) {
            await _callerCandidatesRef?.push().set(json);
          } else {
            await _receiverCandidatesRef?.push().set(json);
          }
        } catch (e) {
          _errorController.add('Failed to push local ICE candidate: $e');
        }
      };

      _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
        if (kDebugMode) {
          print("[webrtc] ICE connection state: $state");
        }
        if (state == RTCIceConnectionState.RTCIceConnectionStateConnected) {
          _callStateController.add(CallState.inCall);
        } else if (state ==
                RTCIceConnectionState.RTCIceConnectionStateDisconnected ||
            state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
          _callStateController.add(CallState.ended);
        }
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<MediaStream> getUserMedia({
    required bool video,
    required bool audio,
  }) async {
    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': audio,
        'video':
            video
                ? {
                  'facingMode': 'user',
                  'width': {'ideal': 1280},
                  'height': {'ideal': 720},
                }
                : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );

      _localStreamController.add(_localStream);

      _localStream!.getTracks().forEach((track) {
        _peerConnection!.addTrack(track, _localStream!);
      });

      return _localStream!;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createCall({
    required String callerUid,
    required String receiverUid,
    required bool isVideo,
  }) async {
    try {
      _role = CallRole.caller;
      _callId = const Uuid().v4();

      _callRef = firebaseDatabase.ref('calls/$_callId');
      _callerCandidatesRef = _callRef!.child('callerCandidates');
      _receiverCandidatesRef = _callRef!.child('receiverCandidates');

      await _callRef!.set({
        'type': 'offer',
        'from': callerUid,
        'to': receiverUid,
        'isVideo': isVideo,
        'createdAt': ServerValue.timestamp,
        'callState': 'ringing',
      });

      await initializePeerConnection();

      if (_localStream == null) {
        await getUserMedia(audio: true, video: isVideo);
      } else {
        _localStream!.getTracks().forEach((track) {
          _peerConnection!.addTrack(track, _localStream!);
        });
      }

      RTCSessionDescription offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      await _callRef!.update({
        'sdp': {'type': offer.type, 'sdp': offer.sdp},
      });

      _listenForRemoteAnswerAndCandidates();

      _callStateController.add(CallState.connecting);

      return _callId!;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createAnswer({
    required String callId,
    required String receiverUid,
    required bool isVideo,
  }) async {
    try {
      _role = CallRole.receiver;
      _callId = callId;

      _callRef = firebaseDatabase.ref('calls/$_callId');
      _callerCandidatesRef = _callRef!.child('callerCandidates');
      _receiverCandidatesRef = _callRef!.child('receiverCandidates');

      final snapshot = await _callRef!.get();
      if (!snapshot.exists) {
        throw Exception('Call not found for id: $_callId');
      }

      final data = snapshot.value as Map<dynamic, dynamic>? ?? {};
      final sdpNode = data['sdp'] as Map<dynamic, dynamic>?;

      if (sdpNode == null) {
        throw Exception('Offer SDP not found for callId $_callId');
      }

      final offerSdp = sdpNode['sdp'] as String;
      final offerType = sdpNode['type'] as String;

      await initializePeerConnection();

      if (_localStream == null) {
        await getUserMedia(audio: true, video: isVideo);
      } else {
        _localStream!.getTracks().forEach((track) {
          _peerConnection!.addTrack(track, _localStream!);
        });
      }

      await _peerConnection!.setRemoteDescription(
        RTCSessionDescription(offerSdp, offerType),
      );

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      await _callRef!.update({
        'type': 'answer',
        'sdp': {'type': answer.type, 'sdp': answer.sdp},
        'callState': 'in_call',
      });

      // start listening for remote ICE candidates (caller -> callee)
      _listenForRemoteAnswerAndCandidates();

      _callStateController.add(CallState.inCall);
    } catch (e) {
      rethrow;
    }
  }

  void _listenForRemoteAnswerAndCandidates() {
    if (_callRef == null) return;

    _callRef!.onValue.listen((event) async {
      final snapshot = event.snapshot;
      if (!snapshot.exists) return;
      final data = snapshot.value as Map<dynamic, dynamic>? ?? {};

      if (_role == CallRole.caller) {
        final sdpNode = data['sdp'] as Map<dynamic, dynamic>?;
        final type = sdpNode?['type'] as String?;
        final sdp = sdpNode?['sdp'] as String?;
        if (type != null && sdp != null && type.toLowerCase() == 'answer') {
          try {
            await _peerConnection?.setRemoteDescription(
              RTCSessionDescription(sdp, type),
            );
            _callStateController.add(CallState.inCall);
          } catch (e) {
            _errorController.add('Failed to set remote answer: $e');
          }
        }
      }

      final callState = data['callState'] as String?;
      if (callState != null && callState == 'ended') {
        _callStateController.add(CallState.ended);
      }
    });

    _callerCandidatesRef?.onChildAdded.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return;
      final candidate = data['candidate'] as String?;
      final sdpMid = data['sdpMid'] as String?;
      final sdpMLineIndex = data['sdpMLineIndex'] as int?;
      if (candidate != null) {
        final ice = RTCIceCandidate(candidate, sdpMid, sdpMLineIndex);
        _peerConnection?.addCandidate(ice);
      }
    });

    _receiverCandidatesRef?.onChildAdded.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return;
      final candidate = data['candidate'] as String?;
      final sdpMid = data['sdpMid'] as String?;
      final sdpMLineIndex = data['sdpMLineIndex'] as int?;
      if (candidate != null) {
        final ice = RTCIceCandidate(candidate, sdpMid, sdpMLineIndex);
        _peerConnection?.addCandidate(ice);
      }
    });
  }

  Future<void> addRemoteIceCandidate(Map<String, dynamic> candidateJson) async {
    try {
      final candidate = RTCIceCandidate(
        candidateJson['candidate'] as String?,
        candidateJson['sdpMid'] as String?,
        candidateJson['sdpMLineIndex'] as int?,
      );
      await _peerConnection!.addCandidate(candidate);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> hangUp({bool deleteCallFromServer = true}) async {
    try {
      await _callRef?.update({'callState': 'ended'});
    } catch (_) {}

    if (deleteCallFromServer && _callRef != null) {
      try {
        await _callRef!.remove();
      } catch (e) {}
    }

    // Close peer connection & local stream
    await _peerConnection?.close();
    _peerConnection = null;

    try {
      await _localStream?.dispose();
    } catch (_) {}

    _localStream = null;
    _remoteStream = null;

    try {
      await _callerCandidatesRef?.onChildAdded.drain();
    } catch (_) {}
    try {
      await _receiverCandidatesRef?.onChildAdded.drain();
    } catch (_) {}

    _callRef = null;
    _callerCandidatesRef = null;
    _receiverCandidatesRef = null;
    _callId = null;
    _role = null;

    _callStateController.add(CallState.ended);
  }

  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  void toggleMute() {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
    }
  }

  void toggleVideo() {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = !videoTrack.enabled;
    }
  }

  Future<void> toggleSpeaker(bool enable) async {
    if (_localStream != null) {
      await Helper.setSpeakerphoneOn(enable);
    }
  }

  Future<void> dispose() async {
    try {
      await hangUp(deleteCallFromServer: false);
      await _remoteStreamController.close();
      await _localStreamController.close();
      await _callStateController.close();
      await _errorController.close();
    } catch (e) {
      rethrow;
    }
  }
}
