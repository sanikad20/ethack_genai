import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_role.dart';

/// Day 1: stub only. Real sign-up/login + role assignment
/// (Firestore-backed) gets built out on Day 4.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) {
    // TODO (Day 4): error handling, loading states, role lookup after login
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    UserRole role,
  ) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // TODO (Day 4): write role to Firestore users/{uid} doc
    return cred;
  }

  Future<void> signOut() => _auth.signOut();
}
