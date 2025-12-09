import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PresenceService {
  static final _auth = FirebaseAuth.instance;
  static final _db = FirebaseDatabase.instance;
  static final _firestore = FirebaseFirestore.instance;

  static DatabaseReference? _statusRef;

  /// ✅ Call ONCE after login
  static Future<void> startPresence() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    _statusRef = _db.ref("status/$uid");

    await _statusRef!.set({
      "state": "online",
      "lastChanged": ServerValue.timestamp,
    });

    await _statusRef!.onDisconnect().set({
      "state": "offline",
      "lastChanged": ServerValue.timestamp,
    });

    // ✅ Mirror status into Firestore for UI usage
    _db.ref(".info/connected").onValue.listen((event) {
      final connected = event.snapshot.value == true;
      _firestore.collection("users").doc(uid).set({
        "onlineStatus": connected ? "online" : "offline"
      }, SetOptions(merge: true));
    });
  }

  /// ✅ Call on logout
  static Future<void> stopPresence() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _statusRef == null) return;

    await _statusRef!.set({
      "state": "offline",
      "lastChanged": ServerValue.timestamp,
    });

    await _firestore.collection("users").doc(uid).set({
      "onlineStatus": "offline"
    }, SetOptions(merge: true));
  }
}
