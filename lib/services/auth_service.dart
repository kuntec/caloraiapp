import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
