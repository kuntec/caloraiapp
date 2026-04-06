import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/models/FoodData.dart';
import 'package:calorai/screens/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateFood extends StatefulWidget {
  const CreateFood({super.key});

  @override
  State<CreateFood> createState() => _CreateFoodState();
}

class _CreateFoodState extends State<CreateFood> {
  TextEditingController nameCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();
  TextEditingController servingSizeCtrl = TextEditingController();
  TextEditingController servingPerContCtrl = TextEditingController();
  TextEditingController caloriesCtrl = TextEditingController();

  TextEditingController proteinCtrl = TextEditingController();
  TextEditingController carbsCtrl = TextEditingController();
  TextEditingController fatCtrl = TextEditingController();
  TextEditingController saturatedFatCtrl = TextEditingController();
  TextEditingController polyFatCtrl = TextEditingController();
  TextEditingController monoFatCtrl = TextEditingController();
  TextEditingController transFatCtrl = TextEditingController();
  TextEditingController cholesterolCtrl = TextEditingController();
  TextEditingController fiberCtrl = TextEditingController();
  TextEditingController sugarCtrl = TextEditingController();
  TextEditingController sodiumCtrl = TextEditingController();
  TextEditingController potassiumCtrl = TextEditingController();
  TextEditingController vitaminACtrl = TextEditingController();
  TextEditingController vitaminCCtrl = TextEditingController();
  TextEditingController calciumCtrl = TextEditingController();
  TextEditingController ironCtrl = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F7FB);
    const card = Color(0xFFF3F2F8);
    const ink = primaryOrangeDark;
    return Scaffold(
      backgroundColor: bg,
      // Your FAB + bottom nav remains in main scaffold
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Create Food",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============= APP BAR ROW =============
              // Row(
              //   children: [
              //     GestureDetector(
              //       onTap: () {
              //         Navigator.pop(context);
              //       },
              //       child: Container(
              //         padding: const EdgeInsets.all(8),
              //         decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(12),
              //           color: Colors.grey.shade200,
              //         ),
              //         child: const Icon(Icons.arrow_back_ios_new, size: 18),
              //       ),
              //     ),
              //     const SizedBox(width: 12),
              //     const Text(
              //       "Create Food",
              //       style: TextStyle(
              //         fontSize: 18,
              //         fontWeight: FontWeight.w700,
              //       ),
              //     ),
              //   ],
              // ),
              // ============= ADD IMAGE BOX =============
              // GestureDetector(
              //   onTap: () {
              //     // TODO: open image picker
              //   },
              //   child: Container(
              //     height: 140,
              //     width: double.infinity,
              //     decoration: BoxDecoration(
              //       gradient: LinearGradient(
              //         colors: [
              //           Colors.orange.shade100,
              //           Colors.orange.shade50,
              //         ],
              //         begin: Alignment.topLeft,
              //         end: Alignment.bottomRight,
              //       ),
              //       borderRadius: BorderRadius.circular(18),
              //       border: Border.all(color: Colors.orangeAccent, width: 1.2),
              //     ),
              //     child: Column(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Container(
              //           padding: const EdgeInsets.all(10),
              //           decoration: BoxDecoration(
              //             shape: BoxShape.circle,
              //             border: Border.all(color: Colors.orange, width: 2),
              //           ),
              //           child: const Icon(Icons.add, color: Colors.orange),
              //         ),
              //         const SizedBox(height: 10),
              //         const Text(
              //           "Add Image",
              //           style: TextStyle(
              //             color: Colors.orange,
              //             fontWeight: FontWeight.w600,
              //             fontSize: 15,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // ============= TITLE INPUT =============
              const _InputLabel(label: "Name"),
              _TextInputField(
                controller: nameCtrl,
                hint: "Enter name",
                icon: Icons.list_alt,
              ),

              const SizedBox(height: 18),

              const _InputLabel(label: "Description"),
              _TextInputField(
                controller: descriptionCtrl,
                hint: "Enter description",
                icon: Icons.list_alt,
              ),

              const SizedBox(height: 18),

              const _InputLabel(label: "Serving size"),
              _TextInputField(
                controller: servingSizeCtrl,
                hint: "Enter serving size",
                icon: Icons.list_alt,
              ),

              const SizedBox(height: 18),

              const _InputLabel(label: "Serving per container"),
              _TextInputField(
                controller: servingPerContCtrl,
                hint: "Enter serving per container",
                icon: Icons.list_alt,
              ),

              const SizedBox(height: 18),

              // ============= SERVING SIZE DROPDOWN =============
              //const _InputLabel(label: "Serving Size"),
              //const _DropdownField(),
              //MealDropdownField(),
              //const SizedBox(height: 18),

              // ============= CALORIES INPUT =============
              const _InputLabel(label: "Calories*"),
              _TextInputField(
                controller: caloriesCtrl,
                hint: "Calories",
                icon: Icons.local_fire_department,
              ),

              const SizedBox(height: 18),

              // ============= CALORIES INPUT =============
              const _InputLabel(label: "Additional Info (optional)"),
              const SizedBox(height: 18),
              //Proteins + Carbs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Protein (g)"),
                          _TextInputField(
                            controller: proteinCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Carbs (g)"),
                          _TextInputField(
                            controller: carbsCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              //Proteins + Carbs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Fat (g)"),
                          _TextInputField(
                            controller: fatCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Saturated Fat (g)"),
                          _TextInputField(
                            controller: saturatedFatCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              //Proteins + Carbs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Polyunsaturated Fat (g)"),
                          _TextInputField(
                            controller: polyFatCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Monounsaturated Fat (g)"),
                          _TextInputField(
                            controller: monoFatCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              //Proteins + Carbs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Trans Fat (g)"),
                          _TextInputField(
                            controller: transFatCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Cholesterol (mg)"),
                          _TextInputField(
                            controller: cholesterolCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              //Proteins + Carbs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Fiber (g)"),
                          _TextInputField(
                            controller: fiberCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Sugar (g)"),
                          _TextInputField(
                            controller: sugarCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              //Proteins + Carbs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Sodium (mg)"),
                          _TextInputField(
                            controller: sodiumCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Potassium (mg)"),
                          _TextInputField(
                            controller: potassiumCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              //Proteins + Carbs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Vitamin A (mcg)"),
                          _TextInputField(
                            controller: vitaminACtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Vitamin C (mg)"),
                          _TextInputField(
                            controller: vitaminCCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              //Proteins + Carbs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Calcium (mg)"),
                          _TextInputField(
                            controller: calciumCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Flexible(
                    child: Container(
                      child: Column(
                        children: [
                          const _InputLabel(label: "Iron (mg)"),
                          _TextInputField(
                            controller: ironCtrl,
                            hint: "0",
                            icon: Icons.bubble_chart,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // // ============= CARBS INPUT =============
              // const _InputLabel(label: "Carbs"),
              // const _TextInputField(
              //   hint: "Type Here",
              //   icon: Icons.bubble_chart,
              // ),
              //
              // const SizedBox(height: 18),
              //
              // // ============= PROTEINS INPUT =============
              // const _InputLabel(label: "Proteins"),
              // const _TextInputField(
              //   hint: "Type Here",
              //   icon: Icons.energy_savings_leaf_outlined,
              // ),
              //
              // const SizedBox(height: 18),
              //
              // // ============= FATS INPUT =============
              // const _InputLabel(label: "Fats"),
              // const _TextInputField(
              //   hint: "Type Here",
              //   icon: Icons.water_drop,
              // ),

              const SizedBox(height: 30),

              // ============= ADD BUTTON =============
              isLoading
                  ? CircularProgressIndicator(
                      color: primaryOrangeLight,
                    )
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          addFood();
                        },
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

  Future<void> addFood() async {
    setState(() {
      isLoading = true;
    });
    ApiCall apiCall = ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? token = preferences.getString("token");
    Nutrients nutrients = Nutrients();
    nutrients.calories = caloriesCtrl.text.toString();
    nutrients.proteinG = proteinCtrl.text.toString();
    nutrients.carbsG = carbsCtrl.text.toString();
    nutrients.fatsG = fatCtrl.text.toString();
    nutrients.saturatedFatG = saturatedFatCtrl.text.toString();
    nutrients.polyunsaturatedFatG = polyFatCtrl.text.toString();
    nutrients.monounsaturatedFatG = monoFatCtrl.text.toString();
    nutrients.transFatG = transFatCtrl.text.toString();
    nutrients.cholesterolMg = cholesterolCtrl.text.toString();
    nutrients.fiberG = fiberCtrl.text.toString();
    nutrients.sugarG = sugarCtrl.text.toString();
    nutrients.sodiumMg = sodiumCtrl.text.toString();
    nutrients.potassiumMg = potassiumCtrl.text.toString();
    nutrients.vitaminAMcg = vitaminACtrl.text.toString();
    nutrients.vitaminCMg = vitaminCCtrl.text.toString();
    nutrients.calciumMg = calciumCtrl.text.toString();
    nutrients.ironMg = ironCtrl.text.toString();

    Food food = Food();
    food.name = nameCtrl.text.toString();
    food.brand = "Home";
    food.description = descriptionCtrl.text.toString();
    food.servingSize = servingSizeCtrl.text.toString();
    food.servingsPerContainer = servingPerContCtrl.text.toString();
    food.nutrients = nutrients;
    food.source = "user";

    FoodData foodData = await apiCall.addFood(food, token!);
    print(foodData);
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
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
  final TextEditingController controller;

  const _TextInputField({
    required this.controller,
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
              controller: controller,
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
