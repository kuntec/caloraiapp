import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/models/UserRegisterData.dart';
import 'package:calorai/screens/dashboard_screen.dart';
import 'package:calorai/screens/main_navigation_screen.dart';
import 'package:calorai/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupScreen extends StatefulWidget {
  String email;
  String password;
  ProfileSetupScreen({required this.email, required this.password, super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _step = 0;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  // Values
  String _gender = "male";
  String _goal = "maintenance";
  String _activity = "moderate";
  String _diet = "Any";

  bool _saving = false;

  // Colors

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0) {
      if (_nameCtrl.text.toString().trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Name is required")),
        );
        return;
      }
    }
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  Future<void> _submit() async {
    setState(() => _saving = true);

    try {
      // TODO: Call update profile API (JSON raw)
      //await Future.delayed(const Duration(seconds: 1));
      print(_nameCtrl.text);
      print(_ageCtrl.text);
      print(_gender);
      print(_activity);
      print(_diet);
      print(_heightCtrl);
      print(_weightCtrl);
      print(_goal);
      if (!mounted) return;
      await registerUser();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> registerUser() async {
    ApiCall apiCall = ApiCall();
    UserRegisterData userRegisterData = await apiCall.register(
        _nameCtrl.text,
        widget.email,
        widget.password,
        _ageCtrl.text,
        _gender,
        _heightCtrl.text,
        _weightCtrl.text,
        _activity,
        _goal);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("isRegisterComplete", true);
    preferences.setString("token", userRegisterData.token!);
    preferences.setString("id", userRegisterData.user!.id!);
    MyUtility.removePage(context, MainNavigationScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          "Profile Setup",
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomSheet: Container(
        height: _step > 0 ? 140 : 80,
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: _GradientButton(
                text: _saving
                    ? "Saving..."
                    : _step == 2
                        ? "Finish"
                        : "Next",
                onPressed: _saving ? () {} : _next,
                gradient: const LinearGradient(
                  colors: [primary, primary2],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            if (_step > 0)
              InkWell(
                onTap: _back,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  decoration: kContainerBox,
                  alignment: Alignment.center,
                  child: Text("Back"),
                ),
              ),
            // TextButton(
            //   onPressed: _back,
            //   child: const Text(
            //     "Back",
            //     style: TextStyle(
            //         color: textSecondary, fontWeight: FontWeight.w700),
            //   ),
            // ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _StepIndicator(step: _step),
              const SizedBox(height: 10),
              // Expanded(
              //   child: Padding(
              //     padding: const EdgeInsets.all(20),
              //     child: _buildStep(),
              //   ),
              // ),
              _buildStep(),
              // Padding(
              //   padding: const EdgeInsets.all(10),
              //   child: _GradientButton(
              //     text: _saving
              //         ? "Saving..."
              //         : _step == 2
              //             ? "Finish"
              //             : "Next",
              //     onPressed: _saving ? () {} : _next,
              //     gradient: const LinearGradient(
              //       colors: [primary, primary2],
              //       begin: Alignment.bottomCenter,
              //       end: Alignment.topCenter,
              //     ),
              //   ),
              // ),
              // if (_step > 0)
              //   TextButton(
              //     onPressed: _back,
              //     child: const Text(
              //       "Back",
              //       style: TextStyle(
              //           color: textSecondary, fontWeight: FontWeight.w700),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _stepBasic();
      case 1:
        return _stepGoals();
      case 2:
        return _stepLifestyle();
      default:
        return const SizedBox();
    }
  }

  // ---------------- STEP 1 ----------------
  Widget _stepBasic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Basic Details",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
        ),
        const SizedBox(height: 16),
        InputField(
            controller: _nameCtrl,
            hintText: "Full Name",
            prefixIcon: Icons.person),
//        InputField(_nameCtrl, "Full Name", Icons.person),
        const SizedBox(height: 12),
        Row(
          children: ["male", "female", "other"]
              .map((g) => Expanded(
                    child: _Chip(
                      text: g,
                      selected: _gender == g,
                      onTap: () => setState(() => _gender = g),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        InputField(
          controller: _ageCtrl,
          hintText: "Date of Birth",
          prefixIcon: Icons.cake,
          keyboardType: TextInputType.number,
        ),
//        _Input(_ageCtrl, "Age", Icons.cake, keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: InputField(
                controller: _heightCtrl,
                hintText: "Height (cm)",
                prefixIcon: Icons.height,
                keyboardType: TextInputType.number,
              ),
              // child: _Input(_heightCtrl, "Height (cm)", Icons.height,
              //     keyboardType: TextInputType.number),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputField(
                controller: _weightCtrl,
                hintText: "Weight (kg)",
                prefixIcon: Icons.monitor_weight,
                keyboardType: TextInputType.number,
              ),
              // child: _Input(_weightCtrl, "Weight (kg)", Icons.monitor_weight,
              //     keyboardType: TextInputType.number),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- STEP 2 ----------------
  Widget _stepGoals() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Your Goal",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
        ),
        const SizedBox(height: 16),
        _GoalCard("Weight Loss", _goal == "weight_loss",
            () => setState(() => _goal = "weight_loss")),
        _GoalCard("Maintain", _goal == "maintenance",
            () => setState(() => _goal = "maintenance")),
        _GoalCard("Muscle Gain", _goal == "muscle_gain",
            () => setState(() => _goal = "muscle_gain")),
        _GoalCard(
            "Keto", _goal == "keto", () => setState(() => _goal = "keto")),
        _GoalCard("Intermittent Fasting", _goal == "intermittent_fasting",
            () => setState(() => _goal = "intermittent_fasting")),
      ],
    );
  }

  // ---------------- STEP 3 ----------------
  Widget _stepLifestyle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Lifestyle & Diet",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: textPrimary),
        ),
        const SizedBox(height: 16),
        _Dropdown(
          label: "Activity Level",
          value: _activity,
          items: const [
            'sedentary',
            'light',
            'moderate',
            'active',
            'very-active'
          ],
          onChanged: (v) => setState(() => _activity = v),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          children: ["Any", "Halal", "Veg", "Non-Veg", "Keto"]
              .map((d) => _Chip(
                    text: d,
                    selected: _diet == d,
                    onTap: () => setState(() => _diet = d),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int step;
  const _StepIndicator({required this.step});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i <= step;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          height: 8,
          width: active ? 26 : 8,
          decoration: BoxDecoration(
            color: active ? Color(0xFFFF9800) : Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

// class _Input extends StatelessWidget {
//   final TextEditingController c;
//   final String hint;
//   final IconData icon;
//   final TextInputType? keyboardType;
//
//   const _Input(this.c, this.hint, this.icon, {this.keyboardType});
//
//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: c,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         filled: true,
//         fillColor: Color(0xFFF9FAFB),
//         hintText: hint,
//         prefixIcon: Icon(icon, color: Color(0xFFFF9800)),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }

class _Chip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _Chip(
      {required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        margin: const EdgeInsets.only(right: 10, bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
              color: selected ? Color(0xFFFF9800) : Color(0xFFE5E7EB)),
        ),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Color(0xFFFF9800) : Color(0xFF1F2937)),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _GoalCard(this.text, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? Color(0xFFFF9800) : Color(0xFFE5E7EB)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _Dropdown(
      {required this.label,
      required this.value,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w700, color: Color(0xFF6B7280))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => onChanged(v!),
            ),
          ),
        ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final LinearGradient gradient;

  const _GradientButton(
      {required this.text, required this.onPressed, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 52,
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
                  fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
