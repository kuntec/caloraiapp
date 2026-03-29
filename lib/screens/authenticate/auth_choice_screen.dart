import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/models/UserRegisterData.dart';
import 'package:calorai/screens/authenticate/forgot_password_screen.dart';
import 'package:calorai/screens/authenticate/login_otp_screen.dart';
import 'package:calorai/screens/dashboard_screen.dart';
import 'package:calorai/screens/main_navigation_screen.dart';
import 'package:calorai/screens/on_boarding_screen.dart';
import 'package:calorai/screens/profile_setup_screen.dart';
import 'package:calorai/screens/register_screen.dart';
import 'package:calorai/services/auth_service.dart';
import 'package:calorai/widgets/google_signin_button.dart';
import 'package:calorai/widgets/gradient_button.dart';
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

  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String? verificationId;
  bool isOTPSent = false;

  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> sendOTP() async {
    await AuthService().sendOtp(
      phoneNumber: _phoneController.text.trim(),
      codeSent: (verId, resendToken) {
        verificationId = verId;
      },
      verificationFailed: (e) {
        print(e.message);
      },
      verificationCompleted: (credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      codeAutoRetrievalTimeout: (verId) {
        verificationId = verId;
      },
    );
    setState(() {
      isOTPSent = true;
    });
  }

  Future<void> verifyOTP() async {
    UserCredential userCredential = await AuthService().verifyOtp(
      verificationId: verificationId!,
      smsCode: _otpController.text.trim(),
    );
    if (!mounted) return;
    print(userCredential.user!.phoneNumber);
    setState(() {
      isOTPSent = false;
    });
  }

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

  void _onForgotPassword() {
    // TODO: Navigate to Forgot Password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Forgot password tapped")),
    );
    MyUtility.changePage(context, ForgotPasswordScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
              // Logo
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      // BoxShadow(
                      //   blurRadius: 18,
                      //   offset: Offset(0, 8),
                      //   color: Color(0x14000000),
                      // )
                    ],
                  ),
                  // child: const Icon(Icons.local_dining,
                  //     color: primaryOrangeDark, size: 32),
                  // Replace with your asset logo:
                  child: Image.asset("assets/images/logo_alpha.png"),
                ),
              ),

              // Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 24,
                      offset: Offset(0, 10),
                      color: Color(0x0F000000),
                    )
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _InputField(
                        controller: _emailCtrl,
                        hintText: "Email address",
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          final value = (v ?? "").trim();
                          if (value.isEmpty) return "Email is required";
                          final ok =
                              RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value);
                          if (!ok) return "Enter a valid email";
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      _InputField(
                        controller: _passCtrl,
                        hintText: "Password",
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscure,
                        suffixIcon:
                            _obscure ? Icons.visibility_off : Icons.visibility,
                        onSuffixTap: () => setState(() => _obscure = !_obscure),
                        validator: (v) {
                          final value = (v ?? "");
                          if (value.isEmpty) return "Password is required";
                          if (value.length < 6) return "Minimum 6 characters";
                          return null;
                        },
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _onForgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: primaryOrangeDark,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                          ),
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      GradientButton(
                        text: _loading ? "Logging in..." : "Login",
                        enabled: !_loading,
                        onPressed: () {},
                        gradient: const LinearGradient(
                          colors: [primaryOrangeDark, primaryOrangeLight],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Divider OR
                      Row(
                        children: const [
                          Expanded(child: Divider(color: border)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "OR",
                              style: TextStyle(
                                  fontSize: 12, color: Color(0xFF9CA3AF)),
                            ),
                          ),
                          Expanded(child: Divider(color: border)),
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Text(
                        "You can login using Google.",
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      // Google button (optional)

                      InkWell(
                        onTap: _loadingGoogle ? null : _handleGoogle,
                        child: Container(
                          decoration: kContainerBox,
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Image.asset("assets/images/google.png"),
                              Text(
                                _loadingGoogle
                                    ? "Signing in..."
                                    : "Continue with Google",
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // OutlinedButton.icon(
                      //   onPressed: _loadingGoogle ? null : _handleGoogle,
                      //   icon: const Icon(Icons.g_mobiledata,
                      //       size: 26, color: textPrimary),
                      //   label: Text(
                      //     _loadingGoogle
                      //         ? "Signing in..."
                      //         : "Continue with Google",
                      //     style: TextStyle(
                      //       color: textPrimary,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      //   style: OutlinedButton.styleFrom(
                      //     backgroundColor: Colors.white,
                      //     side: const BorderSide(color: border),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(14),
                      //     ),
                      //     minimumSize: const Size.fromHeight(52),
                      //   ),
                      // ),
                      const SizedBox(height: 8),
                      // Google button (optional)
                      // OutlinedButton.icon(
                      //   onPressed: () {
                      //     MyUtility.changePage(context, LoginOtpScreen());
                      //   },
                      //   icon: const Icon(Icons.g_mobiledata,
                      //       size: 26, color: textPrimary),
                      //   label: Text(
                      //     "Continue with Phone OTP",
                      //     style: TextStyle(
                      //       color: textPrimary,
                      //       fontWeight: FontWeight.w600,
                      //     ),
                      //   ),
                      //   style: OutlinedButton.styleFrom(
                      //     backgroundColor: Colors.white,
                      //     side: const BorderSide(color: border),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(14),
                      //     ),
                      //     minimumSize: const Size.fromHeight(52),
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),

              // const Text(
              //   "Choose a sign-in method",
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              // ),

              // const Text(
              //   "You can login using Google or Phone OTP.",
              //   style: TextStyle(color: Colors.black54),
              // ),
              //const SizedBox(height: 24),
              // _AuthButton(
              //   icon: Icons.g_mobiledata,
              //   title:
              //       _loadingGoogle ? "Signing in..." : "Continue with Google",
              //   onTap: _loadingGoogle ? null : _handleGoogle,
              // ),
              //const SizedBox(height: 14),
              // TextField(
              //     controller: _phoneController,
              //     keyboardType: TextInputType.phone,
              //     decoration: InputDecoration(
              //         border: OutlineInputBorder(
              //           borderRadius: BorderRadius.all(Radius.circular(20)),
              //         ),
              //         hintText: "Phone Number",
              //         prefixIcon: const Icon(Icons.phone))),
              //const SizedBox(height: 14),
              // isOTPSent
              //     ? TextField(
              //         controller: _otpController,
              //         keyboardType: TextInputType.number,
              //         decoration: InputDecoration(
              //             border: OutlineInputBorder(
              //               borderRadius: BorderRadius.all(Radius.circular(20)),
              //             ),
              //             hintText: "OTP Number",
              //             prefixIcon: const Icon(Icons.pin)))
              //     : SizedBox(),
              // const SizedBox(height: 14),
              // _AuthButton(
              //   icon: Icons.phone_android,
              //   title: isOTPSent ? "Verify OTP" : "Continue with Phone (OTP)",
              //   onTap: () {
              //     isOTPSent ? verifyOTP() : sendOTP();
              //     // ScaffoldMessenger.of(context).showSnackBar(
              //     //   const SnackBar(content: Text("Phone OTP: Step 3")),
              //     // );
              //   },
              // ),
              // const SizedBox(height: 14),
              // _AuthButton(
              //   icon: Icons.phone_android,
              //   title: "On Boarding",
              //   onTap: () {
              //     MyUtility.changePage(context, OnBoardingScreen());
              //     // ScaffoldMessenger.of(context).showSnackBar(
              //     //   const SnackBar(content: Text("Phone OTP: Step 3")),
              //     // );
              //   },
              // ),
              const Spacer(),
              // _AuthButton(
              //   icon: Icons.phone_android,
              //   title: "Register",
              //   onTap: () {
              //     MyUtility.changePage(context, RegisterScreen());
              //     // ScaffoldMessenger.of(context).showSnackBar(
              //     //   const SnackBar(content: Text("Phone OTP: Step 3")),
              //     // );
              //   },
              // ),
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

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.onSuffixTap,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    const bgField = Color(0xFFF9FAFB);
    const border = Color(0xFFE5E7EB);
    const primary = Color(0xFFFF9800);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: bgField,
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon: Icon(prefixIcon, color: primary),
        suffixIcon: suffixIcon == null
            ? null
            : InkWell(
                onTap: onSuffixTap,
                child: Icon(suffixIcon, color: const Color(0xFF6B7280)),
              ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: border),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primary, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFEF4444)),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
