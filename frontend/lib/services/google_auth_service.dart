import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Service to handle Google Sign-In authentication with Firebase
class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with Google
  ///
  /// Returns a map with:
  /// - 'success': bool indicating if sign-in was successful
  /// - 'user': UserCredential if successful
  /// - 'idToken': Firebase ID token if successful
  /// - 'message': Error message if failed
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      debugPrint('🔵 Starting Google Sign-In flow...');
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        debugPrint('⚠️ Google Sign-In canceled by user');
        return {'success': false, 'message': 'Sign-in canceled by user'};
      }

      debugPrint('✅ Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint('✅ Google authentication obtained');

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('✅ Firebase credential created');

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      debugPrint('✅ Firebase authentication successful');

      // Get the Firebase ID token to send to backend
      final String? idToken = await userCredential.user?.getIdToken();

      debugPrint('✅ Firebase ID token obtained');

      return {
        'success': true,
        'user': userCredential,
        'idToken': idToken,
        'email': userCredential.user?.email,
        'displayName': userCredential.user?.displayName,
        'photoUrl': userCredential.user?.photoURL,
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase Auth Exception: ${e.code} - ${e.message}');
      String message;
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message =
              'An account already exists with the same email address but different sign-in credentials.';
          break;
        case 'invalid-credential':
          message = 'The credential is malformed or has expired.';
          break;
        case 'operation-not-allowed':
          message = 'Google sign-in is not enabled. Please contact support.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'user-not-found':
          message = 'No user found with this credential.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        case 'invalid-verification-code':
          message = 'The verification code is invalid.';
          break;
        case 'invalid-verification-id':
          message = 'The verification ID is invalid.';
          break;
        default:
          message = 'Authentication failed: ${e.message}';
      }

      return {'success': false, 'message': message, 'errorCode': e.code};
    } catch (e) {
      debugPrint('❌ Unexpected error during Google Sign-In: $e');
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  /// Sign out from Google and Firebase
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }

  /// Check if user is currently signed in
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  /// Get current Firebase user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
