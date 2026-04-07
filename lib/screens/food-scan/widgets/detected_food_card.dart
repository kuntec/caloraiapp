import 'package:flutter/material.dart';
import '../models/food_scan_model.dart';

class DetectedFoodCard extends StatelessWidget {
  final DetectedFoodItem item;

  const DetectedFoodCard({super.key, required this.item});

  String get confidenceText {
    return "${(item.confidence * 100).toStringAsFixed(0)}%";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (item.estimatedQuantity.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                item.estimatedQuantity,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _chip("🔥 ${item.calories.toStringAsFixed(0)} kcal"),
                _chip("🥩 ${item.protein.toStringAsFixed(0)}g P"),
                _chip("🍚 ${item.carbs.toStringAsFixed(0)}g C"),
                _chip("🥑 ${item.fats.toStringAsFixed(0)}g F"),
                _chip("⚖️ ${item.estimatedWeightGrams.toStringAsFixed(0)}g"),
                _chip("🎯 $confidenceText"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}
