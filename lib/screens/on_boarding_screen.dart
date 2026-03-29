import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/screens/login_screen.dart';
import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageCtrl = PageController();
  int _index = 0;
  // static const primary = Color(0xFFFF9800);
  // static const primary2 = Color(0xFFFFB74D);
  static const bg = Color(0xFFF9FAFB);
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      icon: Icons.camera_alt_rounded,
      title: "Scan Your Food",
      subtitle:
          "Take a photo of your meal and let CalorAI identify it instantly.",
    ),
    _OnboardPage(
      icon: Icons.bolt_rounded,
      title: "Calories & Macros",
      subtitle: "Get estimated calories, protein, carbs, and fats in seconds.",
    ),
    _OnboardPage(
      icon: Icons.chat_bubble_rounded,
      title: "AI Nutrition Coach",
      subtitle:
          "Ask questions, get suggestions, and improve your daily habits.",
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _goToLogin() {
    MyUtility.replacePage(context, LoginScreen());
  }

  void _next() {
    if (_index < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _goToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top gradient header with Skip
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryOrangeLight, primaryGreenDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _goToLogin,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                      ),
                      child: const Text(
                        "Skip",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "CalorAI",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Smart nutrition tracking",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFDF2E9),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Stack(
                children: [
                  // PageView
                  PageView.builder(
                    controller: _pageCtrl,
                    itemCount: _pages.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (context, i) {
                      final p = _pages[i];
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),

                            // Illustration card (icon-based)
                            Container(
                              height: 220,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 24,
                                    offset: Offset(0, 10),
                                    color: Color(0x0F000000),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  height: 92,
                                  width: 92,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF3E0),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Icon(
                                    p.icon,
                                    size: 44,
                                    color: primaryOrangeLight,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 22),

                            Text(
                              p.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              p.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Bottom card controls
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(22),
                          topRight: Radius.circular(22),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 24,
                            offset: Offset(0, -10),
                            color: Color(0x0A000000),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _DotsIndicator(
                            count: _pages.length,
                            index: _index,
                            activeColor: primaryOrangeLight,
                            inactiveColor: const Color(0xFFE5E7EB),
                          ),
                          const SizedBox(height: 14),

                          // Next / Get Started button
                          _GradientButton(
                            text: isLast ? "Get Started" : "Next",
                            onPressed: _next,
                            gradient: const LinearGradient(
                              colors: [primaryOrangeLight, primaryOrangeDark],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Optional: back link (only when not first)
                          // if (_index > 0)
                          //   TextButton(
                          //     onPressed: () => _pageCtrl.previousPage(
                          //       duration: const Duration(milliseconds: 240),
                          //       curve: Curves.easeOut,
                          //     ),
                          //     style: TextButton.styleFrom(
                          //       foregroundColor: textSecondary,
                          //     ),
                          //     child: const Text(
                          //       "Back",
                          //       style: TextStyle(fontWeight: FontWeight.w700),
                          //     ),
                          //   ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.index,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int index;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 22 : 8,
          decoration: BoxDecoration(
            color: active ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.text,
    required this.onPressed,
    required this.gradient,
  });

  final String text;
  final VoidCallback onPressed;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
