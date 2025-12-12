import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_whatsapp_clon/src/core/errors/exceptions.dart';
import 'package:flutter_whatsapp_clon/src/data/models/conversations/call_model.dart';
import 'package:flutter_whatsapp_clon/src/domain/entities/conversations/call_entity.dart';

class FirebaseCallService {
  final FirebaseFirestore firestore;

  FirebaseCallService({required this.firestore});

  static const String _callsCollection = 'calls';

  Future<CallModel> createCall(CallModel call) async {
    try {
      final docRef = await firestore
          .collection(_callsCollection)
          .add(call.toFirestore());

      final createdDoc = await docRef.get();
      return CallModel.fromFirestore(createdDoc);
    } catch (e) {
      throw ServerException();
    }
  }

  Future<CallModel> getCallById(String callId) async {
    try {
      final doc =
          await firestore.collection(_callsCollection).doc(callId).get();

      if (!doc.exists) {
        throw CallNotFoundException();
      }

      return CallModel.fromFirestore(doc);
    } catch (e) {
      if (e is CallNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<void> updateCallUuId(String callId, String callUuid) async {
    try {
      await firestore.collection(_callsCollection).doc(callId).update({
        'callUuid': callUuid,
      });
    } catch (e) {
      throw CallOperationFailedException();
    }
  }

  Future<void> updateCallStatus({
    required String callId,
    required CallStatus status,
    DateTime? answeredAt,
    DateTime? endedAt,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'status': _callStatusToString(status),
      };

      if (answeredAt != null) {
        updates['answeredAt'] = Timestamp.fromDate(answeredAt);
      }

      if (endedAt != null) {
        updates['endedAt'] = Timestamp.fromDate(endedAt);
      }

      await firestore.collection(_callsCollection).doc(callId).update(updates);
    } catch (e) {
      throw CallOperationFailedException();
    }
  }

  Future<CallModel> updateCall(CallModel call) async {
    try {
      await firestore
          .collection(_callsCollection)
          .doc(call.id)
          .update(call.toFirestore());

      final updatedDoc =
          await firestore.collection(_callsCollection).doc(call.id).get();

      return CallModel.fromFirestore(updatedDoc);
    } catch (e) {
      throw CallOperationFailedException();
    }
  }

  Future<void> deleteCall(String callId) async {
    try {
      await firestore.collection(_callsCollection).doc(callId).delete();
    } catch (e) {
      throw CallOperationFailedException();
    }
  }

  Stream<List<CallModel>> listenForIncomingCalls(String userId) {
    try {
      return firestore
          .collection(_callsCollection)
          .where('receiverId', isEqualTo: userId)
          .where('status', whereIn: ['ringing', 'connecting'])
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => CallModel.fromFirestore(doc))
                .toList();
          });
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<CallModel> listenToCall(String callId) {
    try {
      return firestore.collection(_callsCollection).doc(callId).snapshots().map(
        (doc) {
          if (!doc.exists) {
            throw CallNotFoundException();
          }
          return CallModel.fromFirestore(doc);
        },
      );
    } catch (e) {
      if (e is CallNotFoundException) rethrow;
      throw ServerException();
    }
  }

  Future<List<CallModel>> getCallHistory({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final callerSnapshot =
          await firestore
              .collection(_callsCollection)
              .where('callerId', isEqualTo: userId)
              .where('status', whereIn: ['ended', 'rejected', 'missed'])
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get();

      final receiverSnapshot =
          await firestore
              .collection(_callsCollection)
              .where('receiverId', isEqualTo: userId)
              .where('status', whereIn: ['ended', 'rejected', 'missed'])
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .get();

      // Combinar resultados
      final Set<String> seenIds = {};
      final List<CallModel> calls = [];

      for (var doc in callerSnapshot.docs) {
        if (!seenIds.contains(doc.id)) {
          calls.add(CallModel.fromFirestore(doc));
          seenIds.add(doc.id);
        }
      }

      for (var doc in receiverSnapshot.docs) {
        if (!seenIds.contains(doc.id)) {
          calls.add(CallModel.fromFirestore(doc));
          seenIds.add(doc.id);
        }
      }

      // Ordenar por fecha
      calls.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return calls.take(limit).toList();
    } catch (e) {
      throw ServerException();
    }
  }

  Stream<List<CallModel>> getCallHistoryStream({
    required String userId,
    int limit = 50,
  }) {
    try {
      // Stream de llamadas donde el usuario es el caller
      final callerStream =
          firestore
              .collection(_callsCollection)
              .where('callerId', isEqualTo: userId)
              .where('status', whereIn: ['ended', 'rejected', 'missed'])
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .snapshots();

      // Stream de llamadas donde el usuario es el receiver
      final receiverStream =
          firestore
              .collection(_callsCollection)
              .where('receiverId', isEqualTo: userId)
              .where('status', whereIn: ['ended', 'rejected', 'missed'])
              .orderBy('createdAt', descending: true)
              .limit(limit)
              .snapshots();

      // Combinar ambos streams
      return callerStream.asyncExpand((callerSnapshot) async* {
        await for (final receiverSnapshot in receiverStream) {
          final Set<String> seenIds = {};
          final List<CallModel> calls = [];

          for (var doc in callerSnapshot.docs) {
            if (!seenIds.contains(doc.id)) {
              calls.add(CallModel.fromFirestore(doc));
              seenIds.add(doc.id);
            }
          }

          for (var doc in receiverSnapshot.docs) {
            if (!seenIds.contains(doc.id)) {
              calls.add(CallModel.fromFirestore(doc));
              seenIds.add(doc.id);
            }
          }

          // Ordenar por fecha
          calls.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          yield calls.take(limit).toList();
        }
      });
    } catch (e) {
      throw ServerException();
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
}
