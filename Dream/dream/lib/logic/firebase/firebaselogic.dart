// firebaselogic.dart (only relevant ChatService parts - merge with your existing file)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'dart:io' as io;
import 'package:encrypt/encrypt.dart' as encrypt_pkg;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  static final _aesKey = encrypt_pkg.Key.fromUtf8('01234567890123456789012345678901');

  String _encryptBytesToBase64(List<int> bytes) {
    final iv = encrypt_pkg.IV.fromSecureRandom(16);
    final encrypter = encrypt_pkg.Encrypter(encrypt_pkg.AES(_aesKey, mode: encrypt_pkg.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    final combined = <int>[]..addAll(iv.bytes)..addAll(encrypted.bytes);
    return base64Encode(combined);
  }

  Uint8List decryptBase64ToBytes(String encryptedBase64) {
    try {
      final combined = base64Decode(encryptedBase64);
      final ivBytes = combined.sublist(0, 16);
      final cipherBytes = combined.sublist(16);
      final iv = encrypt_pkg.IV(ivBytes);
      final encrypter = encrypt_pkg.Encrypter(encrypt_pkg.AES(_aesKey, mode: encrypt_pkg.AESMode.cbc));
      final decrypted = encrypter.decryptBytes(encrypt_pkg.Encrypted(Uint8List.fromList(cipherBytes)), iv: iv);
      return Uint8List.fromList(decrypted);
    } catch (e) {
      return Uint8List(0);
    }
  }

  Future<String> createChatRoom(String uid1, String uid2) async {
    final ids = [uid1, uid2]..sort();
    final chatId = ids.join('_');
    final doc = await _firestore.collection('chatRooms').doc(chatId).get();
    if (!doc.exists) {
      await _firestore.collection('chatRooms').doc(chatId).set({'users': ids, 'createdAt': FieldValue.serverTimestamp(), 'lastMessage': ''});
    }
    return chatId;
  }

  // sendMessage now accepts optional reply fields
  Future<void> sendMessage({
    required String chatRoomId,
    required String text,
    required String userId,
    required String receiverId,
    String? replyToId,
    String? replyToText,
  }) async {
    if (text.trim().isEmpty) return;
    final docRef = _firestore.collection("chatRooms").doc(chatRoomId).collection("messages").doc();
    final payload = {
      "text": text.trim(),
      "userId": userId,
      "receiverId": receiverId,
      "isRead": false,
      "timestamp": FieldValue.serverTimestamp(),
      "messageId": docRef.id,
      "type": "text",
      "status": "sent",
      "sentAt": FieldValue.serverTimestamp(),
      "edited": false,
      "starred": false,
    };
    if (replyToId != null) payload['replyToId'] = replyToId;
    if (replyToText != null) payload['replyToText'] = replyToText;
    await docRef.set(payload);
    // update chatroom lastMessage quick meta
    await _firestore.collection('chatRooms').doc(chatRoomId).update({'lastMessage': text, 'lastUpdated': FieldValue.serverTimestamp()});
  }

  Future<void> sendMedia({
    required String chatRoomId,
    required String filePath,
    required String mediaType,
    required String userId,
    required String receiverId,
    String? replyToId,
    String? replyToText,
  }) async {
    List<int> bytes;
    if (kIsWeb) {
      final response = await http.get(Uri.parse(filePath));
      bytes = response.bodyBytes;
    } else {
      final file = io.File(filePath);
      bytes = await file.readAsBytes();
    }
    final encryptedBase64 = _encryptBytesToBase64(bytes);
    final docRef = _firestore.collection("chatRooms").doc(chatRoomId).collection("messages").doc();
    final payload = {
      "userId": userId,
      "receiverId": receiverId,
      "isRead": false,
      "timestamp": FieldValue.serverTimestamp(),
      "messageId": docRef.id,
      "type": mediaType,
      "status": "sent",
      "sentAt": FieldValue.serverTimestamp(),
      "mediaData": encryptedBase64,
      "encrypted": true,
      "edited": false,
      "starred": false,
    };
    if (replyToId != null) payload['replyToId'] = replyToId;
    if (replyToText != null) payload['replyToText'] = replyToText;
    await docRef.set(payload);
    await _firestore.collection('chatRooms').doc(chatRoomId).update({'lastMessage': "[${mediaType.toUpperCase()}]", 'lastUpdated': FieldValue.serverTimestamp()});
  }

  Future<void> markMessagesAsRead({ required String myUid, required String friendUid }) async {
    final ids = [myUid, friendUid]..sort();
    final chatId = ids.join('_');
    final unread = await _firestore.collection('chatRooms').doc(chatId).collection('messages').where('receiverId', isEqualTo: myUid).where('isRead', isEqualTo: false).get();
    for (final doc in unread.docs) {
      await doc.reference.update({'isRead': true, 'status': 'viewed', 'viewedAt': FieldValue.serverTimestamp()});
    }
  }

  Stream<int> unreadCountStream({ required String myUid, required String friendUid }) {
    final ids = [myUid, friendUid]..sort();
    final chatId = ids.join('_');
    return _firestore.collection('chatRooms').doc(chatId).collection('messages').where('receiverId', isEqualTo: myUid).where('isRead', isEqualTo: false).snapshots().map((s) => s.docs.length);
  }

  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return FirebaseFirestore.instance.collection("chatRooms").doc(chatRoomId).collection("messages").orderBy("timestamp", descending: false).snapshots();
  }

  Future<void> deleteMessage(String chatRoomId, String messageId) async {
    await _firestore.collection("chatRooms").doc(chatRoomId).collection("messages").doc(messageId).delete();
  }

  Future<void> edit(String? chatRoomId, String? messageId, String newText) async {
    if (chatRoomId == null || messageId == null) return;
    await FirebaseFirestore.instance.collection("chatRooms").doc(chatRoomId).collection("messages").doc(messageId).update({"text": newText, "edited": true});
  }

  Future<void> Statandunstar(String? chatRoomId, String? messageId, bool isStarred) async {
    if (chatRoomId == null || messageId == null) return;
    await FirebaseFirestore.instance.collection("chatRooms").doc(chatRoomId).collection("messages").doc(messageId).update({"starred": !isStarred});
  }

  Future<void> markMessageDelivered(String chatRoomId, String messageId) async {
    try {
      await _firestore.collection("chatRooms").doc(chatRoomId).collection("messages").doc(messageId).update({"status": "delivered"});
    } catch (e) {
      // ignore
    }
  }

  Future<void> markMessageViewed(String chatRoomId, String messageId) async {
    await FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).collection('messages').doc(messageId).update({'status': 'viewed'});
  }
}
