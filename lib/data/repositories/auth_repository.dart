import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository._internal();
  static final AuthRepository _authRepository = AuthRepository._internal();
  factory AuthRepository.instance() => _authRepository;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? get currentUser => _firebaseAuth.currentUser;

  void logout() {
    _firebaseAuth.signOut();
  }

  Future<UserCredential> login(String email, String password) =>
      _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<UserCredential> register(String email, String password) =>
      _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<void> sendResetLink(String email) =>
      _firebaseAuth.sendPasswordResetEmail(
        email: email,
      );
}
