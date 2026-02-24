import 'dart:io';
import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _otpSent = false;
  bool _loading = false;

  static const bg = Color(0xFFF9FAFB);
  static const primary = Color(0xFFFF9800);
  static const primary2 = Color(0xFFFFB74D);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();

    final phone = _phoneCtrl.text.trim();
    if (phone.length < 8) {
      _toast("Enter a valid phone number");
      return;
    }

    setState(() => _loading = true);

    try {
      // TODO: Call OTP SEND (Firebase / Node backend)
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      setState(() => _otpSent = true);
      _toast("OTP sent (demo)");
    } catch (e) {
      _toast("Failed to send OTP: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _verifyOtp() async {
    FocusScope.of(context).unfocus();

    final otp = _otpCtrl.text.trim();
    if (otp.length < 4) {
      _toast("Enter a valid OTP");
      return;
    }

    setState(() => _loading = true);

    try {
      // TODO: Verify OTP (Firebase / Node backend)
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      // TODO: Decide next:
      // - if new user -> profile setup
      // - else -> dashboard
      Navigator.pushReplacementNamed(context, "/dashboard");
    } catch (e) {
      _toast("OTP verification failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resendOtp() {
    // TODO: resend OTP
    _toast("Resend OTP (TODO)");
  }

  void _editPhone() {
    setState(() {
      _otpSent = false;
      _otpCtrl.clear();
    });
  }

  void _onGoogle() {
    // TODO: Google sign-in
    _toast("Google Sign-in (TODO)");
  }

  void _onApple() {
    // TODO: Apple sign-in
    _toast("Apple Sign-in (TODO)");
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Logo
                Center(
                  child: Container(
                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 22,
                          offset: Offset(0, 10),
                          color: Color(0x14000000),
                        )
                      ],
                    ),
                    child: const Icon(Icons.local_dining,
                        color: primary, size: 36),
                    // Replace with your logo:
                    // child: Padding(
                    //   padding: const EdgeInsets.all(12),
                    //   child: Image.asset("assets/logo.png"),
                    // ),
                  ),
                ),
                const SizedBox(height: 14),

                const Center(
                  child: Text(
                    "CalorAI",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    "Sign in to start tracking your nutrition",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                // Main Card
                Container(
                  padding: const EdgeInsets.all(18),
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
                  child: Column(
                    children: [
                      // PHONE INPUT
                      _InputField(
                        controller: _phoneCtrl,
                        hintText: "Phone number (e.g. +971 50 123 4567)",
                        prefixIcon: Icons.phone_iphone,
                        enabled: !_otpSent && !_loading,
                        keyboardType: TextInputType.phone,
                      ),

                      const SizedBox(height: 12),

                      // If OTP not sent: show Send OTP
                      if (!_otpSent)
                        _GradientButton(
                          text: _loading ? "Sending..." : "Send OTP",
                          enabled: !_loading,
                          onPressed: _sendOtp,
                          gradient:
                              const LinearGradient(colors: [primary, primary2]),
                        ),

                      // OTP SECTION (same screen)
                      if (_otpSent) ...[
                        const SizedBox(height: 14),
                        _InputField(
                          controller: _otpCtrl,
                          hintText: "Enter OTP",
                          prefixIcon: Icons.password_rounded,
                          enabled: !_loading,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: _loading ? null : _editPhone,
                              style: TextButton.styleFrom(
                                foregroundColor: textSecondary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                              ),
                              child: const Text(
                                "Edit phone",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            TextButton(
                              onPressed: _loading ? null : _resendOtp,
                              style: TextButton.styleFrom(
                                foregroundColor: primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                              ),
                              child: const Text(
                                "Resend OTP",
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        _GradientButton(
                          text: _loading ? "Verifying..." : "Verify & Continue",
                          enabled: !_loading,
                          onPressed: _verifyOtp,
                          gradient:
                              const LinearGradient(colors: [primary, primary2]),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // Divider
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

                      // Google
                      OutlinedButton.icon(
                        onPressed: _loading ? null : _onGoogle,
                        icon: const Icon(Icons.g_mobiledata,
                            size: 28, color: textPrimary),
                        label: const Text(
                          "Continue with Google",
                          style: TextStyle(
                              fontWeight: FontWeight.w700, color: textPrimary),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: border),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Apple (iOS only)
                      if (Platform.isIOS)
                        OutlinedButton.icon(
                          onPressed: _loading ? null : _onApple,
                          icon: const Icon(Icons.apple,
                              size: 22, color: textPrimary),
                          label: const Text(
                            "Continue with Apple",
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: textPrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: border),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "By continuing, you agree to our Terms & Privacy Policy.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: textSecondary),
                ),
              ],
            ),
          ),
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
    required this.enabled,
    this.keyboardType,
    this.maxLength,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final bool enabled;
  final TextInputType? keyboardType;
  final int? maxLength;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9FAFB);
    const primary = Color(0xFFFF9800);
    const border = Color(0xFFE5E7EB);

    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        counterText: "",
        filled: true,
        fillColor: bg,
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        prefixIcon: Icon(prefixIcon, color: primary),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.text,
    required this.onPressed,
    required this.gradient,
    this.enabled = true,
  });

  final String text;
  final VoidCallback onPressed;
  final LinearGradient gradient;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
