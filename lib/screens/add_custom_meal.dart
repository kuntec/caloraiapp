import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/models/FoodData.dart';
import 'package:calorai/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color _orange = Color(0xFFFF9800);

class AddCustomMeal extends StatefulWidget {
  const AddCustomMeal({super.key});

  @override
  State<AddCustomMeal> createState() => _AddCustomMealState();
}

class _AddCustomMealState extends State<AddCustomMeal> {
  // ── Controllers ──────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _caloriesCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatsCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────
  String _mealType = 'lunch';
  double _servingSize = 1;
  bool _isLoading = false;

  static const List<_MealOption> _mealOptions = [
    _MealOption('Breakfast', 'breakfast', Icons.wb_sunny_outlined),
    _MealOption('Lunch', 'lunch', Icons.lunch_dining_outlined),
    _MealOption('Dinner', 'dinner', Icons.dinner_dining_outlined),
    _MealOption('Snack', 'snack', Icons.apple_outlined),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _brandCtrl.dispose();
    _caloriesCtrl.dispose();
    _carbsCtrl.dispose();
    _proteinCtrl.dispose();
    _fatsCtrl.dispose();
    super.dispose();
  }

  // ── Submit ─────────────────────────────────────────────────
  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final caloriesStr = _caloriesCtrl.text.trim();

    if (name.isEmpty) {
      _snack('Please enter a food name.');
      return;
    }
    if (caloriesStr.isEmpty) {
      _snack('Please enter the calorie amount.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? '';

      // Build the Food object the API call expects
      final food = Food(
        id: '',
        name: name,
        brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
        description: null,
        servingSize: _servingSize,
        servingUnit: 'serving',
        servingsPerContainer: 1,
        source: 'user',
        nutrients: Nutrients(
          calories: double.tryParse(caloriesStr) ?? 0,
          proteinG: double.tryParse(_proteinCtrl.text) ?? 0,
          carbsG: double.tryParse(_carbsCtrl.text) ?? 0,
          fatsG: double.tryParse(_fatsCtrl.text) ?? 0,
          saturatedFatG: 0,
          polyunsaturatedFatG: 0,
          monounsaturatedFatG: 0,
          transFatG: 0,
          cholesterolMg: 0,
          fiberG: 0,
          sugarG: 0,
          sodiumMg: 0,
          potassiumMg: 0,
          vitaminAMcg: 0,
          vitaminCMg: 0,
          calciumMg: 0,
          ironMg: 0,
        ),
      );

      // Step 1: Create the food entry
      final foodData = await ApiCall().addFood(food, token);
      final createdId = foodData.food?.id ?? '';

      if (createdId.isEmpty) {
        _snack('Food was saved but could not be logged. Try again.');
        return;
      }

      // Step 2: Log it for today
      final now = DateTime.now();
      final date = DateFormat('yyyy-MM-dd').format(now);
      final time = DateFormat('hh:mm a').format(now);

      await ApiCall().addFoodLog(
        date, time, _mealType, createdId, 1, 'manual', token,
      );

      if (!mounted) return;
      _snack('Food logged successfully! 🎉');
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      MyUtility.removePage(context, const MainNavigationScreen());
    } catch (e) {
      if (mounted) _snack('Something went wrong. Please try again.');
      debugPrint('AddCustomMeal error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── APP BAR ──────────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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
                    "Add Custom Meal",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── MEAL TYPE SELECTOR ────────────────────────
              const _SectionLabel(label: "Meal Type"),
              const SizedBox(height: 10),
              Row(
                children: _mealOptions.map((opt) {
                  final selected = _mealType == opt.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _mealType = opt.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? _orange : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? _orange : Colors.grey.shade300,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(opt.icon,
                                size: 20,
                                color: selected ? Colors.white : Colors.grey.shade600),
                            const SizedBox(height: 4),
                            Text(
                              opt.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // ── FOOD NAME ─────────────────────────────────
              const _SectionLabel(label: "Food Name *"),
              _InputField(
                controller: _nameCtrl,
                hint: "e.g. Boiled Egg",
                icon: Icons.restaurant_menu_outlined,
              ),

              const SizedBox(height: 16),

              // ── BRAND (optional) ──────────────────────────
              const _SectionLabel(label: "Brand (optional)"),
              _InputField(
                controller: _brandCtrl,
                hint: "e.g. Home cooked",
                icon: Icons.label_outline,
              ),

              const SizedBox(height: 16),

              // ── SERVING SIZE ─────────────────────────────
              const _SectionLabel(label: "Serving Size"),
              _ServingDropdown(
                value: _servingSize,
                onChanged: (v) => setState(() => _servingSize = v ?? 1),
              ),

              const SizedBox(height: 22),

              // ── NUTRITION HEADER ──────────────────────────
              const _SectionLabel(label: "Nutrition (per serving)"),
              const SizedBox(height: 12),

              // ── CALORIES ──────────────────────────────────
              _InputField(
                controller: _caloriesCtrl,
                hint: "Calories *",
                icon: Icons.local_fire_department_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                iconColor: Colors.deepOrange,
              ),

              const SizedBox(height: 12),

              // ── MACROS ROW ────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _InputField(
                      controller: _carbsCtrl,
                      hint: "Carbs (g)",
                      icon: Icons.grain_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      iconColor: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InputField(
                      controller: _proteinCtrl,
                      hint: "Protein (g)",
                      icon: Icons.energy_savings_leaf_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      iconColor: Colors.green.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _InputField(
                controller: _fatsCtrl,
                hint: "Fats (g)",
                icon: Icons.water_drop_outlined,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                iconColor: Colors.blue.shade400,
              ),

              const SizedBox(height: 32),

              // ── ADD BUTTON ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    disabledBackgroundColor: _orange.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_outline, color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "Log Food",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//   MEAL TYPE OPTION MODEL
// ─────────────────────────────────────────────────────────────
class _MealOption {
  final String label;
  final String value;
  final IconData icon;
  const _MealOption(this.label, this.value, this.icon);
}

// ─────────────────────────────────────────────────────────────
//   SECTION LABEL
// ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//   INPUT FIELD
// ─────────────────────────────────────────────────────────────
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color? iconColor;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.iconColor,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, color: iconColor ?? Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//   SERVING SIZE DROPDOWN
// ─────────────────────────────────────────────────────────────
class _ServingDropdown extends StatelessWidget {
  final double value;
  final ValueChanged<double?> onChanged;

  const _ServingDropdown({required this.value, required this.onChanged});

  static const _options = [
    _ServingItem(0.5, '½ serving (0.5)'),
    _ServingItem(1.0, '1 serving'),
    _ServingItem(1.5, '1.5 servings'),
    _ServingItem(2.0, '2 servings'),
    _ServingItem(3.0, '3 servings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<double>(
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          isExpanded: true,
          items: _options.map((o) {
            return DropdownMenuItem(
              value: o.value,
              child: Row(
                children: [
                  const Icon(Icons.list_alt, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Text(o.label,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ServingItem {
  final double value;
  final String label;
  const _ServingItem(this.value, this.label);
}
