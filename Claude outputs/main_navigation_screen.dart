import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/screens/dashboard_screen.dart';
import 'package:calorai/screens/exercise/log_exercise.dart';
import 'package:calorai/screens/food-scan/screens/food_scan_home_screen.dart';
import 'package:calorai/screens/food/log_food.dart';
import 'package:calorai/screens/streak_screen.dart';
import 'package:calorai/screens/subscription_page.dart';
import 'package:flutter/material.dart';
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
  dynamic screens = [
    DashboardScreen(),
    LogFood(),
    LogExercise(),
    StreakScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Check on first load
    _checkSubscription();
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
    _evaluateAccess(info);
  }

  /// Called whenever the app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkSubscription();
    }
  }

  Future<void> _checkSubscription() async {
    try {
      final info = await Purchases.getCustomerInfo();
      _evaluateAccess(info);
    } catch (_) {
      // RevenueCat error — don't block the user
    }
  }

  /// Shared gate: called both from the listener and from manual checks.
  Future<void> _evaluateAccess(CustomerInfo info) async {
    final isPremium = info.entitlements.active.isNotEmpty;
    if (isPremium) return; // active subscription — all good

    // Not premium — check manual trial timer (for users who used Skip)
    final prefs = await SharedPreferences.getInstance();
    final int? trialStart = prefs.getInt('trialStartDate');

    if (trialStart == null) {
      // Brand new user who has never seen the paywall — show it with Skip
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const SubscriptionPage(showSkip: true)),
          (_) => false,
        );
      }
      return;
    }

    final trialExpired = DateTime.now().isAfter(
      DateTime.fromMillisecondsSinceEpoch(trialStart)
          .add(const Duration(days: 7)),
    );
    if (!trialExpired) return; // still in trial

    // Trial expired — show blocking paywall
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (_) => const SubscriptionPage(showSkip: false)),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        children: [
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
                  active: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _NavItem(
                  icon: Icons.restaurant_menu,
                  label: "Food",
                  active: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                const SizedBox(width: 50), // space for FAB
                _NavItem(
                  icon: Icons.directions_run,
                  label: "Exercises",
                  active: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                _NavItem(
                  icon: Icons.flag,
                  label: "Challenges",
                  active: _selectedIndex == 3,
                  onTap: () => setState(() => _selectedIndex = 3),
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
