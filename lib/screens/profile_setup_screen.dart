import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/models/UserRegisterData.dart';
import 'package:calorai/screens/main_navigation_screen.dart';
import 'package:calorai/screens/subscription_page.dart';
import 'package:calorai/widgets/input_field.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String email;
  final String password;
  final String? name;
  const ProfileSetupScreen({
    required this.email,
    required this.password,
    this.name,
    super.key,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  int _step = 0;

  // Controllers
  final _nameCtrl = TextEditingController();

  // Values
  DateTime? _dob;
  String _height = "170";
  String _weight = "70";
  String _gender = "male";
  String _goal = "maintenance";
  String _activity = "moderate";
  String _diet = "Any";

  bool _saving = false;

  // Height range: 100–250 cm
  final List<String> _heightOptions =
      List.generate(151, (i) => "${i + 100}");

  // Weight range: 30–200 kg
  final List<String> _weightOptions =
      List.generate(171, (i) => "${i + 30}");

  @override
  void initState() {
    super.initState();
    if (widget.name != null && widget.name!.isNotEmpty) {
      _nameCtrl.text = widget.name!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0) {
      if (_nameCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Name is required")),
        );
        return;
      }
      if (_dob == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select your date of birth")),
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
      if (!mounted) return;
      await registerUser();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> registerUser() async {
    final dobString = _dob != null
        ? "${_dob!.year.toString().padLeft(4, '0')}-${_dob!.month.toString().padLeft(2, '0')}-${_dob!.day.toString().padLeft(2, '0')}T00:00:00.000Z"
        : "";

    ApiCall apiCall = ApiCall();
    UserRegisterData userRegisterData = await apiCall.register(
        _nameCtrl.text,
        widget.email,
        widget.password,
        dobString,
        _gender,
        _height,
        _weight,
        _activity,
        _goal,
        firebaseUid: widget.password); // widget.password = Firebase UID for social auth users

    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setBool("isRegisterComplete", true);
    preferences.setString("token", userRegisterData.token!);
    preferences.setString("id", userRegisterData.user!.id!);
    preferences.setString("email", widget.email);
    // Save diet preference locally (backend model doesn't store this field)
    await preferences.setString("dietPreference", _diet);

    // Returning users (e.g. social-auth whose token expired) already have a
    // goalType set on the backend.  Send them straight to the dashboard.
    // New users have no goalType yet — send them through subscription setup.
    final returnedGoalType =
        userRegisterData.user?.profile?.goalType?.toString() ?? '';
    if (returnedGoalType.isNotEmpty) {
      MyUtility.removePage(context, MainNavigationScreen());
    } else {
      MyUtility.removePage(context, SubscriptionPage(showSkip: true));
    }
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
        // Name — pre-filled from RegisterScreen
        InputField(
          controller: _nameCtrl,
          hintText: "Full Name",
          prefixIcon: Icons.person,
        ),
        const SizedBox(height: 12),
        // Gender chips
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
        // Date of birth — date picker
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dob ?? DateTime(2000, 1, 1),
              firstDate: DateTime(1920),
              lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFFFF9800),
                    onPrimary: Colors.white,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _dob = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.cake, color: Color(0xFFFF9800)),
                const SizedBox(width: 12),
                Text(
                  _dob == null
                      ? "Date of Birth"
                      : "${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}",
                  style: TextStyle(
                    fontSize: 14,
                    color: _dob == null
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Height and Weight dropdowns
        Row(
          children: [
            Expanded(
              child: _Dropdown(
                label: "Height (cm)",
                value: _height,
                items: _heightOptions,
                onChanged: (v) => setState(() => _height = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Dropdown(
                label: "Weight (kg)",
                value: _weight,
                items: _weightOptions,
                onChanged: (v) => setState(() => _weight = v),
              ),
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
