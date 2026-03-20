import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {
    await _db.collection("users").doc(user.uid).set({
      "uid": user.uid,
      "email": user.email,
      "name": user.displayName ?? user.email!.split('@').first,
      "createdAt": DateTime.now(),
    }, SetOptions(merge: true));
  }

  Future<bool> checkEmailExists(String email) async {
    final snapshot = await _db
        .collection("users")
        .where("email", isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}