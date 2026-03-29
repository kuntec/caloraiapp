import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/screens/add_custom_meal.dart';
import 'package:calorai/screens/ai_detection_result_screen.dart';
import 'package:calorai/screens/dashboard_screen.dart';
import 'package:calorai/screens/exercise/log_exercise.dart';
import 'package:calorai/screens/food/log_food.dart';
import 'package:calorai/screens/food/food_logging_screen.dart';
import 'package:calorai/screens/streak_screen.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  dynamic screens = [
    DashboardScreen(),
    LogFood(),
    LogExercise(),
    StreakScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("Main Navigation Screen"),
      // ),
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        children: [
          // Background bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                    icon: Icons.home,
                    label: "Calor AI",
                    active: _selectedIndex == 0 ? true : false,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    }),
                _NavItem(
                    icon: Icons.restaurant_menu,
                    label: "Food",
                    active: _selectedIndex == 1 ? true : false,
                    onTap: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                      // MyUtility.changePage(context, AddCustomMeal());
                      // Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => AddCustomMeal()));
                    }),
                const SizedBox(width: 50), // space for center button
                _NavItem(
                  icon: Icons.directions_run,
                  label: "Exercises",
                  active: _selectedIndex == 2 ? true : false,
                  onTap: () async {
                    setState(() {
                      _selectedIndex = 2;
                    });
                    //await MyUtility.changePage(context, LogExercise());
                    //print("Return from Challenges");
                  },
                ),
                _NavItem(
                  icon: Icons.flag,
                  label: "Challenges",
                  active: _selectedIndex == 3 ? true : false,
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                    //MyUtility.changePage(context, FoodLogingsScreen());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () {
          MyUtility.changePage(context, AiDetectionResultScreen());
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryOrangeDark,
            border: Border.all(color: Colors.transparent, width: 5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(Icons.camera, size: 42, color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: screens[_selectedIndex],
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final dynamic onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: active ? Color(0xFFFFA53B) : Colors.black54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: active ? Color(0xFFFFA53B) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
