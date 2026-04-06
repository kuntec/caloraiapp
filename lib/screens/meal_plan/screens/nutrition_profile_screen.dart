import 'package:flutter/material.dart';
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

  Widget _dropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e.replaceAll("_", " ")),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
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
        title: const Text("Nutrition Profile"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Age"),
              validator: (v) => v == null || v.isEmpty ? "Enter age" : null,
            ),
            TextFormField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Height (cm)"),
              validator: (v) => v == null || v.isEmpty ? "Enter height" : null,
            ),
            TextFormField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Weight (kg)"),
              validator: (v) => v == null || v.isEmpty ? "Enter weight" : null,
            ),
            TextFormField(
              controller: targetWeightController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Target Weight (optional)"),
            ),
            const SizedBox(height: 12),
            _dropdownField(
              label: "Gender",
              value: gender,
              items: const ["male", "female"],
              onChanged: (v) => setState(() => gender = v!),
            ),
            _dropdownField(
              label: "Activity Level",
              value: activityLevel,
              items: const ["sedentary", "light", "moderate", "active"],
              onChanged: (v) => setState(() => activityLevel = v!),
            ),
            _dropdownField(
              label: "Goal",
              value: goal,
              items: const [
                "weight_loss",
                "weight_gain",
                "muscle_gain",
                "maintain"
              ],
              onChanged: (v) => setState(() => goal = v!),
            ),
            _dropdownField(
              label: "Diet Type",
              value: dietType,
              items: const ["veg", "non_veg", "vegan", "eggetarian"],
              onChanged: (v) => setState(() => dietType = v!),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Halal Required"),
              value: halalRequired,
              onChanged: (v) => setState(() => halalRequired = v),
            ),
            DropdownButtonFormField<int>(
              value: mealsPerDay,
              decoration: const InputDecoration(labelText: "Meals Per Day"),
              items: [3, 4, 5, 6]
                  .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                  .toList(),
              onChanged: (v) => setState(() => mealsPerDay = v ?? 4),
            ),
            TextFormField(
              controller: cuisineController,
              decoration: const InputDecoration(
                labelText: "Cuisine Preferences",
                hintText: "indian, arabic",
              ),
            ),
            TextFormField(
              controller: allergiesController,
              decoration: const InputDecoration(
                labelText: "Allergies",
                hintText: "nuts, dairy",
              ),
            ),
            TextFormField(
              controller: excludedFoodsController,
              decoration: const InputDecoration(
                labelText: "Excluded Foods",
                hintText: "broccoli, mushroom",
              ),
            ),
            TextFormField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Notes"),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Save & Generate Meal Plan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
