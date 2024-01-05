import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      _fireStore
          .collection('users')
          .doc(credential.user!.uid)
          .set({'uid': credential.user!.uid, 'email': email, 'password': password});

      return credential.user;
    } catch (e) {
      print(e);
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      _fireStore.collection('users').doc(credential.user!.uid).set(
          {'uid': credential.user!.uid, 'email': email, 'password': password},
          SetOptions(merge: true));
      return credential.user;
    } catch (e) {
      print("Some error occured");
    }
  }

  //sign out
  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
