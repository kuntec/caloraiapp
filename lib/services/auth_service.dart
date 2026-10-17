import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // static const String _clientId =
  //     '82830612690-pghni5dc5ria234qe09ev6l7f0q70gs2.apps.googleusercontent.com';

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithGoogle() async {
    // 1️⃣ Trigger authentication

    final GoogleSignInAccount googleUser =
        await GoogleSignIn.instance.authenticate();

    // 2️⃣ Get auth details
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // 3️⃣ Create Firebase credential
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // 4️⃣ Sign in to Firebase
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  // ---------------------------
  // Email / Password Register
  // ---------------------------
  Future<UserCredential> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await credential.user?.sendEmailVerification();
    return credential;
  }

  // Email / Password Sign In
  // ---------------------------
  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ---------------------------
  // Forgot Password
  // ---------------------------
  Future<void> sendPasswordReset({
    required String email,
  }) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  // ---------------------------
  // Phone OTP - Send Code
  // ---------------------------
  Future<void> sendOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException e) verificationFailed,
    required void Function(PhoneAuthCredential credential)
        verificationCompleted,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // ---------------------------
  // Phone OTP - Verify Code
  // ---------------------------
  Future<UserCredential> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // ---------------------------
  // Apple Sign-In
  // ---------------------------
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
        length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Returns a record with the Firebase [UserCredential] and the user's
  /// display name sourced from Apple's credential (only available on the
  /// very first sign-in) or from the Firebase user profile thereafter.
  Future<({UserCredential credential, String? displayName})>
      signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // Apple only provides givenName / familyName on the FIRST sign-in.
    final givenName = appleCredential.givenName ?? '';
    final familyName = appleCredential.familyName ?? '';
    final appleName = '$givenName $familyName'.trim();

    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _auth.signInWithCredential(oauthCredential);

    // Persist the name to the Firebase profile so it's available on future
    // sign-ins (when Apple no longer sends it).
    if (appleName.isNotEmpty &&
        (userCredential.user?.displayName == null ||
            userCredential.user!.displayName!.isEmpty)) {
      await userCredential.user?.updateDisplayName(appleName);
    }

    // Prefer the name we just got from Apple; fall back to Firebase profile.
    final displayName = appleName.isNotEmpty
        ? appleName
        : userCredential.user?.displayName;

    return (credential: userCredential, displayName: displayName);
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
