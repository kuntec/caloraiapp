import 'package:calorai/constants/constants.dart';
import 'package:flutter/material.dart';
import '../models/meal_plan_model.dart';

class MealCard extends StatelessWidget {
  final MealItem meal;

  const MealCard({super.key, required this.meal});

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kContainerBox,
      //elevation: 0.8,
      margin: const EdgeInsets.only(bottom: 14),
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _capitalize(meal.type),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              meal.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              meal.servingSize,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: meal.ingredients
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        //color: Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                    child: Text("🔥 ${meal.calories.toStringAsFixed(0)} kcal")),
                Expanded(
                    child: Text("🥩 ${meal.protein.toStringAsFixed(0)}g P")),
                Expanded(child: Text("🍚 ${meal.carbs.toStringAsFixed(0)}g C")),
                Expanded(child: Text("🥑 ${meal.fats.toStringAsFixed(0)}g F")),
              ],
            ),
            if (meal.notes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                meal.notes,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
