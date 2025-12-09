import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/app_user.dart';

class UserService {
  UserService._();

  static final UserService instance = UserService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users');

  Future<AppUser?> getById(String id) async {
    final doc = await _col.doc(id).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) {
    return _col.doc(id).set(data, SetOptions(merge: true));
  }

  Future<void> addToWallet(String id, num amount) {
    return _col.doc(id).update({
      'walletBalance': FieldValue.increment(amount),
    });
  }

  Future<String> uploadProfileImage(String uid, File file) async {
    final ref = _storage.ref().child('user_profile_images').child('$uid.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<void> updateProfileImageUrl(String uid, String url) {
    return updateUser(uid, {'profileImageUrl': url});
  }

  Stream<AppUser?> watchUser(String id) {
    return _col.doc(id).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AppUser.fromMap(snap.id, snap.data()!);
    });
  }
}
