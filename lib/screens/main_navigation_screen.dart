import 'dart:convert';

import 'package:calorai/api/api_resources.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/screens/dashboard_screen.dart';
import 'package:calorai/screens/exercise/log_exercise.dart';
import 'package:calorai/screens/food-scan/screens/food_scan_home_screen.dart';
import 'package:calorai/screens/food/log_food.dart';
import 'package:calorai/screens/streak_screen.dart';
import 'package:calorai/screens/subscription_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _paywallPushed = false; // prevents stacking paywall on itself
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey<DashboardScreenState>();
  late final List<Widget> screens;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _initScreens() {
    screens = [
      DashboardScreen(key: _dashboardKey),
      LogFood(),
      LogExercise(),
      StreakScreen(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _initScreens();
    WidgetsBinding.instance.addObserver(this);
    // Check on first load — reminder is suppressed on initial load
    _checkSubscription(isResume: false);
    // RevenueCat pushes updates whenever subscription status changes —
    // this fires even while the app is in the foreground (e.g. sandbox expiry)
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    super.dispose();
  }

  /// Called by RevenueCat whenever entitlements change (renewal, expiry, etc.)
  void _onCustomerInfoUpdated(CustomerInfo info) {
    // Treat subscription changes same as initial load — no reminder on this path
    _evaluateAccess(info, isResume: false);
  }

  /// Called whenever the app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // isResume: true — this is the path that shows the daily trial reminder
      _checkSubscription(isResume: true);
    }
  }

  Future<void> _checkSubscription({bool isResume = false}) async {
    try {
      final info = await Purchases.getCustomerInfo();
      _evaluateAccess(info, isResume: isResume);
    } catch (_) {
      // RevenueCat error — don't block the user
    }
  }

  /// Shared gate: called both from the listener and from manual checks.
  ///
  /// [isResume] = true  → app came back from background (shows trial reminder)
  /// [isResume] = false → initial app load or RevenueCat event (reminder suppressed)
  ///
  /// Outcomes:
  ///  1. Paid subscriber           → do nothing (full access)
  ///  2. Trial expired             → blocking paywall, no skip (always)
  ///  3. No trial started yet      → first-time paywall with skip (always, even on init)
  ///     (covers old users who registered before the trial system was added)
  ///  4. Trial active + isResume   → reminder paywall with skip
  ///  4. Trial active + !isResume  → do nothing (let user in silently)
  Future<void> _evaluateAccess(CustomerInfo info, {bool isResume = false}) async {
    final isPremium = info.entitlements.active.isNotEmpty;
    if (isPremium) return; // paid subscription — all good

    final trial = await _fetchTrialStatus();
    if (!mounted) return;

    final trialStartDate = trial['trialStartDate'];
    final trialExpired = trial['trialExpired'] == true;

    if (trialExpired) {
      // Hard block — must subscribe to continue (always, regardless of isResume)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => const SubscriptionPage(showSkip: false)),
        (_) => false,
      );
      return;
    }

    if (trialStartDate == null) {
      // No trial started yet — show first-time paywall on every load
      // (old users and new users who haven't gone through onboarding paywall)
      if (_paywallPushed) return;
      _paywallPushed = true;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SubscriptionPage(
            showSkip: true,
            isReminder: false,
          ),
        ),
      ).then((_) {
        if (mounted) setState(() => _paywallPushed = false);
      });
      return;
    }

    // Trial is active — only remind when the user returns from background.
    // Suppressed on initial load so the dashboard doesn't immediately re-show
    // a paywall right after the user just tapped Skip to start their trial.
    if (!isResume) return;

    if (_paywallPushed) return;
    _paywallPushed = true;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SubscriptionPage(
          showSkip: true,
          isReminder: true,
        ),
      ),
    ).then((_) {
      if (mounted) setState(() => _paywallPushed = false);
    });
  }

  /// Fetches trial status from server. Falls back to local cache on network
  /// error so the user is never wrongly blocked when offline.
  Future<Map<String, dynamic>> _fetchTrialStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) return {'trialStartDate': null, 'trialExpired': false};

      final response = await http.get(
        Uri.parse(APIResource.TRIAL_STATUS),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Keep local cache in sync
        if (data['trialStartDate'] != null) {
          final prefs2 = await SharedPreferences.getInstance();
          await prefs2.setString(
              'trialStartDate', data['trialStartDate'].toString());
        }

        return data;
      }
    } catch (_) {
      // Network error — build a response from local cache
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('trialStartDate') ?? '';
      if (cached.isEmpty) return {'trialStartDate': null, 'trialExpired': false};
      final trialStart = DateTime.tryParse(cached);
      if (trialStart == null) return {'trialStartDate': null, 'trialExpired': false};
      final expired =
          DateTime.now().isAfter(trialStart.add(const Duration(days: 7)));
      return {'trialStartDate': cached, 'trialExpired': expired};
    }

    return {'trialStartDate': null, 'trialExpired': false};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        children: [
          Container(
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            height: 80 + MediaQuery.of(context).padding.bottom,
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
              children: [
                // Left half — equal width ensures FAB gap lands at center
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: Icons.home,
                        label: "Calor AI",
                        active: _selectedIndex == 0,
                        onTap: () {
                          if (_selectedIndex != 0) {
                            _dashboardKey.currentState?.refreshData();
                          }
                          setState(() => _selectedIndex = 0);
                        },
                      ),
                      _NavItem(
                        icon: Icons.restaurant_menu,
                        label: "Food",
                        active: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 70), // gap for FAB
                // Right half — equal width mirrors the left
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavItem(
                        icon: Icons.directions_run,
                        label: "Workout",
                        active: _selectedIndex == 2,
                        onTap: () => setState(() => _selectedIndex = 2),
                      ),
                      _NavItem(
                        icon: Icons.flag,
                        label: "Goals",
                        active: _selectedIndex == 3,
                        onTap: () => setState(() => _selectedIndex = 3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () async {
          SharedPreferences preferences = await SharedPreferences.getInstance();
          String id = preferences.getString("id").toString();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodScanHomeScreen(userId: id),
            ),
          );
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
  final VoidCallback onTap;

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
            color: active ? const Color(0xFFFFA53B) : Colors.black54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: active ? const Color(0xFFFFA53B) : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
