import 'dart:async';

import 'package:calorai/constants/utility.dart';
import 'package:calorai/screens/authenticate/auth_choice_screen.dart';
import 'package:calorai/screens/main_navigation_screen.dart';
import 'package:calorai/screens/subscription_page.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 3)).then((value) => goToHome());
  }

  void goToHome() async {
    final preferences = await SharedPreferences.getInstance();
    final bool isRegisterComplete =
        preferences.getBool("isRegisterComplete") ?? false;

    if (!isRegisterComplete) {
      MyUtility.replacePage(context, AuthChoiceScreen());
      return;
    }
    // Returning user — check subscription status
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isPremium = customerInfo.entitlements.active.isNotEmpty;

      if (isPremium) {
        MyUtility.replacePage(context, MainNavigationScreen());
        return;
      }

      // Not premium — check trial
      final int? trialStart = preferences.getInt('trialStartDate');
      if (trialStart != null) {
        final trialStartDate = DateTime.fromMillisecondsSinceEpoch(trialStart);
        final trialExpired =
            DateTime.now().isAfter(trialStartDate.add(const Duration(days: 7)));

        if (!trialExpired) {
          MyUtility.replacePage(context, MainNavigationScreen());
          return;
        }
      }

      // Trial expired or never started — show blocking paywall
      MyUtility.replacePage(context, SubscriptionPage(showSkip: false));
    } catch (_) {
      // RevenueCat error — let them in, don't block
      MyUtility.replacePage(context, MainNavigationScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF9800);
    const primary2 = Color(0xFFFFB74D);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primary, primary2],
          ),
        ),
        child: SafeArea(
            child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo container
                Container(
                  height: 92,
                  width: 92,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 28,
                        offset: Offset(0, 12),
                        color: Color(0x26000000),
                      )
                    ],
                  ),
                  // child: const Icon(
                  //   Icons.local_dining,
                  //   size: 44,
                  //   color: primary,
                  // ),
//                  Replace with your logo:
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset("assets/images/logo.png"),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  "CalorAI",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),

                const SizedBox(height: 6),
                const Text(
                  "Smart nutrition tracking",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFFDF2E9),
                  ),
                ),

                const SizedBox(height: 26),

                const SizedBox(height: 90),
              ],
            ),
          ),
        )),
      ),
    );
  }
}
