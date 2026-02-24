import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
//import 'package:calorai/models/AuthData.dart';
import 'package:calorai/widgets/gradient_button.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    //testing credentials
    _nameCtrl.text = "Saiyed";
    _emailCtrl.text = "saiyed.mhs@gmail.com";
    _passCtrl.text = "saiyed123";
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // TODO: Call your login API here.
      await registerUser();
      if (!mounted) return;

      // TODO: Navigate to dashboard or profile setup.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Register success (demo)")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Register failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onForgotPassword() {
    // TODO: Navigate to Forgot Password screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Forgot password tapped")),
    );
  }

  void _onSignup() {
    // TODO: Navigate to Register screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sign up tapped")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ============= APP BAR ROW =============
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade200,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                // Logo
                Center(
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 18,
                          offset: Offset(0, 8),
                          color: Color(0x14000000),
                        )
                      ],
                    ),
                    // child: const Icon(Icons.local_dining,
                    //     color: primary, size: 32),
                    // Replace with your asset logo:
                    child: Image.asset("assets/images/logo.jpg"),
                  ),
                ),
                const SizedBox(height: 12),

                // App name
                const Center(
                  child: Text(
                    "CalorAI",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),

                const SizedBox(height: 28),
                const SizedBox(height: 6),
                const Center(
                  child: Text(
                    "Register to continue tracking your nutrition",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

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
                          controller: _nameCtrl,
                          hintText: "Name",
                          prefixIcon: Icons.person,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 14),
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
                          suffixIcon: _obscure
                              ? Icons.visibility_off
                              : Icons.visibility,
                          onSuffixTap: () =>
                              setState(() => _obscure = !_obscure),
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
                              foregroundColor: primary,
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

                        // Login button
                        GradientButton(
                          text: _loading ? "Registering in..." : "Register",
                          enabled: !_loading,
                          onPressed: _onRegister,
                          gradient: LinearGradient(
                            colors: [primaryOrangeDark, primaryOrangeLight],
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

                        // Google button (optional)
                        OutlinedButton.icon(
                          onPressed: _loading ? null : () {},
                          icon: const Icon(Icons.g_mobiledata,
                              size: 26, color: textPrimary),
                          label: const Text(
                            "Continue with Google",
                            style: TextStyle(
                              color: textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            minimumSize: const Size.fromHeight(52),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> registerUser() async {
    // ApiCall apiCall = ApiCall();
    // AuthData authData = await apiCall.register(_nameCtrl.text.toString(),
    //     _emailCtrl.text.toString(), _passCtrl.text.toString());
    // if (authData.success!) {
    //   print(authData.data!.token!);
    // }
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
