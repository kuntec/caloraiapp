import 'package:calorai/constants/utility.dart';
import 'package:calorai/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';

class AddCustomMeal extends StatefulWidget {
  const AddCustomMeal({super.key});

  @override
  State<AddCustomMeal> createState() => _AddCustomMealState();
}

class _AddCustomMealState extends State<AddCustomMeal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Your FAB + bottom nav remains in main scaffold
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============= APP BAR ROW =============
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      MyUtility.removePage(context, MainNavigationScreen());
                    },
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

              const SizedBox(height: 25),

              // ============= ADD IMAGE BOX =============
              GestureDetector(
                onTap: () {
                  // TODO: open image picker
                },
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade100,
                        Colors.orange.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.orangeAccent, width: 1.2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.orange, width: 2),
                        ),
                        child: const Icon(Icons.add, color: Colors.orange),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Add Image",
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // ============= TITLE INPUT =============
              const _InputLabel(label: "Title"),
              const _TextInputField(
                hint: "Type here",
                icon: Icons.list_alt,
              ),

              const SizedBox(height: 18),

              // ============= SERVING SIZE DROPDOWN =============
              const _InputLabel(label: "Serving Size"),
              //const _DropdownField(),
              MealDropdownField(),
              const SizedBox(height: 18),

              // ============= CALORIES INPUT =============
              const _InputLabel(label: "Calories"),
              const _TextInputField(
                hint: "Type Here",
                icon: Icons.local_fire_department,
              ),

              const SizedBox(height: 18),

              // ============= CARBS INPUT =============
              const _InputLabel(label: "Carbs"),
              const _TextInputField(
                hint: "Type Here",
                icon: Icons.bubble_chart,
              ),

              const SizedBox(height: 18),

              // ============= PROTEINS INPUT =============
              const _InputLabel(label: "Proteins"),
              const _TextInputField(
                hint: "Type Here",
                icon: Icons.energy_savings_leaf_outlined,
              ),

              const SizedBox(height: 18),

              // ============= FATS INPUT =============
              const _InputLabel(label: "Fats"),
              const _TextInputField(
                hint: "Type Here",
                icon: Icons.water_drop,
              ),

              const SizedBox(height: 30),

              // ============= ADD BUTTON =============
              SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 30,
                    ),
                    label: const Text(
                      "Add",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  )),

              const SizedBox(height: 80), // to avoid FAB overlap
            ],
          ),
        ),
      ),
    );
  }
}

//
// ─────────────────────────────────────────
//   LABEL WIDGET
// ─────────────────────────────────────────
//
class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 15,
      ),
    );
  }
}

//
// ─────────────────────────────────────────
//   TEXT INPUT FIELD
// ─────────────────────────────────────────
//
class _TextInputField extends StatelessWidget {
  final String hint;
  final IconData icon;

  const _TextInputField({
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(icon, color: Colors.green, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────
//   DROPDOWN INPUT FIELD
// ─────────────────────────────────────────
//
// class _DropdownField extends StatelessWidget {
//   const _DropdownField();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 55,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.list_alt, color: Colors.green, size: 22),
//           const SizedBox(width: 12),
//
//           // Dropdown placeholder
//           Expanded(
//             child: Text(
//               "Select",
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//                 fontSize: 14,
//               ),
//             ),
//           ),
//
//           const Icon(Icons.keyboard_arrow_down_rounded, size: 26),
//         ],
//       ),
//     );
//   }
// }

class MealDropdownField extends StatefulWidget {
  const MealDropdownField({super.key});

  @override
  State<MealDropdownField> createState() => _MealDropdownFieldState();
}

class _MealDropdownFieldState extends State<MealDropdownField> {
  final List<String> items = [
    "Small (100g)",
    "Medium (150g)",
    "Large (200g)",
    "1 Cup",
    "1 Bowl",
  ];

  String? selectedValue;

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
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Row(
            children: [
              const Icon(Icons.list_alt, color: Colors.green),
              const SizedBox(width: 12),
              Text(
                "Select",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          isExpanded: true,
          items: items.map((e) {
            return DropdownMenuItem(
              value: e,
              child: Row(
                children: [
                  const Icon(Icons.list_alt, color: Colors.green),
                  const SizedBox(width: 12),
                  Text(e),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => selectedValue = value);
          },
        ),
      ),
    );
  }
}
