import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  FirebaseAuth get auth => FirebaseAuth.instance;

  User? get currentUser => auth.currentUser;

  Stream<User?> get authStateChanges => auth.authStateChanges();

  // Register user with email and password
  Future<UserCredential> register(String email, String password) async {
    try {
      return await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Register FirebaseAuthException: [${e.code}] ${e.message}');
      throw Exception(_mapAuthCode(e.code));
    } catch (e) {
      debugPrint('Register unexpected error: $e');
      rethrow;
    }
  }

  // Login user with email and password
  Future<UserCredential> login(String email, String password) async {
    try {
      return await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('Login FirebaseAuthException: [${e.code}] ${e.message}');
      throw Exception(_mapAuthCode(e.code));
    } catch (e) {
      debugPrint('Login unexpected error: $e');
      rethrow;
    }
  }

  // Google Sign-In
  // On Web  → uses Firebase signInWithPopup (no Client ID meta tag needed)
  // On Mobile → uses google_sign_in package (standard OAuth flow)
  Future<UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // ── Web: popup flow driven by Firebase Auth directly ───────────
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        return await auth.signInWithPopup(googleProvider);
      } else {
        // ── Mobile: google_sign_in package flow ────────────────────────
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          throw Exception('Google Sign-In was cancelled.');
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'Google Sign-In FirebaseAuthException: [${e.code}] ${e.message}');
      throw Exception(_mapAuthCode(e.code));
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    // Only call google_sign_in signOut on mobile; not needed on web
    if (!kIsWeb) {
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      } catch (e) {
        debugPrint('Google Sign-Out error (non-fatal): $e');
      }
    }
    await auth.signOut();
  }

  // Send Password Reset Link
  Future<void> sendPasswordReset(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      debugPrint(
          'Password reset FirebaseAuthException: [${e.code}] ${e.message}');
      throw Exception(_mapAuthCode(e.code));
    } catch (e) {
      debugPrint('Password reset unexpected error: $e');
      rethrow;
    }
  }

  // Map FirebaseAuthException.code to user-friendly messages
  String _mapAuthCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email address. [$code]';
      case 'user-disabled':
        return 'This account has been disabled. [$code]';
      case 'user-not-found':
        return 'No account found with this email. [$code]';
      case 'wrong-password':
        return 'Incorrect password. [$code]';
      case 'invalid-credential':
        return 'Invalid email or password. [$code]';
      case 'email-already-in-use':
        return 'An account already exists with this email. [$code]';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters. [$code]';
      case 'network-request-failed':
        return 'Network error. Check your internet connection. [$code]';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again. [$code]';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled in Firebase Console. [$code]';
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method. [$code]';
      case 'requires-recent-login':
        return 'Please sign out and sign in again to perform this action. [$code]';
      case 'popup-closed-by-user':
        return 'Sign-in popup was closed before completing. [$code]';
      case 'popup-blocked':
        return 'Sign-in popup was blocked by the browser. Allow popups and try again. [$code]';
      default:
        return 'Authentication error: $code';
    }
  }
}
