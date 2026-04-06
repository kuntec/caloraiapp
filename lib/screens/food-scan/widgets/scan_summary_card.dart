import 'package:flutter/material.dart';

class ScanSummaryCard extends StatelessWidget {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  const ScanSummaryCard({
    super.key,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  Widget _item(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Row(
          children: [
            _item("Calories", calories.toStringAsFixed(0)),
            _item("Protein", "${protein.toStringAsFixed(0)}g"),
            _item("Carbs", "${carbs.toStringAsFixed(0)}g"),
            _item("Fats", "${fats.toStringAsFixed(0)}g"),
          ],
        ),
      ),
    );
  }
}
