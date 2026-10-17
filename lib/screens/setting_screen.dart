import 'dart:convert';

import 'package:calorai/api/api_call.dart';
import 'package:calorai/api/api_resources.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/screens/authenticate/auth_choice_screen.dart';
import 'package:calorai/screens/sources_screen.dart';
import 'package:calorai/screens/subscription_page.dart';
import 'package:calorai/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  static const bg = Color(0xFFF9FAFB);

  bool _isPremium = false;
  bool _loadingSubscription = true;
  bool _deletingAccount = false;
  String? _activePlanLabel;

  // Trial state
  DateTime? _trialExpiryDate;
  bool _trialExpired = false;
  int _trialDaysLeft = 0;

  // Reminder toggles
  bool _notifBreakfast = true;
  bool _notifLunch = true;
  bool _notifDinner = true;
  bool _notifWater = true;

  // Water cup size
  int _waterCupMl = 250;

  @override
  void initState() {
    super.initState();
    _checkSubscription();
    _loadReminderPrefs();
  }

  Future<void> _loadReminderPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifBreakfast = prefs.getBool(NotificationService.kBreakfast) ?? true;
      _notifLunch = prefs.getBool(NotificationService.kLunch) ?? true;
      _notifDinner = prefs.getBool(NotificationService.kDinner) ?? true;
      _notifWater = prefs.getBool(NotificationService.kWater) ?? true;
      _waterCupMl = prefs.getInt('waterCupMl') ?? 250;
    });
  }

  Future<void> _toggleReminder(String key, bool value) async {
    // Request permission on first enable
    if (value) {
      await NotificationService.requestPermissions();
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    await NotificationService.scheduleAllReminders();
    if (!mounted) return;
    setState(() {
      switch (key) {
        case NotificationService.kBreakfast:
          _notifBreakfast = value;
          break;
        case NotificationService.kLunch:
          _notifLunch = value;
          break;
        case NotificationService.kDinner:
          _notifDinner = value;
          break;
        case NotificationService.kWater:
          _notifWater = value;
          break;
      }
    });
  }

  Future<void> _showWaterCupPicker() async {
    const options = [100, 150, 200, 250, 300, 350, 400, 500];
    final picked = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Water Per Entry',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...options.map((ml) => ListTile(
                            title: Text(
                              '$ml ml',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: _waterCupMl == ml
                                ? const Icon(Icons.check_circle_rounded,
                                    color: Color(0xFF2196F3))
                                : null,
                            onTap: () => Navigator.pop(_, ml),
                          )),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (picked != null && picked != _waterCupMl) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('waterCupMl', picked);
      if (mounted) setState(() => _waterCupMl = picked);
    }
  }

  Future<void> _checkSubscription() async {
    try {
      // Fetch RevenueCat status and trial status in parallel
      final results = await Future.wait([
        Purchases.getCustomerInfo(),
        _fetchTrialStatus(),
      ]);

      final info = results[0] as CustomerInfo;
      final trial = results[1] as Map<String, dynamic>?;

      if (mounted) {
        String? label;
        if (info.activeSubscriptions.isNotEmpty) {
          final id = info.activeSubscriptions.first.toLowerCase();
          if (id.contains('annual') || id.contains('yearly') || id.contains('year')) {
            label = 'Annual Plan';
          } else if (id.contains('monthly') || id.contains('month')) {
            label = 'Monthly Plan';
          } else {
            label = 'Premium';
          }
        }

        DateTime? expiry;
        bool expired = false;
        int daysLeft = 0;
        if (trial != null && trial['trialStartDate'] != null) {
          final expiryStr = trial['trialExpiryDate'] as String?;
          if (expiryStr != null) expiry = DateTime.tryParse(expiryStr);
          expired = trial['trialExpired'] == true;
          if (expiry != null && !expired) {
            daysLeft = expiry.difference(DateTime.now()).inDays;
            if (daysLeft < 0) daysLeft = 0;
          }
        }

        setState(() {
          _isPremium = info.entitlements.active.isNotEmpty;
          _activePlanLabel = label;
          _trialExpiryDate = expiry;
          _trialExpired = expired;
          _trialDaysLeft = daysLeft;
          _loadingSubscription = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSubscription = false);
    }
  }

  Future<Map<String, dynamic>?> _fetchTrialStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) return null;
      final response = await http.get(
        Uri.parse(APIResource.TRIAL_STATUS),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  Future<void> _manageSubscription() async {
    final uri = Uri.parse('https://apps.apple.com/account/subscriptions');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
      (_) => false,
    );
  }

  Future<void> _resetForTesting() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset for Testing',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'This clears all local data and deletes the Firebase auth account '
          'so you can re-register with the same Google / Apple account.\n\n'
          'Backend data is NOT deleted.\n\n'
          'This option only appears in debug builds.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset',
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}

      try {
        await FirebaseAuth.instance.currentUser?.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          await FirebaseAuth.instance.signOut();
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Reset complete — register again as a new user'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset failed: $e')),
      );
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Account',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will permanently delete your account and all your data — '
          'calorie logs, meal history, workouts, and profile. '
          'This action cannot be undone.',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete My Account',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deletingAccount = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final apiCall = ApiCall();
      await apiCall.deleteAccount(token);

      try {
        await FirebaseAuth.instance.currentUser?.delete();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          // Re-auth required — backend data already wiped
        }
      }

      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
      await FirebaseAuth.instance.signOut();
      await prefs.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your account has been deleted.')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthChoiceScreen()),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _deletingAccount = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete account: ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            foregroundColor: primaryOrangeDark,
            elevation: 0,
            title: const Text(
              "Settings",
              style: TextStyle(
                  color: primaryOrangeDark,
                  fontWeight: FontWeight.w800,
                  fontSize: 14),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: primaryOrangeDark),
          ),
          body: ListView(
            children: [
              const SizedBox(height: 16),

              // ── Subscription ──────────────────────────────────────
              _SectionHeader(title: 'Subscription'),
              if (_loadingSubscription)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_isPremium)
                _SettingsTile(
                  icon: Icons.verified,
                  iconColor: Colors.green,
                  title: _activePlanLabel ?? 'Premium Active',
                  subtitle: 'Tap to manage or cancel in the App Store',
                  onTap: _manageSubscription,
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ),
                )
              else ...[
                if (_trialExpiryDate != null) _TrialBanner(
                  daysLeft: _trialDaysLeft,
                  expiryDate: _trialExpiryDate!,
                  expired: _trialExpired,
                  onSubscribe: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SubscriptionPage(showSkip: false)),
                  ).then((_) => _checkSubscription()),
                ),
                _SettingsTile(
                  icon: Icons.star_rounded,
                  iconColor: primaryOrangeDark,
                  title: 'Get Premium',
                  subtitle: 'Unlock all features of CalorAI',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const SubscriptionPage(showSkip: false)),
                  ).then((_) => _checkSubscription()),
                ),
                _SettingsTile(
                  icon: Icons.restore,
                  iconColor: Colors.grey,
                  title: 'Restore Purchases',
                  subtitle: 'Already subscribed? Restore your access',
                  onTap: () async {
                    try {
                      final info = await Purchases.restorePurchases();
                      if (!mounted) return;
                      final active = info.entitlements.active.isNotEmpty;
                      setState(() => _isPremium = active);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(active
                            ? 'Purchases restored!'
                            : 'No active purchases found.'),
                      ));
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Restore failed: $e')));
                    }
                  },
                ),
              ],

              const SizedBox(height: 24),

              // ── Reminders ─────────────────────────────────────────
              _SectionHeader(title: 'Reminders'),
              _ReminderTile(
                icon: Icons.free_breakfast_outlined,
                title: 'Breakfast Reminder',
                subtitle: '8:00 AM — daily',
                value: _notifBreakfast,
                onChanged: (v) =>
                    _toggleReminder(NotificationService.kBreakfast, v),
              ),
              _ReminderTile(
                icon: Icons.lunch_dining_outlined,
                title: 'Lunch Reminder',
                subtitle: '1:00 PM — daily',
                value: _notifLunch,
                onChanged: (v) =>
                    _toggleReminder(NotificationService.kLunch, v),
              ),
              _ReminderTile(
                icon: Icons.dinner_dining_outlined,
                title: 'Dinner Reminder',
                subtitle: '7:00 PM — daily',
                value: _notifDinner,
                onChanged: (v) =>
                    _toggleReminder(NotificationService.kDinner, v),
              ),
              _ReminderTile(
                icon: Icons.water_drop_outlined,
                title: 'Water Reminders',
                subtitle: 'Every 2 hours (8 AM – 8 PM)',
                value: _notifWater,
                onChanged: (v) =>
                    _toggleReminder(NotificationService.kWater, v),
              ),
              // Water cup size setting
              _SettingsTile(
                icon: Icons.water_drop,
                iconColor: const Color(0xFF2196F3),
                title: 'Water Per Entry',
                subtitle: '$_waterCupMl ml per tap',
                onTap: _showWaterCupPicker,
              ),

              const SizedBox(height: 24),

              // ── Account ───────────────────────────────────────────
              _SectionHeader(title: 'Account'),
              _SettingsTile(
                icon: Icons.logout,
                iconColor: Colors.grey,
                title: 'Sign Out',
                subtitle: 'Sign out of your CalorAI account',
                onTap: _signOut,
              ),

              const SizedBox(height: 24),

              // ── Danger Zone ───────────────────────────────────────
              _SectionHeader(title: 'Danger Zone'),
              ListTile(
                tileColor: Colors.white,
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'Delete Account',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.red),
                ),
                subtitle: const Text(
                  'Permanently delete your account and all data',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: _deletingAccount ? null : _confirmDeleteAccount,
              ),

              const SizedBox(height: 32),

              // ── Legal ─────────────────────────────────────────────
              _SectionHeader(title: 'Legal'),
              _SettingsTile(
                icon: Icons.science_outlined,
                iconColor: primaryOrangeDark,
                title: 'Scientific Sources',
                subtitle: 'Research & guidelines behind our health calculations',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SourcesScreen()),
                ),
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: Colors.grey,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: () async {
                  final uri = Uri.parse('https://www.calorai.app/privacy');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                iconColor: Colors.grey,
                title: 'Terms of Service',
                subtitle: 'Our terms and conditions',
                onTap: () async {
                  final uri = Uri.parse('https://www.calorai.app/terms');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),

              const SizedBox(height: 24),

              // ── Apple Health ───────────────────────────────────────
              _SectionHeader(title: 'Apple Health'),
              ListTile(
                tileColor: Colors.white,
                leading: const Icon(Icons.favorite_rounded,
                    color: Color(0xFFE53935)),
                title: const Text(
                  'Health Data Access',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: const Text(
                  'CalorAI reads your Step Count from Apple Health '
                  'to display your daily activity. No health data is uploaded to our servers.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () async {
                  final uri = Uri.parse('x-apple-health://');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  } else {
                    final settingsUri = Uri.parse('app-settings:');
                    if (await canLaunchUrl(settingsUri)) {
                      await launchUrl(settingsUri);
                    }
                  }
                },
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  'To change which Health data CalorAI can access, go to '
                  'Settings → Privacy & Security → Health → CalorAI.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 24),

              // ── Health Science & Sources ───────────────────────────
              _SectionHeader(title: 'Health Science & Sources'),
              _SettingsTile(
                icon: Icons.science_outlined,
                iconColor: Colors.blueGrey,
                title: 'Calorie & TDEE Calculations',
                subtitle:
                    'Based on the Mifflin-St Jeor equation (NIH / PubMed)',
                onTap: () async {
                  final uri =
                      Uri.parse('https://pubmed.ncbi.nlm.nih.gov/2305711/');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
              _SettingsTile(
                icon: Icons.lunch_dining_outlined,
                iconColor: Colors.blueGrey,
                title: 'Dietary Reference Intakes',
                subtitle:
                    'Macro targets based on NIH Office of Dietary Supplements',
                onTap: () async {
                  final uri =
                      Uri.parse('https://ods.od.nih.gov/factsheets/list-all/');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
              _SettingsTile(
                icon: Icons.directions_run_outlined,
                iconColor: Colors.blueGrey,
                title: 'Physical Activity Guidelines',
                subtitle:
                    'Activity level recommendations — WHO Global Guidelines',
                onTap: () async {
                  final uri = Uri.parse(
                      'https://www.who.int/publications/i/item/9789241599979');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  'CalorAI provides general wellness information for '
                  'educational purposes only. It is not a substitute for '
                  'professional medical advice, diagnosis, or treatment. '
                  'Always consult a qualified healthcare provider.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),

        // Full-screen loading overlay while deleting
        if (_deletingAccount)
          Container(
            color: Colors.black45,
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Deleting your account…',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ReminderTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: Icon(icon, color: primaryOrangeDark),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: primaryOrangeDark,
        onChanged: onChanged,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.8)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      leading: Icon(icon, color: iconColor),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trial Banner
// ─────────────────────────────────────────────────────────────────────────────
class _TrialBanner extends StatelessWidget {
  final int daysLeft;
  final DateTime expiryDate;
  final bool expired;
  final VoidCallback onSubscribe;

  const _TrialBanner({
    required this.daysLeft,
    required this.expiryDate,
    required this.expired,
    required this.onSubscribe,
  });

  static String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color iconColor;
    final String headline;
    final String subline;
    final IconData icon;

    if (expired) {
      bgColor = const Color(0xFFFFF0F0);
      borderColor = Colors.red.shade200;
      iconColor = Colors.red;
      icon = Icons.timer_off_rounded;
      headline = 'Your free trial has ended';
      subline = 'Subscribe now to continue using CalorAI.';
    } else if (daysLeft <= 2) {
      bgColor = const Color(0xFFFFF8E1);
      borderColor = Colors.orange.shade300;
      iconColor = Colors.orange.shade700;
      icon = Icons.warning_amber_rounded;
      headline = daysLeft == 0
          ? 'Trial expires today!'
          : 'Trial ends in $daysLeft ${daysLeft == 1 ? "day" : "days"}';
      subline =
          'Subscribe before ${daysLeft == 0 ? "midnight" : _monthName(expiryDate.month) + " ${expiryDate.day}"} to keep access.';
    } else {
      bgColor = const Color(0xFFF0FFF4);
      borderColor = Colors.green.shade200;
      iconColor = Colors.green.shade700;
      icon = Icons.timer_rounded;
      headline = '$daysLeft days left in your free trial';
      subline =
          'Trial ends ${_monthName(expiryDate.month)} ${expiryDate.day}, ${expiryDate.year}. Subscribe anytime to keep access.';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  headline,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subline,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrangeDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text(
                'Subscribe Now',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
