import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileRepository {
  UserProfileRepository._();

  static DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid);

  static Stream<DocumentSnapshot<Map<String, dynamic>>> watch(String uid) =>
      userDoc(uid).snapshots();

  /// Creates a sane default profile if missing.
  static Future<void> ensureProfile(User user) async {
    final ref = userDoc(user.uid);
    final snap = await ref.get();
    if (snap.exists) return;

    await ref.set({
      'preferredLocale': 'he',
      'timezone': 'Asia/Jerusalem',
      'currencyCode': 'ILS',
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updatePreferredLocale(String uid, String code) async {
    await userDoc(uid).update({
      'preferredLocale': code,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateTimezone(String uid, String timezone) async {
    await userDoc(uid).update({
      'timezone': timezone,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateCurrency(String uid, String currencyCode) async {
    await userDoc(uid).update({
      'currencyCode': currencyCode,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

}
