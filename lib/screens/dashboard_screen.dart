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
import 'package:calorai/screens/meal_plan/screens/ai_meal_plan_screen.dart';
import 'package:calorai/screens/meal_plan/screens/meal_plan_home_screen.dart';
import 'package:calorai/screens/activity_history_screen.dart';
import 'package:calorai/screens/profile_screen.dart';
import 'package:calorai/screens/subscription_page.dart';
import 'package:calorai/screens/weekly_progress_screen.dart';
import 'package:calorai/widgets/weekly_calorie_chart.dart';
import 'package:calorai/services/steps_service.dart';
import 'package:calorai/widgets/HorizontalDatePicker.dart';
import 'package:calorai/widgets/meal_plan_card.dart';
import 'package:calorai/widgets/water_intake.dart';
import 'package:calorai/widgets/workout_history_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calorai/components/CalorieRing.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final health = Health();
  int _currentSteps = 0;
  dynamic metrics;
  bool isLoading = false;
  dynamic activities;
  DateTime currentDate = DateTime.now();
  String selectedDate = "";
  bool _isPremium = false;
  int _targetCalories = 2000;
  List<WeeklyCaloriePoint> _weeklyPoints = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day); // today 00:00
    final end = now;
    selectedDate = DateFormat('yyyy-MM-dd').format(now);
    // print("Selected Date " + selectedDate);
    getTodaySteps(start, end).catchError((_) {});
    getDailyMetricsToday();
    // Small delay so the backend write is fully committed before we fetch.
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) getRecentActivity();
    });
    _checkPremium();
    _loadUserTargets();
    _loadWeeklyMetrics();
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
      // print("Health permission not granted");
      if (mounted)
        setState(() {
          _currentSteps = 0;
        });
      return 0;
    }
    // Many apps: easiest API is "getTotalStepsInInterval"
    final steps = await health.getTotalStepsInInterval(start, end);
    if (mounted)
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
    if (!mounted) return;
    setState(() {
      activities = activityData.activities;
    });
  }

  Future<void> getRecentActivityByDate(String date) async {
    ApiCall apiCall = ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token").toString();
    // print("Get Recent Activity " + date);
    RecentActivityData activityData = await apiCall.recentActivity(date, token);
    if (!mounted) return;
    setState(() {
      activities = activityData.activities;
    });
  }

  Future<void> _checkPremium() async {
    try {
      final info = await Purchases.getCustomerInfo();
      if (mounted) {
        setState(() => _isPremium = info.entitlements.active.isNotEmpty);
      }
    } catch (_) {}
  }

  Future<void> _loadUserTargets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? '';
      if (token.isEmpty) return;
      final userData = await ApiCall().getMe(token);
      final target = userData.user?.dailyTargets?.targetCalories;
      if (target != null && mounted) {
        setState(() => _targetCalories = (target as num).round());
      }
    } catch (_) {}
  }

  Future<void> _loadWeeklyMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? '';
      if (token.isEmpty) return;
      final now = DateTime.now();
      final end = now;
      final start = now.subtract(const Duration(days: 6));
      final fmt = (DateTime d) =>
          '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final rows =
          await ApiCall().getWeeklyMetrics(fmt(start), fmt(end), token);
      final points = rows.map((r) {
        final dateStr = (r['date'] as String? ?? '');
        final date = dateStr.isNotEmpty
            ? DateTime.tryParse(dateStr) ?? DateTime.now()
            : DateTime.now();

        final cal =
            ((r['nutrientsConsumed'] as Map?)?.containsKey('calories') == true
                ? (r['nutrientsConsumed']['calories'] as num).toDouble()
                : 0.0);
        return WeeklyCaloriePoint(date: date, calories: cal);
      }).toList();
      if (mounted) setState(() => _weeklyPoints = points);
    } catch (_) {}
  }

  /// Called externally (e.g. from MainNavigationScreen) to force a full reload.
  void refreshData() {
    getDailyMetricsToday();
    getRecentActivity();
  }

  Future<void> getDailyMetricsToday() async {
    if (!mounted) return;
    // Only show full-screen spinner on first load; refresh silently afterwards.
    if (metrics == null) {
      setState(() {
        isLoading = true;
      });
    }
    ApiCall apiCall = new ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token").toString();
    DailyMetricsData metricsData = await apiCall.getDailyMetricsToday(token);
    if (!mounted) return;
    if (metricsData.status == false) {
      // print("NO TOKEN");
      MyUtility.logout(context);

      return;
    }
    // print(metricsData.metrics!.userId);
    if (!mounted) return;
    setState(() {
      metrics = metricsData.metrics;
      isLoading = false;
    });
  }

  Future<void> getDailyMetricsByDate(String date) async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    ApiCall apiCall = ApiCall();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String token = preferences.getString("token").toString();
    DailyMetricsData metricsData =
        await apiCall.getDailyMetricsDate(date, token);
    // print(metricsData);
    if (!mounted) return;
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
      body: (isLoading && metrics == null)
          ? Center(
              child: CircularProgressIndicator(color: primaryOrangeLight),
            )
          : Stack(
              children: [
                // Slim bar on refreshes when metrics already exist
                if (isLoading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      color: primaryOrangeLight,
                      backgroundColor: primaryOrangeLight.withOpacity(0.2),
                    ),
                  ),
                // ================= HEADER =================
                _DashboardHeader(
                  currentDate: currentDate,
                  onDateChange: (value) {
                    // print("This is ${value}");
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
                    child: RefreshIndicator(
                      color: primaryOrangeDark,
                      onRefresh: () async {
                        await getRecentActivity();
                        await getDailyMetricsToday();
                      },
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          left: 15,
                          right: 15,
                          // Clears the nav bar + floating camera button
                          // so content doesn't scroll behind them.
                          bottom: MediaQuery.of(context).padding.bottom + 120,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ======= CALORIES + STEPS CARDS =======
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _StatCard(
                                      type: 'Calories',
                                      bgColor: primaryOrangeDark,
                                      icon: Icons.local_fire_department,
                                      title: "Today Calories",
                                      value:
                                          "${(metrics.nutrientsConsumed?.calories ?? 0).round()}",
                                      total: "$_targetCalories",
                                      burned:
                                          "${(metrics.caloriesBurned ?? 0).round()}",
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: _StatCard(
                                      type: 'Steps',
                                      bgColor: primaryGreenDark,
                                      icon: Icons.directions_walk,
                                      title: "Daily Steps",
                                      value: "${_currentSteps.toString()}",
                                      total: "${metrics.steps.goal.toString()}",
                                      burned: "${(_currentSteps ~/ 1000) * 50}",
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Get Premium banner (hidden for premium users) ──
                            if (!_isPremium) ...[
                              const SizedBox(height: 14),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SubscriptionPage(showSkip: false),
                                  ),
                                ).then((_) => _checkPremium()),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFFF9800),
                                        Color(0xFFFFB74D),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.star_rounded,
                                          color: Colors.white, size: 22),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Upgrade to CalorAI Premium',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w800,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              'Unlock AI meal plans, food scan & more',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.chevron_right,
                                          color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            MealPlanCard(
                              onTap: () async {
                                SharedPreferences preferences =
                                    await SharedPreferences.getInstance();
                                String id =
                                    preferences.getString("id").toString();
                                // print("ID = $id");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MealPlanHomeScreen(userId: id),
                                  ),
                                );
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (_) => AiMealPlanScreen(
                                //       onGenerateTap: () {},
                                //       onHistoryTap: () {},
                                //       onEditProfileTap: () {},
                                //     ),
                                //   ),
                                // );
                              },
                            ),

                            //const SizedBox(height: 25),

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

                            // ============= WEEKLY CALORIE CHART ============
                            const SizedBox(height: 14),
                            if (_weeklyPoints.isNotEmpty)
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const WeeklyProgressScreen()),
                                ),
                                child:
                                    WeeklyCalorieChart(points: _weeklyPoints),
                              ),

                            // ============= PIE CHART SECTION ============
                            //_SectionHeader(title: "Pie Chart"),
                            const SizedBox(height: 10),
                            //_PieChartPlaceholder(),

                            //const SizedBox(height: 28);

                            // ============= RECENT ACTIVITY SECTION ============
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _SectionHeader(title: "Recently Uploaded"),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const ActivityHistoryScreen()),
                                  ),
                                  child: const Text(
                                    "See All →",
                                    style: TextStyle(
                                        color: primaryOrangeDark, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
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
                                                alignment:
                                                    Alignment.centerRight,
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

                                              confirmDismiss:
                                                  (direction) async {
                                                return await showDialog<bool>(
                                                      context: context,
                                                      builder: (_) =>
                                                          AlertDialog(
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
                                                  final token = prefs
                                                          .getString("token") ??
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

                            // ── Nutritional disclaimer (Apple 1.4.1) ──────
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Text(
                                'Calorie and nutrition data are estimates based on the USDA FoodData Central database and standard dietary reference values. These figures are for informational purposes only and do not constitute medical or dietary advice. Consult a qualified healthcare professional for personalised nutrition guidance.',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                    height: 1.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ), // RefreshIndicator
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
                      backgroundImage: AssetImage("assets/images/logo.png"),
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
                              "${FirebaseAuth.instance.currentUser?.displayName ?? 'Welcome'}",
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
                      backgroundImage:
                          FirebaseAuth.instance.currentUser?.photoURL != null
                              ? NetworkImage(
                                  FirebaseAuth.instance.currentUser!.photoURL!)
                              : const AssetImage('assets/images/logo.png')
                                  as ImageProvider,
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
                // print("Selected date: $currentDate");
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
  final String? burned;

  const _StatCard({
    required this.bgColor,
    required this.icon,
    required this.title,
    required this.value,
    required this.total,
    required this.type,
    this.burned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            width: 50,
            height: 50,
            child: Center(
              child: Icon(
                icon,
                size: 40,
                color:
                    type == "Calories" ? primaryOrangeDark : primaryGreenDark,
              ),
            ),
          ),
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
          if (type == 'Steps') ...[
            const SizedBox(height: 4),
            const Text(
              'via Apple Health',
              style: TextStyle(color: Colors.white70, fontSize: 9),
            ),
          ],
          if (burned != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_fire_department,
                      color: Colors.white, size: 13),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '$burned kcal burned',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

/*
// ── ORIGINAL _ActivityCard (tall ~110px, kept for reference) ─────────────────
class _ActivityCardOriginal extends StatelessWidget {
  final Activities item;
  const _ActivityCardOriginal({required this.item});

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
        boxShadow: [BoxShadow(blurRadius: 10, offset: const Offset(0, 4), color: Colors.black.withOpacity(0.05))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
              Text(item.time, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ]),
            const SizedBox(height: 4),
            Text(item.isFood ? (item.subtitle ?? '') : _exerciseSubtitle(item), style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
            const SizedBox(height: 8),
            Row(children: [
              _pill("${item.calories} kcal"),
              if (item.isFood && item.macros != null) ...[const SizedBox(width: 6), _pill("P ${_fmt(item.macros!.proteinG)}g"), const SizedBox(width: 6), _pill("C ${_fmt(item.macros!.carbsG)}g"), const SizedBox(width: 6), _pill("F ${_fmt(item.macros!.fatsG)}g")],
              if (item.isExercise && item.durationMin != null) ...[const SizedBox(width: 6), _pill("${item.durationMin} min")],
            ]),
          ])),
        ],
      ),
    );
  }
  static Widget _pill(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(999), border: Border.all(color: Colors.grey.shade200)), child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)));
  static String _exerciseSubtitle(Activities item) { final parts = <String>[]; if (item.exerciseType != null && item.exerciseType!.isNotEmpty) parts.add(item.exerciseType!); if (item.intensity != null && item.intensity!.isNotEmpty) parts.add("• ${item.intensity}"); return parts.join(' '); }
  static String _fmt(num v) { if (v % 1 == 0) return v.toInt().toString(); return v.toStringAsFixed(1); }
}
*/

// ── COMPACT _ActivityCard (~56px tall — shows 4-5 cards without scrolling) ───
class _ActivityCard extends StatelessWidget {
  final Activities item;
  const _ActivityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isFood = item.isFood;
    final accentColor =
        isFood ? const Color(0xFFFF8B00) : const Color(0xFF2196F3);
    final iconColor =
        isFood ? const Color(0xFFFF8B00) : const Color(0xFF2196F3);
    final iconBg = isFood
        ? const Color(0xFFFF8B00).withOpacity(0.10)
        : const Color(0xFF2196F3).withOpacity(0.10);
    final icon =
        isFood ? Icons.restaurant_rounded : Icons.fitness_center_rounded;

    // macro text for food: "P 6g  C 1g  F 5g"
    String detailLine;
    if (isFood && item.macros != null) {
      detailLine =
          'P ${_fmt(item.macros!.proteinG)}g  C ${_fmt(item.macros!.carbsG)}g  F ${_fmt(item.macros!.fatsG)}g';
    } else if (!isFood) {
      final parts = <String>[];
      if (item.exerciseType != null && (item.exerciseType as String).isNotEmpty)
        parts.add(item.exerciseType as String);
      if (item.durationMin != null) parts.add('${item.durationMin} min');
      if (item.intensity != null && (item.intensity as String).isNotEmpty)
        parts.add(item.intensity as String);
      detailLine = parts.join(' · ');
    } else {
      detailLine = item.subtitle ?? '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accentColor, width: 3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Circle icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(width: 10),

            // Title + detail
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A)),
                  ),
                  if (detailLine.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      detailLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Kcal badge + time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.calories} kcal',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentColor),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.time ?? '',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(num v) {
    if (v % 1 == 0) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
