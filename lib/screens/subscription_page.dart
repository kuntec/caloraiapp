import 'dart:convert';

import 'package:calorai/api/api_resources.dart';
import 'package:calorai/screens/main_navigation_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPage extends StatefulWidget {
  /// Show a skip button (first-time users). Set false for blocking paywall.
  final bool showSkip;

  /// True when the user is already in a trial and this is a reminder popup.
  /// Skip just dismisses the page — no trial-start API call or dialog.
  final bool isReminder;

  const SubscriptionPage({
    super.key,
    this.showSkip = false,
    this.isReminder = false,
  });

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  static const _primary = Color(0xFFFF9800);

  Offerings? _offerings;
  CustomerInfo? _customerInfo;
  bool _loading = true;
  bool _purchasing = false;
  bool _restoring = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        Purchases.getOfferings(),
        Purchases.getCustomerInfo(),
      ]);
      if (!mounted) return;
      setState(() {
        _offerings = results[0] as Offerings;
        _customerInfo = results[1] as CustomerInfo;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isPremium {
    return _customerInfo?.entitlements.active.isNotEmpty ?? false;
  }

  Future<void> _purchase(Package package) async {
    setState(() => _purchasing = true);
    try {
      final result = await Purchases.purchasePackage(package);
      if (!mounted) return;
      setState(() => _customerInfo = result.customerInfo);
      if (mounted) _goToDashboard();
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return;
      if (!mounted) return;
      // Sandbox sometimes throws an error even when payment succeeded —
      // re-fetch customer info to confirm before showing an error.
      await _verifyAndNavigate(fallbackError: e.name);
    } catch (e) {
      if (!mounted) return;
      await _verifyAndNavigate(fallbackError: e.toString());
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  /// After a purchase error, force-sync with the App Store via restorePurchases().
  /// This reliably picks up a just-completed purchase that RevenueCat hasn't
  /// processed yet (common in sandbox / TestFlight).
  Future<void> _verifyAndNavigate({required String fallbackError}) async {
    try {
      // Small delay — give RevenueCat a moment to process the receipt.
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      final info = await Purchases.restorePurchases();
      if (!mounted) return;
      if (info.entitlements.active.isNotEmpty) {
        setState(() => _customerInfo = info);
        _goToDashboard();
      } else {
        _showSnack('Payment unsuccessful. Please try again or use a different payment method.');
      }
    } catch (_) {
      if (mounted) _showSnack('Payment unsuccessful. Please try again or use a different payment method.');
    }
  }

  Future<void> _restore() async {
    setState(() => _restoring = true);
    try {
      final info = await Purchases.restorePurchases();
      if (!mounted) return;
      setState(() => _customerInfo = info);
      if (info.entitlements.active.isNotEmpty) {
        _goToDashboard();
      } else {
        _showSnack('No active purchases found.');
      }
    } catch (e) {
      if (!mounted) return;
      _showSnack('Restore failed: $e');
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<void> _skip() async {
    // Reminder mode — trial is already active; just dismiss this page.
    if (widget.isReminder) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // First-time skip: register trial start on the server.
    DateTime? trialExpiry;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isNotEmpty) {
        final response = await http.post(
          Uri.parse(APIResource.START_TRIAL),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final expiryStr = data['trialExpiryDate'] as String?;
          if (expiryStr != null) {
            trialExpiry = DateTime.tryParse(expiryStr);
          }
          // Cache locally as a backup so the app works offline
          await prefs.setString(
              'trialStartDate', data['trialStartDate'] ?? '');
        }
      }
    } catch (_) {
      // API failed — fall back to local storage so user isn't blocked
      final prefs = await SharedPreferences.getInstance();
      if ((prefs.getString('trialStartDate') ?? '').isEmpty) {
        final now = DateTime.now();
        await prefs.setString('trialStartDate', now.toIso8601String());
        trialExpiry = now.add(const Duration(days: 7));
      }
    }

    if (!mounted) return;
    // Show trial-started dialog before going to dashboard
    await _showTrialStartedDialog(trialExpiry);
    if (mounted) _goToDashboard();
  }

  Future<void> _showTrialStartedDialog(DateTime? expiryDate) async {
    final expiry = expiryDate ?? DateTime.now().add(const Duration(days: 7));
    final expiryFormatted =
        '${expiry.day} ${_monthName(expiry.month)} ${expiry.year}';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_rounded,
                    color: Color(0xFFFF9800), size: 40),
              ),
              const SizedBox(height: 18),
              const Text(
                '7-Day Free Trial Started!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Text(
                'You have full access to all CalorAI Premium features until $expiryFormatted.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black54, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 6),
              const Text(
                'After your trial ends you can subscribe to keep your progress.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Start Exploring',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  void _goToDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => MainNavigationScreen()),
      (_) => false,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.showSkip
            ? null
            : IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    _goToDashboard();
                  }
                },
              ),
        title: const Text('Premium', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          if (widget.showSkip)
            TextButton(
              onPressed: _skip,
              child: const Text('Skip',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
            )
          else
            TextButton(
              onPressed: (_restoring || _loading) ? null : _restore,
              child: _restoring
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Restore',
                      style: TextStyle(color: _primary, fontSize: 13)),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_isPremium) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, color: _primary, size: 64),
            SizedBox(height: 16),
            Text('You\'re a Premium member!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('Enjoy all features of CalorAI.',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final offering = _offerings?.current;
    if (offering == null || offering.availablePackages.isEmpty) {
      // Show mock UI in debug/simulator so the screen can be previewed
      if (kDebugMode) return _buildMockPaywall();
      return const Center(child: Text('No plans available at this time.'));
    }

    // Sort: monthly first, then yearly
    final packages = [...offering.availablePackages]..sort((a, b) {
        final order = [
          PackageType.monthly,
          PackageType.annual,
          PackageType.weekly,
          PackageType.lifetime,
        ];
        return order
            .indexOf(a.packageType)
            .compareTo(order.indexOf(b.packageType));
      });

    return _buildPaywall(
      cards: packages
          .map((pkg) => _PackageCard(
                package: pkg,
                onTap: _purchasing ? null : () => _purchase(pkg),
                loading: _purchasing,
              ))
          .toList(),
    );
  }

  Widget _buildMockPaywall() {
    return _buildPaywall(
      cards: [
        _MockPackageCard(
          title: 'Monthly',
          description: 'Billed every month',
          price: '\$4.99',
          period: '/ month',
          isYearly: false,
          onTap: () => _showSnack('Purchase unavailable in simulator'),
        ),
        _MockPackageCard(
          title: 'Annual',
          description: 'Billed once a year — save 50%',
          price: '\$29.99',
          period: '/ year',
          isYearly: true,
          onTap: () => _showSnack('Purchase unavailable in simulator'),
        ),
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Widget _buildPaywall({required List<Widget> cards}) {
    // Wrapped in SingleChildScrollView to prevent overflow on smaller screens
    // and to accommodate the extra legal links required by guideline 3.1.2(c).
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Unlock CalorAI Premium',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Everything you need to reach your health goals.',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Feature list — required by App Store guideline 3.1.2(c)
          _FeatureRow(
              icon: Icons.camera_alt_rounded,
              text:
                  'AI Food Scanner — instant calorie & macro detection from photos'),
          _FeatureRow(
              icon: Icons.restaurant_menu_rounded,
              text:
                  'Personalised AI Meal Plans — tailored to your goals daily'),
          _FeatureRow(
              icon: Icons.bar_chart_rounded,
              text: 'Unlimited Calorie & Macro Tracking — no daily cap'),
          _FeatureRow(
              icon: Icons.fitness_center_rounded,
              text:
                  'Workout Logging — log exercises and track calories burned'),
          _FeatureRow(
              icon: Icons.water_drop_rounded,
              text: 'Water Intake Tracking — hit your daily hydration goal'),
          _FeatureRow(
              icon: Icons.directions_walk_rounded,
              text: 'Step Counter — connected to Apple Health'),
          const SizedBox(height: 20),
          ...cards,
          const SizedBox(height: 12),
          TextButton(
            onPressed: (_restoring || _loading) ? null : _restore,
            child: Text(
              _restoring ? 'Restoring...' : 'Restore Purchases',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const SizedBox(height: 4),
          // Privacy Policy & Terms links — required by guideline 3.1.2(c)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _launchUrl('https://www.calorai.app/privacy'),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Text('  ·  ',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
              GestureDetector(
                onTap: () => _launchUrl('https://www.calorai.app/terms'),
                child: const Text(
                  'Terms of Use',
                  style: TextStyle(
                    color: _primary,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Subscriptions auto-renew unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in your App Store settings.',
            style: TextStyle(color: Colors.grey, fontSize: 10),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF9800)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 13, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockPackageCard extends StatelessWidget {
  const _MockPackageCard({
    required this.title,
    required this.description,
    required this.price,
    required this.period,
    required this.isYearly,
    required this.onTap,
  });

  final String title;
  final String description;
  final String price;
  final String period;
  final bool isYearly;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF9800);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isYearly ? primary.withOpacity(0.08) : Colors.white,
          border: Border.all(
            color: isYearly ? primary : Colors.grey.shade300,
            width: isYearly ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                  if (isYearly) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('BEST VALUE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: primary)),
                Text(period,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({
    required this.package,
    required this.onTap,
    required this.loading,
  });

  final Package package;
  final VoidCallback? onTap;
  final bool loading;

  bool get _isYearly => package.packageType == PackageType.annual;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF9800);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _isYearly ? primary.withOpacity(0.08) : Colors.white,
          border: Border.all(
            color: _isYearly ? primary : Colors.grey.shade300,
            width: _isYearly ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package.storeProduct.title
                        .replaceAll(RegExp(r'\s*\(.*?\)'), ''),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  if (_isYearly) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('BEST VALUE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    package.storeProduct.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  package.storeProduct.priceString,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: primary),
                ),
                Text(
                  _isYearly ? '/ year' : '/ month',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
