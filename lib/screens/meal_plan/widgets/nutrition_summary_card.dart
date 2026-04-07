import 'package:calorai/constants/constants.dart';
import 'package:flutter/material.dart';

class NutritionSummaryCard extends StatelessWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  const NutritionSummaryCard({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  Widget _buildItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: kContainerBox,
      //elevation: 0.8,
      //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Row(
          children: [
            _buildItem("Calories", calories.toStringAsFixed(0)),
            _buildItem("Protein", "${protein.toStringAsFixed(0)}g"),
            _buildItem("Carbs", "${carbs.toStringAsFixed(0)}g"),
            _buildItem("Fats", "${fats.toStringAsFixed(0)}g"),
          ],
        ),
      ),
    );
  }
}
