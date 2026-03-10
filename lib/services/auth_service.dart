import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// I put all Firebase Authentication calls in this one file.
// That way the screens stay clean and I only hfave to come here
// when something auth-related needs fixing.

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // signUp creates the Auth account, sends the verification email,
  // then writes the user document to Firestore.
  // If the Firestore write fails after Auth already succeeded,
  // I delete the Auth account so there's no broken orphan account.
  Future<UserCredential> signUp(
    String email, String password, String displayName,
  ) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password,
      );
      await cred.user!.sendEmailVerification();
      try {
        await _db.collection('users').doc(cred.user!.uid).set({
          'uid': cred.user!.uid,
          'email': email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'notificationsEnabled': false,
        });
      } catch (e) {
        // Firestore write failed so I clean up the Auth account
        await cred.user!.delete();
        throw Exception('Account setup failed. Please try again.');
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _authError(e);
    }
  }

  // Force reload to get latest emailVerified status from Firebase
  // before checking if user can proceed to the app.
  Future<UserCredential> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password,
      );
      // Reload user to get fresh emailVerified status
      await cred.user!.reload();
      final refreshedUser = _auth.currentUser;
      if (refreshedUser != null && !refreshedUser.emailVerified) {
        await _auth.signOut();
        throw Exception(
          'Please verify your email before signing in. '
          'Check your inbox for the verification link.',
        );
      }
      return cred;
    } on FirebaseAuthException catch (e) {
      throw _authError(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  // I call reload() to force Firebase to re-check the emailVerified flag.
  // The verification screen calls this every 3 seconds.
  Future<void> reloadUser() async => await _auth.currentUser?.reload();

  Future<UserModel?> getUserDocument(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateNotificationPreference(String uid, bool value) async {
    await _db.collection('users').doc(uid).update({
      'notificationsEnabled': value,
    });
  }

  // I map Firebase error codes to messages a normal person can understand
  Exception _authError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('This email is already registered.');
      case 'weak-password':
        return Exception('Password must be at least 6 characters.');
      case 'invalid-email':
        return Exception('Please enter a valid email address.');
      case 'user-not-found':
        return Exception('No account found with this email.');
      case 'wrong-password':
        return Exception('Incorrect password. Please try again.');
      case 'invalid-credential':
        return Exception('Incorrect email or password.');
      case 'too-many-requests':
        return Exception('Too many attempts. Try again later.');
      case 'network-request-failed':
        return Exception('No internet connection.');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}