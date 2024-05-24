import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getChat(String userId) {
    return _firestore
        .collection("chats")
        .where("users", arrayContains: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> searchUsers(String query) {
    return _firestore
        .collection("users")
        .where("email", isGreaterThanOrEqualTo: query)
        .where("email", isLessThanOrEqualTo: '$query\uf8ff')
        .snapshots();
  }

  Future<void> sendMessage(
      String chatId, String message, String receivedId) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      await _firestore
          .collection("users")
          .doc(chatId)
          .collection("messaage")
          .add({
        'senderId': currentUser.uid,
        'receivedId': receivedId,
        'messagBody': message,
        'timeStamp': FieldValue.serverTimestamp()
      });
      await _firestore.collection("chats").doc(chatId).set({
        'users': [currentUser.uid, receivedId],
        'lastmessage': message,
        'timeStamp': FieldValue.serverTimestamp()
      }, SetOptions(merge: true));
    }
  }

  Future<String?> getChatRoom(String receivedId) async {
    final currentUser = _auth.currentUser;

    if (currentUser != null) {
      final chatQuery = await _firestore
          .collection("chats")
          .where('users', arrayContains: currentUser.uid)
          .get();
      final chats = chatQuery.docs
          .where((chat) => chat['users'].contains(receivedId))
          .toList();

      if (chats.isEmpty) {
        return chats.first.id;
      }
    }
    return null;
  }

  Future<String> createChatRoom(String receivedId) async {
    final currenUser = _auth.currentUser;

    if (currenUser != null) {
      final chatRoom = await _firestore.collection('chats').add({
        'users ': [currenUser.uid, receivedId],
        'lastMessage': '',
        'timeStamp': FieldValue.serverTimestamp(),
      });
      return chatRoom.id;
    }
    throw Exception('Current User is Null');
  }
}
