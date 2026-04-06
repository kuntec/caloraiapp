import 'package:calorai/api/api_call.dart';
import 'package:calorai/components/CalorieRing.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/models/DailyMetricsData.dart';
import 'package:calorai/models/RecentActivityData.dart';
import 'package:calorai/screens/add_custom_meal.dart';
import 'package:calorai/screens/ai_detection_result_screen.dart';
import 'package:calorai/screens/challenges_screen.dart';
import 'package:calorai/screens/connect_health_screen.dart';
import 'package:calorai/screens/food-scan/screens/food_scan_home_screen.dart';
import 'package:calorai/screens/food/food_logging_screen.dart';
import 'package:calorai/screens/exercise/log_exercise.dart';
import 'package:calorai/screens/meal_plan/screens/meal_plan_home_screen.dart';
import 'package:calorai/screens/profile_screen.dart';
import 'package:calorai/services/steps_service.dart';
import 'package:calorai/widgets/HorizontalDatePicker.dart';
import 'package:calorai/widgets/water_intake.dart';
import 'package:calorai/widgets/workout_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calorai/components/CalorieRing.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final health = Health();
  int _currentSteps = 0;
  dynamic metrics;
  bool isLoading = false;
  dynamic activities;
  DateTime currentDate = DateTime.now();
  String selectedDate = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day); // today 00:00
    final end = now;
    selectedDate = DateFormat('yyyy-MM-dd').format(now);
    print("Selected Date " + selectedDate);
    getTodaySteps(start, end);
    getDailyMetricsToday();
    getRecentActivity();
  }

  Future<int> getTodaySteps(DateTime start, DateTime end) async {
    // Steps is a cumulative type → prefer total aggregation when possible.
    final types = [HealthDataType.STEPS];

    // final now = DateTime.now();
    // final start = DateTime(now.year, now.month, now.day); // today 00:00
    // final end = now;

    // Request read permission
    final granted = await health.requestAuthorization(
      types,
      permissions: [HealthDataAccess.READ],
    );
    if (!granted) {
      print("Health permission not granted");
      throw Exception("Health permission not granted");
    }
    // Many apps: easiest API is "getTotalStepsInInterval"
    final steps = await health.getTotalStepsInInterval(start, end);
    setState(() {
      _currentSteps = steps ?? 0;
    });
    return steps ?? 0;
  }

  Future<void> getRecentActivity() async {
    ApiCall apiCall = ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token").toString();
    DateTime now = DateTime.now();

    String currentDate = DateFormat('yyyy-MM-dd').format(now);
    RecentActivityData activityData =
        await apiCall.recentActivity(currentDate, token);
    setState(() {
      activities = activityData.activities;
    });
  }

  Future<void> getRecentActivityByDate(String date) async {
    ApiCall apiCall = ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token").toString();
    print("Get Recent Activity " + date);
    RecentActivityData activityData = await apiCall.recentActivity(date, token);
    setState(() {
      activities = activityData.activities;
    });
  }

  Future<void> getDailyMetricsToday() async {
    setState(() {
      isLoading = true;
    });
    ApiCall apiCall = new ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token").toString();
    DailyMetricsData metricsData = await apiCall.getDailyMetricsToday(token);
    if (metricsData.status == false) {
      print("NO TOKEN");
      MyUtility.logout(context);
    }
    print(metricsData.metrics!.userId);
    setState(() {
      metrics = metricsData.metrics;
      isLoading = false;
    });
  }

  Future<void> getDailyMetricsByDate(String date) async {
    setState(() {
      isLoading = true;
    });
    ApiCall apiCall = ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token").toString();
    DailyMetricsData metricsData =
        await apiCall.getDailyMetricsDate(date, token);
    print(metricsData);
    setState(() {
      metrics = metricsData.metrics;
      currentDate = DateTime.parse(date);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F5F5),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryOrangeLight,
              ),
            )
          : Stack(
              children: [
                // ================= HEADER =================
                _DashboardHeader(
                  currentDate: currentDate,
                  onDateChange: (value) {
                    print("This is ${value}");
                    getDailyMetricsByDate(value);
                    DateTime sd = DateTime.parse(value);
                    setState(() {
                      selectedDate = value;
                    });
                    final start = DateTime(
                      sd.year,
                      sd.month,
                      sd.day,
                    );

                    final now = DateTime.now();

                    final bool isToday = sd.year == now.year &&
                        sd.month == now.month &&
                        sd.day == now.day;

                    final end =
                        isToday ? now : start.add(const Duration(days: 1));
                    getTodaySteps(start, end);
                    getRecentActivityByDate(value);
                  },
                ),

                // ================= BODY =================
                Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40))),
                  margin: const EdgeInsets.only(top: 225),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ======= CALORIES + STEPS CARDS =======
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  type: 'Calories',
                                  bgColor: primaryOrangeDark,
                                  icon: Icons.local_fire_department,
                                  title: "Today Calories",
                                  value: "${metrics.caloriesBurned ?? ""}",
                                  total:
                                      "${metrics.nutrientsConsumed.calories ?? ""}",
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Expanded(
                              //     // child: _StatCard(
                              //     //   bgColor: primaryGreenDark,
                              //     //   icon: Icons.directions_walk,
                              //     //   title: "Daily Steps",
                              //     //   value: "${_currentSteps.toString()}",
                              //     //   total: "${metrics.steps.goal.toString()}",
                              //     // ),
                              //     child: ElevatedButton(
                              //   onPressed: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //           builder: (_) =>
                              //               const ConnectHealthScreen()),
                              //     );
                              //   },
                              //   child: const Text("Connect to Google Health"),
                              // )),
                              const SizedBox(width: 14),
                              Expanded(
                                child: _StatCard(
                                  type: 'Steps',
                                  bgColor: primaryGreenDark,
                                  icon: Icons.directions_walk,
                                  title: "Daily Steps",
                                  value: "${_currentSteps.toString()}",
                                  total: "${metrics.steps.goal.toString()}",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // ElevatedButton(
                          //     onPressed: () async {
                          //       SharedPreferences preferences =
                          //           await SharedPreferences.getInstance();
                          //       String id =
                          //           preferences.getString("id").toString();
                          //       print("ID = $id");
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (_) =>
                          //               MealPlanHomeScreen(userId: id),
                          //         ),
                          //       );
                          //     },
                          //     child: Container(
                          //       child: Text("AI Meal Plan"),
                          //     )),
                          //
                          // ElevatedButton(
                          //     onPressed: () async {
                          //       SharedPreferences preferences =
                          //           await SharedPreferences.getInstance();
                          //       String id =
                          //           preferences.getString("id").toString();
                          //       print("ID = $id");
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (_) =>
                          //               FoodScanHomeScreen(userId: id),
                          //         ),
                          //       );
                          //     },
                          //     child: Container(
                          //       child: Text("Scan Food"),
                          //     )),

                          //Water intake system
                          WaterIntakeWidget(
                            total: metrics.waterIntake.totalMl,
                            goal: metrics.waterIntake.goalMl,
                            currentDate: selectedDate,
                          ),
                          // ============= PIE CHART SECTION ============
                          //_SectionHeader(title: "Pie Chart"),
                          const SizedBox(height: 10),
                          //_PieChartPlaceholder(),

                          //const SizedBox(height: 28),

                          // ============= CHALLENGES SECTION ============
                          _SectionHeader(title: "Recently Uploaded"),
                          activities == null
                              ? const Center(
                                  child: CircularProgressIndicator(
                                  color: primaryOrangeLight,
                                ))
                              : activities.isEmpty
                                  ? const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Center(
                                          child: Column(
                                        children: [
                                          Icon(
                                            Icons.edit_document,
                                            color: primaryOrangeDark,
                                            size: 30,
                                          ),
                                          Text(
                                            "No Activities found",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      )),
                                    )
                                  : Container(
                                      child: ListView.builder(
                                        padding: EdgeInsets.only(top: 10),
                                        itemCount: activities.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final item = activities[index];
                                          return Dismissible(
                                            key: ValueKey(
                                                "${item.type}_${item.id}"),
                                            direction: DismissDirection
                                                .endToStart, // right -> left only

                                            background: Container(
                                              alignment: Alignment.centerRight,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 18),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: const Icon(Icons.delete,
                                                  color: Colors.white,
                                                  size: 28),
                                            ),

                                            confirmDismiss: (direction) async {
                                              return await showDialog<bool>(
                                                    context: context,
                                                    builder: (_) => AlertDialog(
                                                      title: const Text(
                                                          "Delete activity?"),
                                                      content: Text(
                                                          "This will remove '${item.title}' from your logs."),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  false),
                                                          child: const Text(
                                                              "Cancel"),
                                                        ),
                                                        ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context,
                                                                  true),
                                                          child: const Text(
                                                              "Delete",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)),
                                                        ),
                                                      ],
                                                    ),
                                                  ) ??
                                                  false;
                                            },

                                            onDismissed: (_) async {
                                              try {
                                                final prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                final token =
                                                    prefs.getString("token") ??
                                                        "";
                                                final api = ApiCall();

                                                if (item.isFood) {
                                                  await api.deleteFoodLog(
                                                      item.id, token);
                                                } else {
                                                  await api.deleteExerciseLog(
                                                      item.id, token);
                                                }

                                                setState(() {
                                                  activities.removeAt(index);
                                                });

                                                // Optional: refresh totals on dashboard after delete
                                                await getDailyMetricsToday();
                                              } catch (e) {
                                                // If API failed, re-fetch to restore list state
                                                await getRecentActivity();

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content: Text(
                                                          "Delete failed: $e")),
                                                );
                                              }
                                            },

                                            child: _ActivityCard(item: item),
                                          );
                                        },
                                      ),
                                    ),
                        ],
                      ),
                    ),
                  ),
                ),
                // WorkoutHistoryScreen(),
              ],
            ),

      // ================= BOTTOM NAV =================
      //bottomNavigationBar: _BottomNavBar(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: Colors.orange,
      //   foregroundColor: Colors.white,
      //   shape: const CircleBorder(),
      //   child: Icon(
      //     Icons.camera,
      //     size: 40,
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: InkWell(
      //   onTap: () {
      //     MyUtility.changePage(context, AiDetectionResultScreen());
      //   },
      //   child: Container(
      //     height: 70,
      //     width: 70,
      //     decoration: BoxDecoration(
      //       shape: BoxShape.circle,
      //       color: primaryOrangeDark,
      //       border: Border.all(color: Colors.transparent, width: 5),
      //       boxShadow: [
      //         BoxShadow(
      //           color: Colors.black.withOpacity(0.2),
      //           blurRadius: 10,
      //         ),
      //       ],
      //     ),
      //     child: const Icon(Icons.camera, size: 42, color: Colors.white),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

//
// ─────────────────────────────────────────────────────────
//   HEADER (CURVED ORANGE CARD)
// ─────────────────────────────────────────────────────────
//

class _DashboardHeader extends StatelessWidget {
  dynamic onDateChange;
  dynamic currentDate;
  _DashboardHeader({required this.onDateChange, required this.currentDate});

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      //clipper: _HeaderClipper(),
      child: Container(
        height: 300,
        width: double.infinity,
        padding: const EdgeInsets.only(top: 50),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFA53B),
              Color(0xFFFF8B00),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP ROW (TIME + NOTIFICATION ICON)
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: const [
            //     Text(
            //       "9:41",
            //       style: TextStyle(color: Colors.white, fontSize: 18),
            //     ),
            //     Icon(Icons.signal_cellular_4_bar, color: Colors.white),
            //   ],
            // ),
            const SizedBox(height: 10),
            // GREETING + NAME ROW
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  // Container(
                  //   height: 40,
                  //   width: 40,
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(10),
                  //   ),
                  //   child:
                  //       const Icon(Icons.camera_alt, color: primaryOrangeDark),
                  // ),
                  InkWell(
                    onTap: () {
                      MyUtility.changePage(context, ProfileScreen());
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage("assets/images/logo.jpg"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        // TextSpan(
                        //   text: "Hi, Good Morning\n",
                        //   style: TextStyle(color: Colors.white, fontSize: 13),
                        // ),
                        TextSpan(
                          text:
                              "${FirebaseAuth.instance.currentUser!.displayName.toString()}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ],
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      MyUtility.changePage(context, ProfileScreen());
                    },
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(
                        FirebaseAuth.instance.currentUser!.photoURL.toString(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

//           const SizedBox(height: 15),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: const Text(
                "Stay on Track for Nutrition Needs",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Horizontaldatepicker(
              currentDate: currentDate,
              onDateSelected: (date) {
                String currentDate = DateFormat('yyyy-MM-dd').format(date);
                print("Selected date: $currentDate");
                onDateChange(currentDate);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(_) => false;
}

//
// ─────────────────────────────────────────────────────────
//   STAT CARD
// ─────────────────────────────────────────────────────────
//

class _StatCard extends StatelessWidget {
  final Color bgColor;
  final IconData icon;
  final String title;
  final String value;
  final String total;
  final String type;

  const _StatCard({
    required this.bgColor,
    required this.icon,
    required this.title,
    required this.value,
    required this.total,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      //height: 140,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            width: 60,
            height: 60,
            child: Center(
              child: Icon(
                icon,
                size: 40,
                color:
                    type == "Calories" ? primaryOrangeDark : primaryGreenDark,
              ),
            ),
          ),
          // SizedBox(
          //   width: 100,
          //   height: 100,
          //   child: CustomPaint(
          //     painter: CalorieRingPainter(progress: 0.75),
          //     child: Center(
          //       child: Icon(
          //         icon,
          //         size: 30,
          //         color: Colors.black,
          //       ),
          //     ),
          //   ),
          // ),
          //Icon(icon, color: Colors.white, size: 42),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            "$value of $total",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────────────────
//   SECTION HEADER + UNDERLINE
// ─────────────────────────────────────────────────────────
//

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              height: 3,
              width: 60,
              color: primaryOrangeDark,
            ),
          ],
        ),
        // Row(
        //   children: const [
        //     Text(
        //       "View More Details",
        //       style: TextStyle(fontSize: 14, color: Colors.black54),
        //     ),
        //     SizedBox(width: 4),
        //     Icon(Icons.chevron_right, size: 18),
        //   ],
        // ),
      ],
    );
  }
}

//
// ─────────────────────────────────────────────────────────
//   PIE CHART PLACEHOLDER
// ─────────────────────────────────────────────────────────
//

class _PieChartPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: 2,
            color: Colors.black12,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              "assets/images/chart.png",
              height: 140,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              chip("Proteins", Colors.blue),
              chip("Carbs", Colors.red),
              chip("Fats", Colors.purple),
              chip("Others", Colors.orange),
            ],
          )
        ],
      ),
    );
  }

  Widget chip(dynamic title, dynamic color) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.rectangle,
              )),
          SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────────────────
