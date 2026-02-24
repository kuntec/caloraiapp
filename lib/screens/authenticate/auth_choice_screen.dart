import 'package:calorai/api/api_call.dart';
import 'package:calorai/models/UserRegisterData.dart';
import 'package:calorai/screens/dashboard_screen.dart';
import 'package:calorai/screens/main_navigation_screen.dart';
import 'package:calorai/screens/profile_setup_screen.dart';
import 'package:calorai/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthChoiceScreen extends StatefulWidget {
  const AuthChoiceScreen({super.key});

  @override
  State<AuthChoiceScreen> createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen> {
  bool _loadingGoogle = false;

  Future<void> _handleGoogle() async {
    setState(() => _loadingGoogle = true);
    try {
      UserCredential userCredential = await AuthService().signInWithGoogle();

      if (!mounted) return;

      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("email", userCredential.user!.email!);
      preferences.setString("uid", userCredential.user!.uid);
      bool isRegisterComplete =
          preferences.getBool("isRegisterComplete") ?? false;

      if (!isRegisterComplete) {
        await login(userCredential.user!.email!, userCredential.user!.uid);
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => MainNavigationScreen()));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _loadingGoogle = false);
    }
  }

  Future<void> login(String email, String password) async {
    ApiCall apiCall = ApiCall();
    UserRegisterData userRegisterData = await apiCall.login(email, password);
    if (userRegisterData.status) {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool("isRegisterComplete", true);
      preferences.setString("token", userRegisterData.token!);
      preferences.setString("id", userRegisterData.user!.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login Successful")),
      );
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => MainNavigationScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userRegisterData.message!)),
      );
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ProfileSetupScreen(
                    email: email,
                    password: password,
                  )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   surfaceTintColor: Colors.white,
      //   elevation: 0,
      //   title: const Text("Login"),
      // ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Choose a sign-in method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                "You can login using Google or Phone OTP.",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              _AuthButton(
                icon: Icons.g_mobiledata,
                title:
                    _loadingGoogle ? "Signing in..." : "Continue with Google",
                onTap: _loadingGoogle ? null : _handleGoogle,
              ),
              const SizedBox(height: 14),
              _AuthButton(
                icon: Icons.phone_android,
                title: "Continue with Phone (OTP)",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Phone OTP: Step 3")),
                  );
                },
              ),
              const Spacer(),
              const Text(
                "By continuing you agree to our Terms & Privacy Policy.",
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _AuthButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
