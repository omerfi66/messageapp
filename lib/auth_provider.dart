import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currenUser => _auth.currentUser;
  bool get isSignedIn => currenUser != null;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    notifyListeners();
  }

  // Future<void> singUp(
  //     String email, String name, String imageUrl, String password) async {
  //   UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
  //       email: email, password: password);

  //   final imageUrl = await _uploadImage(_image!);
  //   await _firestore.collection("users").doc(userCredential.user!.uid).set({
  //     'uid': userCredential.user!.uid,
  //     'name': name,
  //     'email': email,
  //     'imageUrl': imageUrl,
  //   });
  //   notifyListeners();
  // }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