//   CHALLENGE CARD
// ─────────────────────────────────────────────────────────
//

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isCompleted;

  const _ChallengeCard({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (isCompleted)
            const Icon(Icons.check_circle, color: Colors.green, size: 26)
          else
            Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 26),
                SizedBox(width: 6),
                Icon(Icons.radio_button_unchecked,
                    color: Colors.grey, size: 26),
                SizedBox(width: 6),
                Icon(Icons.radio_button_unchecked,
                    color: Colors.grey, size: 26),
              ],
            ),
        ],
      ),
    );
  }
}

//
// ─────────────────────────────────────────────────────────
//   BOTTOM NAVIGATION
// ─────────────────────────────────────────────────────────
//

class _BottomNavBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
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
                  icon: Icons.home, label: "Home", active: true, onTap: () {}),
              _NavItem(
                  icon: Icons.restaurant_menu,
                  label: "Meal Plans",
                  onTap: () {
                    MyUtility.changePage(context, AddCustomMeal());
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //         builder: (context) => AddCustomMeal()));
                  }),
              const SizedBox(width: 50), // space for center button
              _NavItem(
                icon: Icons.flag,
                label: "Challenges",
                onTap: () async {
                  await MyUtility.changePage(context, LogExercise());
                  print("Return from Challenges");
                  //getDailyMetricsToday();
                },
              ),
              _NavItem(
                icon: Icons.fitness_center,
                label: "Fitness",
                onTap: () {
                  MyUtility.changePage(context, FoodLogingsScreen());
                },
              ),
            ],
          ),
        ),

        // Floating Scan Button
        // Positioned(
        //   top: -30,
        //   child: GestureDetector(
        //     onTap: () {},
        //     child: Container(
        //       height: 70,
        //       width: 70,
        //       decoration: BoxDecoration(
        //         color: const Color(0xFFFFA53B),
        //         shape: BoxShape.circle,
        //         border: Border.all(color: Colors.white, width: 5),
        //       ),
        //       child: const Icon(Icons.camera, color: Colors.white, size: 32),
        //     ),
        //   ),
        // ),
      ],
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

