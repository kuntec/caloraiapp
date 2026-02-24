import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/screens/coming_soon.dart';
import 'package:calorai/screens/exercise/add_burned_calories.dart';
import 'package:calorai/screens/exercise/log_exercise_details.dart';
import 'package:flutter/material.dart';

class LogExercise extends StatefulWidget {
  const LogExercise({super.key});

  @override
  State<LogExercise> createState() => _LogExerciseState();
}

class _LogExerciseState extends State<LogExercise> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Log Exercise",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        // leading: Padding(
        //   padding: const EdgeInsets.all(10),
        //   child: _CircleIconButton(
        //     onTap: () => Navigator.pop(context),
        //     icon: Icons.arrow_back_ios_new_rounded,
        //     iconColor: Colors.black,
        //     background: Colors.white,
        //     borderColor: const Color(0xFFE5E7EB),
        //   ),
        // ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(right: 12),
          //   child: _CircleIconButton(
          //     onTap: () {},
          //     icon: Icons.add,
          //     iconColor: Colors.white,
          //     background: const Color(0xFF36B24A),
          //     borderColor: Colors.transparent,
          //   ),
          // )
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(children: [
            exerciseBox(
                Icons.run_circle, "Run", "Running, jogging, sprinting, etc.",
                () {
              MyUtility.changePage(
                  context,
                  RunSetupScreen(
                    title: "Run",
                  ));
            }),
            exerciseBox(Icons.line_weight, "Weight lifting",
                "Machines, free weights, etc", () {
              MyUtility.changePage(
                  context,
                  RunSetupScreen(
                    title: "Weight lifting",
                  ));
            }),
            exerciseBox(
                Icons.description, "Describe", "Write your workout in text",
                () {
              MyUtility.changePage(context, ComingSoon());
            }),
            exerciseBox(Icons.local_fire_department_outlined, "Manual",
                "Enter exactly how many calories you burned", () {
              MyUtility.changePage(
                  context,
                  AddBurnedCaloriesScreen(
                    type: "manual",
                    name: "Manual Calorie",
                    intensity: "Normal",
                    durationMinutes: 0,
                    caloriesBurned: 0,
                  ));
            })
          ])),
    );
  }

  Widget exerciseBox(
      dynamic icon, dynamic title, dynamic subtitle, dynamic onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 80,
        margin: EdgeInsets.only(bottom: 30),
        decoration: kContainerBox,
        child: Row(
          children: [
            SizedBox(width: 20),
            Icon(
              icon,
              size: 50,
            ),
            SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
