import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/models/UserRegisterData.dart';
import 'package:calorai/widgets/app_dialogs.dart';
import 'package:calorai/widgets/gradient_button.dart';
import 'package:calorai/widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nutrition_profile_model.dart';
import '../services/meal_plan_service.dart';
import 'generated_meal_plan_screen.dart';

class NutritionProfileScreen extends StatefulWidget {
  final String userId;

  const NutritionProfileScreen({super.key, required this.userId});

  @override
  State<NutritionProfileScreen> createState() => _NutritionProfileScreenState();
}

class _NutritionProfileScreenState extends State<NutritionProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final cuisineController = TextEditingController();
  final allergiesController = TextEditingController();
  final excludedFoodsController = TextEditingController();
  final notesController = TextEditingController();

  String gender = "male";
  String activityLevel = "moderate";
  String goal = "weight_loss";
  String dietType = "non_veg";
  bool halalRequired = true;
  int mealsPerDay = 4;

  bool isLoading = false;

  final service = MealPlanService();

  List<String> _splitComma(String value) {
    return value
        .split(",")
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _submit() async {
    print(widget.userId);
    print(ageController.text);
    print(heightController.text);
    print(weightController.text);
    print(targetWeightController.text);
    print(gender);
    print(activityLevel);
    print(goal);
    print(dietType);
    print(halalRequired);
    print(mealsPerDay);
    print(cuisineController.text.toLowerCase());
    print(allergiesController.text.toLowerCase());
    print(excludedFoodsController.text.toLowerCase());
    print(notesController.text);

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final profile = NutritionProfile(
        userId: widget.userId,
        age: int.parse(ageController.text.trim()),
        gender: gender,
        heightCm: double.parse(heightController.text.trim()),
        weightKg: double.parse(weightController.text.trim()),
        targetWeightKg: targetWeightController.text.trim().isNotEmpty
            ? double.parse(targetWeightController.text.trim())
            : null,
        activityLevel: activityLevel,
        goal: goal,
        dietType: dietType,
        halalRequired: halalRequired,
        mealsPerDay: mealsPerDay,
        cuisinePreference: _splitComma(cuisineController.text),
        allergies: _splitComma(allergiesController.text),
        excludedFoods: _splitComma(excludedFoodsController.text),
        notes: notesController.text.trim(),
      );
      //print(profile.toString());
      await service.saveProfile(profile);
      final mealPlan = await service.generateMealPlan(widget.userId);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => GeneratedMealPlanScreen(mealPlan: mealPlan),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Widget _dropdownField({
  //   required String label,
  //   required String value,
  //   required List<String> items,
  //   required Function(String?) onChanged,
  // }) {
  //   return DropdownButtonFormField<String>(
  //     value: value,
  //     decoration: InputDecoration(labelText: label),
  //     items: items
  //         .map(
  //           (e) => DropdownMenuItem(
  //             value: e,
  //             child: Text(e.replaceAll("_", " ")),
  //           ),
  //         )
  //         .toList(),
  //     onChanged: onChanged,
  //   );
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProfile();
  }

  Future<void> getProfile() async {
    setState(() {
      isLoading = true;
    });
    print(FirebaseAuth.instance.currentUser!.email);
    print(FirebaseAuth.instance.currentUser!.displayName);
    print(FirebaseAuth.instance.currentUser!.photoURL);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? email = preferences.getString("email");
    String? password = preferences.getString("uid");
    if (email != null && password != null) {
      ApiCall apiCall = ApiCall();
      UserRegisterData userRegisterData = await apiCall.login(email, password);
      if (userRegisterData.status) {
        // _nameCtrl.text = userRegisterData.user!.profile!.fullName;
        heightController.text =
            userRegisterData.user!.profile!.heightCm.toString();
        weightController.text =
            userRegisterData.user!.profile!.weightKg.toString();
        goal = userRegisterData.user!.profile!.goalType;
        activityLevel = userRegisterData.user!.profile!.activityLevel;
        dietType = userRegisterData.user!.profile!.dailyStepGoal.toString();
        gender = userRegisterData.user!.profile!.gender.toString();
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    targetWeightController.dispose();
    cuisineController.dispose();
    allergiesController.dispose();
    excludedFoodsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: primaryOrangeDark,
        elevation: 0,
        title: const Text(
          "Nutrition Profile",
          style: TextStyle(
              color: primaryOrangeDark,
              fontWeight: FontWeight.w800,
              fontSize: 14),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: primaryOrangeDark),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryOrangeLight,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Basic Details",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              // const SizedBox(height: 12),
                              // InputField(
                              //   controller: _nameCtrl,
                              //   hintText: "Full name",
                              //   prefixIcon: Icons.person_outline,
                              // ),

                              const SizedBox(height: 8),
                              const Text(
                                "Gender",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _Chip(
                                    text: "Male",
                                    selected: gender == "male",
                                    onTap: () =>
                                        setState(() => gender = "male"),
                                  ),
                                  _Chip(
                                    text: "Female",
                                    selected: gender == "female",
                                    onTap: () =>
                                        setState(() => gender = "female"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              InputField(
                                keyboardType: TextInputType.number,
                                controller: ageController,
                                hintText: "Age",
                                prefixIcon: Icons.person,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: InputField(
                                      controller: heightController,
                                      hintText: "Height (cm)",
                                      prefixIcon: Icons.height,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InputField(
                                      controller: weightController,
                                      hintText: "Weight (kg)",
                                      prefixIcon: Icons.monitor_weight_outlined,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              InputField(
                                keyboardType: TextInputType.number,
                                controller: ageController,
                                hintText: "Target Weight (optional)",
                                prefixIcon: Icons.monitor_weight_outlined,
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
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _Dropdown(
                                label: "Goal",
                                value: goal,
                                items: const [
                                  'weight_loss',
                                  'muscle_gain',
                                  'maintenance',
                                  'keto',
                                  'intermittent_fasting'
                                ],
                                onChanged: (v) => setState(() => goal = v),
                              ),
                              const SizedBox(height: 12),
                              _Dropdown(
                                label: "Activity",
                                value: activityLevel,
                                items: const [
                                  'sedentary',
                                  'light',
                                  'moderate',
                                  'active',
                                  'very-active'
                                ],
                                onChanged: (v) =>
                                    setState(() => activityLevel = v),
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
                                    text: "Veg",
                                    selected: dietType == "Veg",
                                    onTap: () =>
                                        setState(() => dietType = "Veg"),
                                  ),
                                  _Chip(
                                    text: "Non-Veg",
                                    selected: dietType == "Non-Veg",
                                    onTap: () =>
                                        setState(() => dietType = "Non-Veg"),
                                  ),
                                  _Chip(
                                    text: "Keto",
                                    selected: dietType == "Keto",
                                    onTap: () =>
                                        setState(() => dietType = "Keto"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                activeThumbColor: primaryOrangeDark,
                                title: const Text(
                                  "Halal Required",
                                  style: TextStyle(fontSize: 14),
                                ),
                                value: halalRequired,
                                onChanged: (v) =>
                                    setState(() => halalRequired = v),
                              ),
                              const Text(
                                "Meals Per Day",
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
                                    text: "3",
                                    selected: mealsPerDay == 3,
                                    onTap: () =>
                                        setState(() => mealsPerDay = 3),
                                  ),
                                  _Chip(
                                    text: "4",
                                    selected: mealsPerDay == 4,
                                    onTap: () =>
                                        setState(() => mealsPerDay = 4),
                                  ),
                                  _Chip(
                                    text: "5",
                                    selected: mealsPerDay == 5,
                                    onTap: () =>
                                        setState(() => mealsPerDay = 5),
                                  ),
                                  _Chip(
                                    text: "6",
                                    selected: mealsPerDay == 6,
                                    onTap: () =>
                                        setState(() => mealsPerDay = 6),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Preferences card
                        const SizedBox(height: 14),
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Additional Details",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Cuisine Preference",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InputField(
                                keyboardType: TextInputType.text,
                                controller: cuisineController,
                                hintText: "Cuisine Preferences",
                                prefixIcon: Icons.restaurant,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Allergies / Diseases",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InputField(
                                keyboardType: TextInputType.text,
                                controller: allergiesController,
                                hintText: "Allergies / Diseases",
                                prefixIcon: Icons.thermostat,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Excluded Foods",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InputField(
                                keyboardType: TextInputType.text,
                                controller: excludedFoodsController,
                                hintText: "Excluded Foods",
                                prefixIcon: Icons.cancel,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Notes",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              InputField(
                                keyboardType: TextInputType.text,
                                controller: notesController,
                                hintText: "Notes",
                                prefixIcon: Icons.document_scanner,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Save button
                        GradientButton(
                          text: isLoading
                              ? "Generating..."
                              : "Save & Generate Meal Plan",
                          enabled: !isLoading,
                          onPressed: _submit,
                          gradient: const LinearGradient(
                            colors: [primary, primary2],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ]))),
      // appBar: AppBar(
      //   title: const Text("Nutrition Profile"),
      // ),

      // body: Form(
      //   key: _formKey,
      //   child: ListView(
      //     padding: const EdgeInsets.all(16),
      //     children: [
      //       const SizedBox(height: 10),
      //       const _InputLabel(label: "Age"),
      //       InputField(
      //         controller: ageController,
      //         hintText: "Age",
      //         prefixIcon: Icons.numbers,
      //       ),
      //       const SizedBox(height: 10),
      //       const _InputLabel(label: "Height"),
      //       InputField(
      //         controller: heightController,
      //         hintText: "Height",
      //         prefixIcon: Icons.numbers,
      //       ),
      //       const SizedBox(height: 10),
      //       const _InputLabel(label: "Weight"),
      //       InputField(
      //         controller: weightController,
      //         hintText: "Weight",
      //         prefixIcon: Icons.numbers,
      //       ),
      //       const SizedBox(height: 10),
      //       const _InputLabel(label: "Target Weight (optional)"),
      //       InputField(
      //         controller: targetWeightController,
      //         hintText: "Weight",
      //         prefixIcon: Icons.numbers,
      //       ),
      //       const SizedBox(height: 10),
      //       const _InputLabel(label: "Target Weight (optional)"),
      //
      //       InputField(
      //         controller: targetWeightController,
      //         hintText: "Weight",
      //         prefixIcon: Icons.numbers,
      //       ),
      //       const SizedBox(height: 10),
      //       const _InputLabel(label: "Gender"),
      //       //Wrap
      //       Wrap(
      //         spacing: 10,
      //         runSpacing: 10,
      //         children: [
      //           _Chip(
      //             text: "Male",
      //             selected: gender == "male",
      //             onTap: () => setState(() => gender = "male"),
      //           ),
      //           _Chip(
      //             text: "Female",
      //             selected: gender == "female",
      //             onTap: () => setState(() => gender = "female"),
      //           ),
      //         ],
      //       ),
      //
      //       const SizedBox(height: 10),
      //       const _InputLabel(label: "Activity Level"),
      //       //Wrap
      //       Wrap(
      //         spacing: 10,
      //         runSpacing: 10,
      //         children: [
      //           //sedentary
      //           _Chip(
      //             text: "Sedentary",
      //             selected: activityLevel == "sedentary",
      //             onTap: () => setState(() => activityLevel = "sedentary"),
      //           ),
      //           _Chip(
      //             text: "Light",
      //             selected: activityLevel == "light",
      //             onTap: () => setState(() => activityLevel = "light"),
      //           ),
      //           _Chip(
      //             text: "Moderate",
      //             selected: activityLevel == "moderate",
      //             onTap: () => setState(() => activityLevel = "moderate"),
      //           ),
      //           _Chip(
      //             text: "Active",
      //             selected: activityLevel == "active",
      //             onTap: () => setState(() => activityLevel = "active"),
      //           ),
      //           _Chip(
      //             text: "Very Active",
      //             selected: activityLevel == "very-active",
      //             onTap: () => setState(() => activityLevel = "very-active"),
      //           ),
      //         ],
      //       ),
      //
      //       // TextFormField(
      //       //   controller: ageController,
      //       //   keyboardType: TextInputType.number,
      //       //   decoration: const InputDecoration(labelText: "Age"),
      //       //   validator: (v) => v == null || v.isEmpty ? "Enter age" : null,
      //       // ),
      //       // TextFormField(
      //       //   controller: heightController,
      //       //   keyboardType: TextInputType.number,
      //       //   decoration: const InputDecoration(labelText: "Height (cm)"),
      //       //   validator: (v) => v == null || v.isEmpty ? "Enter height" : null,
      //       // ),
      //       // TextFormField(
      //       //   controller: weightController,
      //       //   keyboardType: TextInputType.number,
      //       //   decoration: const InputDecoration(labelText: "Weight (kg)"),
      //       //   validator: (v) => v == null || v.isEmpty ? "Enter weight" : null,
      //       // ),
      //       // TextFormField(
      //       //   controller: targetWeightController,
      //       //   keyboardType: TextInputType.number,
      //       //   decoration:
      //       //       const InputDecoration(labelText: "Target Weight (optional)"),
      //       // ),
      //       //const SizedBox(height: 12),
      //       // _dropdownField(
      //       //   label: "Gender",
      //       //   value: gender,
      //       //   items: const ["male", "female"],
      //       //   onChanged: (v) => setState(() => gender = v!),
      //       // ),
      //       // _dropdownField(
      //       //   label: "Activity Level",
      //       //   value: activityLevel,
      //       //   items: const ["sedentary", "light", "moderate", "active"],
      //       //   onChanged: (v) => setState(() => activityLevel = v!),
      //       // ),
      //       // _dropdownField(
      //       //   label: "Goal",
      //       //   value: goal,
      //       //   items: const [
      //       //     "weight_loss",
      //       //     "weight_gain",
      //       //     "muscle_gain",
      //       //     "maintain"
      //       //   ],
      //       //   onChanged: (v) => setState(() => goal = v!),
      //       // ),
      //       // _dropdownField(
      //       //   label: "Diet Type",
      //       //   value: dietType,
      //       //   items: const ["veg", "non_veg", "vegan", "eggetarian"],
      //       //   onChanged: (v) => setState(() => dietType = v!),
      //       // ),
      //       //const SizedBox(height: 12),
      //       SwitchListTile(
      //         contentPadding: EdgeInsets.zero,
      //         activeThumbColor: primaryOrangeDark,
      //         title: const Text("Halal Required"),
      //         value: halalRequired,
      //         onChanged: (v) => setState(() => halalRequired = v),
      //       ),
      //       const SizedBox(height: 10),
      //       const _InputLabel(label: "Diet Type"),
      //       //Wrap
      //       Wrap(
      //         spacing: 10,
      //         runSpacing: 10,
      //         children: [
      //           _Chip(
      //             text: "Male",
      //             selected: gender == "male",
      //             onTap: () => setState(() => gender = "male"),
      //           ),
      //           _Chip(
      //             text: "Female",
      //             selected: gender == "female",
      //             onTap: () => setState(() => gender = "female"),
      //           ),
      //         ],
      //       ),
      //       DropdownButtonFormField<int>(
      //         value: mealsPerDay,
      //         decoration: const InputDecoration(labelText: "Meals Per Day"),
      //         items: [3, 4, 5, 6]
      //             .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
      //             .toList(),
      //         onChanged: (v) => setState(() => mealsPerDay = v ?? 4),
      //       ),
      //       TextFormField(
      //         controller: cuisineController,
      //         decoration: const InputDecoration(
      //           labelText: "Cuisine Preferences",
      //           hintText: "indian, arabic",
      //         ),
      //       ),
      //       TextFormField(
      //         controller: allergiesController,
      //         decoration: const InputDecoration(
      //           labelText: "Allergies",
      //           hintText: "nuts, dairy",
      //         ),
      //       ),
      //       TextFormField(
      //         controller: excludedFoodsController,
      //         decoration: const InputDecoration(
      //           labelText: "Excluded Foods",
      //           hintText: "broccoli, mushroom",
      //         ),
      //       ),
      //       TextFormField(
      //         controller: notesController,
      //         maxLines: 3,
      //         decoration: const InputDecoration(labelText: "Notes"),
      //       ),
      //       const SizedBox(height: 24),
      //       SizedBox(
      //         height: 52,
      //         child: ElevatedButton(
      //           onPressed: isLoading ? null : _submit,
      //           child: isLoading
      //               ? const CircularProgressIndicator()
      //               : const Text("Save & Generate Meal Plan"),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
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