class _ActivityCard extends StatelessWidget {
  final Activities item;

  const _ActivityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final icon = item.isFood ? Icons.restaurant : Icons.fitness_center;
    final iconBg = item.isFood
        ? Colors.orange.withOpacity(0.12)
        : Colors.blue.withOpacity(0.12);
    final iconColor = item.isFood ? Colors.orange : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.05),
          )
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      item.time,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Subtitle / Details
                Text(
                  item.isFood ? (item.subtitle ?? '') : _exerciseSubtitle(item),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),

                const SizedBox(height: 8),

                // Bottom row stats
                Row(
                  children: [
                    _pill("${item.calories} kcal"),
                    const SizedBox(width: 8),
                    if (item.isFood && item.macros != null) ...[
                      _pill("P ${_fmt(item.macros!.proteinG)}g"),
                      const SizedBox(width: 6),
                      _pill("C ${_fmt(item.macros!.carbsG)}g"),
                      const SizedBox(width: 6),
                      _pill("F ${_fmt(item.macros!.fatsG)}g"),
                    ],
                    if (item.isExercise && item.durationMin != null) ...[
                      _pill("${item.durationMin} min"),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  static String _exerciseSubtitle(Activities item) {
    final parts = <String>[];
    if (item.exerciseType != null && item.exerciseType!.isNotEmpty) {
      parts.add(item.exerciseType!);
    }
    if (item.intensity != null && item.intensity!.isNotEmpty) {
      parts.add("• ${item.intensity}");
    }
    return parts.join(' ');
  }

  static String _fmt(num v) {
    // show 0.6 as 0.6, 6.0 as 6
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
