import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/models/UserRegisterData.dart';
import 'package:calorai/screens/setting_screen.dart';
import 'package:calorai/screens/splash_screen.dart';
import 'package:calorai/widgets/editable_round_image.dart';
import 'package:calorai/widgets/gradient_button.dart';
import 'package:calorai/widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Demo initial data (replace with API data)
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();

  String _goal = "maintenance";
  String _activity = "moderate";
  String _diet = "Halal";

  // Plan settings (stored locally)
  int _planDurationWeeks = 8;
  int _mealsPerDay = 3;

  bool _saving = false;
  bool _loading = true;

  static const bg = Color(0xFFF9FAFB);
  static const primary = Color(0xFFFF9800);
  static const primary2 = Color(0xFFFFB74D);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      final token = preferences.getString("token");
      // Load saved local preferences (backend doesn't store these)
      final savedDiet = preferences.getString("dietPreference") ?? "Halal";
      final savedPlanWeeks = preferences.getInt("planDurationWeeks") ?? 8;
      final savedMeals = preferences.getInt("mealsPerDay") ?? 3;

      if (token != null) {
        ApiCall apiCall = ApiCall();
        UserRegisterData userRegisterData = await apiCall.getMe(token);
        if (mounted) {
          // Backend /auth/me returns {user:{...}} without a status field,
        // so check for user/profile presence rather than status.
        if (userRegisterData.user?.profile != null) {
            final profile = userRegisterData.user!.profile!;
            _nameCtrl.text = profile.fullName?.toString() ?? '';
            // Show email from API response, fall back to SharedPreferences
            _contactCtrl.text =
                userRegisterData.user?.email?.toString() ??
                preferences.getString("email") ??
                '';
            _heightCtrl.text = profile.heightCm?.toString() ?? '';
            _weightCtrl.text = profile.weightKg?.toString() ?? '';
            // Guard against API returning a value not in the dropdown list
            const validGoals = [
              'weight_loss', 'muscle_gain', 'maintenance',
              'keto', 'intermittent_fasting'
            ];
            const validActivity = [
              'sedentary', 'light', 'moderate', 'active', 'very-active'
            ];
            final apiGoal = profile.goalType?.toString() ?? '';
            final apiActivity = profile.activityLevel?.toString() ?? '';
            _goal = validGoals.contains(apiGoal) ? apiGoal : 'maintenance';
            _activity = validActivity.contains(apiActivity)
                ? apiActivity
                : 'moderate';
            _diet = savedDiet;
            _planDurationWeeks = savedPlanWeeks;
            _mealsPerDay = savedMeals;
          } else {
            // API failed or profile not set — at least show saved email
            _contactCtrl.text = preferences.getString("email") ?? '';
            _diet = savedDiet;
            _planDurationWeeks = savedPlanWeeks;
            _mealsPerDay = savedMeals;
          }
          setState(() => _loading = false);
        }
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      // print("getProfile error: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? '';

      // Save local-only preferences
      await prefs.setString("dietPreference", _diet);
      await prefs.setInt("planDurationWeeks", _planDurationWeeks);
      await prefs.setInt("mealsPerDay", _mealsPerDay);
      // Record plan start date only once (when plan is first configured)
      if (prefs.getString("planStartDate") == null) {
        await prefs.setString(
          "planStartDate",
          DateTime.now().toIso8601String().substring(0, 10),
        );
      }

      // Save name, height, weight, goal, activity to backend
      await ApiCall().updateProfile(
        token: token,
        fullName: _nameCtrl.text.trim(),
        heightCm: _heightCtrl.text.trim(),
        weightKg: _weightCtrl.text.trim(),
        activityLevel: _activity,
        goalType: _goal,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved ✓")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    // Sign out from Firebase so Apple/Google re-login shows a fresh auth sheet
    await FirebaseAuth.instance.signOut();
    if (mounted) MyUtility.removePage(context, SplashScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: primaryOrangeDark,
        elevation: 0,
        title: const Text(
          "My Profile",
          style: TextStyle(
              color: primaryOrangeDark,
              fontWeight: FontWeight.w800,
              fontSize: 14),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryOrangeDark),
        actions: [
          IconButton(
            color: primaryOrangeDark,
            onPressed: () {
              MyUtility.changePage(context, SettingScreen());
            },
            icon: Icon(Icons.settings),
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile header card
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(20),
                child: EditableRoundImage(
                  imageUrl: FirebaseAuth.instance.currentUser?.photoURL ?? '',
                  size: 100,
                  name: _nameCtrl.text,
                  onEdit: () {
                    // open image picker / rescan / crop
                  },
                ),
              ),
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
                child: Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.person, color: primary, size: 30),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameCtrl.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _contactCtrl.text,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () {
                    //     // Optional: open change photo
                    //   },
                    //   icon: const Icon(Icons.edit, color: primary),
                    // )
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Form card
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Basic Details",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    InputField(
                      controller: _nameCtrl,
                      hintText: "Full name",
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    InputField(
                      controller: _contactCtrl,
                      hintText: "Email",
                      prefixIcon: Icons.email_outlined,
                      readOnly: true,
                    ),
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
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InputField(
                            controller: _weightCtrl,
                            hintText: "Weight (kg)",
                            prefixIcon: Icons.monitor_weight_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Preferences card
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Preferences",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _Dropdown(
                      label: "Goal",
                      value: _goal,
                      items: const [
                        'weight_loss',
                        'muscle_gain',
                        'maintenance',
                        'keto',
                        'intermittent_fasting'
                      ],
                      onChanged: (v) => setState(() => _goal = v),
                    ),
                    const SizedBox(height: 12),
                    _Dropdown(
                      label: "Activity",
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
                    const SizedBox(height: 12),
                    const Text(
                      "Diet Preference",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _Chip(
                          text: "Halal",
                          selected: _diet == "Halal",
                          onTap: () => setState(() => _diet = "Halal"),
                        ),
                        _Chip(
                          text: "Veg",
                          selected: _diet == "Veg",
                          onTap: () => setState(() => _diet = "Veg"),
                        ),
                        _Chip(
                          text: "Non-Veg",
                          selected: _diet == "Non-Veg",
                          onTap: () => setState(() => _diet = "Non-Veg"),
                        ),
                        _Chip(
                          text: "Keto",
                          selected: _diet == "Keto",
                          onTap: () => setState(() => _diet = "Keto"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Plan settings card
              _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Plan Settings",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Plan duration
                    const Text(
                      "Plan Duration",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [4, 8, 12, 16].map((w) {
                        return _Chip(
                          text: "$w weeks",
                          selected: _planDurationWeeks == w,
                          onTap: () =>
                              setState(() => _planDurationWeeks = w),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // Meals per day
                    const Text(
                      "Meals per Day",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [2, 3, 4, 5].map((m) {
                        return _Chip(
                          text: "$m meals",
                          selected: _mealsPerDay == m,
                          onTap: () => setState(() => _mealsPerDay = m),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Save button
              GradientButton(
                text: _saving ? "Saving..." : "Save Changes",
                enabled: !_saving,
                onPressed: _saveProfile,
                gradient: const LinearGradient(
                  colors: [primary, primary2],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),

              const SizedBox(height: 10),

              // Logout button
              OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: textPrimary),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                      color: textPrimary, fontWeight: FontWeight.w800),
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
      ),
    );
  }
}

// end of ProfileScreen

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: child,
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF9FAFB);
    const border = Color(0xFFE5E7EB);
    const textSecondary = Color(0xFF6B7280);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: border),
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

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.text, required this.selected, required this.onTap});

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF9800);
    const border = Color(0xFFE5E7EB);
    const textPrimary = Color(0xFF1F2937);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF3E0) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? primary : border),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? primary : textPrimary,
          ),
        ),
      ),
    );
  }
}
