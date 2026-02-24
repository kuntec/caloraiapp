import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String _clientId =
      '82830612690-pghni5dc5ria234qe09ev6l7f0q70gs2.apps.googleusercontent.com';

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

  // Future<UserCredential> signInWithGoogle() async {
  //   // Trigger the Google sign-in flow
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn.instance;
  //   unwaited
  //
  //   final GoogleSignInAccount? googleUser =
  //       await GoogleSignIn.instance.authenticate();
  //
  //   if (googleUser == null) {
  //     // User closed the popup / cancelled
  //     throw Exception("Google sign-in cancelled");
  //   }
  //
  //   // Obtain the auth details from the request
  //   final GoogleSignInAuthentication googleAuth =
  //       await googleUser.authentication;
  //
  //   // Create a new credential
  //   final OAuthCredential credential = GoogleAuthProvider.credential(
  //     idToken: googleAuth.idToken,
  //   );
  //
  //   // Sign in to Firebase with the credential
  //   return await _auth.signInWithCredential(credential);
  // }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
  }
}
