import 'package:calorai/constants/constants.dart';
import 'package:calorai/services/auth_service.dart';
import 'package:calorai/widgets/gradient_button.dart';
import 'package:calorai/widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginOtpScreen extends StatefulWidget {
  const LoginOtpScreen({super.key});

  @override
  State<LoginOtpScreen> createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _otpController = TextEditingController();
  String? verificationId;
  bool isOTPSent = false;

  final _formKey = GlobalKey<FormState>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Login with OTP"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Logo
            Center(
              child: Container(
                height: 150,
                width: 150,
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
            const Text(
              "Login Using Phone OTP",
              style: TextStyle(color: Colors.black54),
            ),
            //Form
            // Card
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
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
                    isOTPSent
                        ? SizedBox()
                        : InputField(
                            controller: _phoneController,
                            hintText: "Phone Number",
                            prefixIcon: Icons.phone_android,
                            keyboardType: TextInputType.phone,
                          ),
                    const SizedBox(height: 14),
                    isOTPSent
                        ? InputField(
                            keyboardType: TextInputType.number,
                            controller: _otpController,
                            hintText: "OTP",
                            prefixIcon: Icons.lock_outline,
                          )
                        : SizedBox(),
                    const SizedBox(height: 22),

                    GradientButton(
                      text: isOTPSent ? "Verify OTP" : "Send",
                      //enabled: !_loading,
                      onPressed: () {
                        if (_phoneController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Phone number is required")),
                          );
                        } else {
                          isOTPSent ? verifyOTP() : sendOTP();
                        }
                      },
                      gradient: const LinearGradient(
                        colors: [primaryOrangeDark, primaryOrangeLight],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Divider OR
                    // Row(
                    //   children: const [
                    //     Expanded(child: Divider(color: border)),
                    //     Padding(
                    //       padding: EdgeInsets.symmetric(horizontal: 10),
                    //       child: Text(
                    //         "OR",
                    //         style: TextStyle(
                    //             fontSize: 12, color: Color(0xFF9CA3AF)),
                    //       ),
                    //     ),
                    //     Expanded(child: Divider(color: border)),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _phoneModule() {
    return Container();
  }

  Widget _otpModule() {
    return Container();
  }
}
