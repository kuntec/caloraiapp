import 'package:flutter/material.dart';
import '../models/daily_status_model.dart';

class TodayProgressCard extends StatelessWidget {
  final DailyStatus status;

  const TodayProgressCard({super.key, required this.status});

  Widget buildItem(String title, bool done) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Icon(
          done ? Icons.check_circle : Icons.cancel,
          color: done ? Colors.green : Colors.grey,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildItem("Food Logged", status.hasFoodLog),
            buildItem("Exercise", status.hasExerciseLog),
            buildItem("Water Goal", status.waterGoalMet),
            buildItem("Steps Goal", status.stepsGoalMet),
          ],
        ),
      ),
    );
  }
}
