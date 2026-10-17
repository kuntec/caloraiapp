import 'dart:async';

import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterIntakeWidget extends StatefulWidget {
  int goal;
  int total;
  String currentDate;
  WaterIntakeWidget({
    required this.goal,
    required this.total,
    required this.currentDate,
    super.key,
  });

  @override
  State<WaterIntakeWidget> createState() => _WaterIntakeWidgetState();
}

class _WaterIntakeWidgetState extends State<WaterIntakeWidget> {
  int currentIntake = 0;
  int waterCup = kWaterCup;

  Timer? _debounce;
  bool _syncing = false;
  bool _syncError = false;

  @override
  void initState() {
    super.initState();
    currentIntake = widget.total;
    _loadCupSize();
  }

  Future<void> _loadCupSize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('waterCupMl') ?? kWaterCup;
    if (mounted) setState(() => waterCup = saved);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _adjust(int delta) {
    final next = currentIntake + delta;
    if (next < 0) return;
    setState(() {
      currentIntake = next;
      _syncError = false;
    });

    // Debounce: wait 800 ms after last tap before hitting the API
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 800), _sync);
  }

  Future<void> _sync() async {
    if (!mounted) return;
    setState(() => _syncing = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      await ApiCall().updateWaterIntake(currentIntake, token, widget.currentDate);
      if (!mounted) return;
      setState(() {
        widget.total = currentIntake;
        _syncing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _syncing = false;
        _syncError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.goal > 0
        ? (currentIntake / widget.goal).clamp(0.0, 1.0)
        : 0.0;
    final done = currentIntake >= widget.goal;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: kContainerBox,
      child: Row(
        children: [
          // ── Water icon ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: kContainerBox.copyWith(
              color: done ? primaryOrangeDark : primaryOrangeDark,
            ),
            child: const Icon(Icons.water_drop, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),

          // ── Label + value + progress bar ─────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text(
                      "Water",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    // Sync status indicator
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _syncing
                          ? const SizedBox(
                              key: ValueKey('spin'),
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                                color: primaryOrangeLight,
                              ),
                            )
                          : _syncError
                              ? const Icon(
                                  key: ValueKey('err'),
                                  Icons.warning_amber_rounded,
                                  size: 14,
                                  color: Colors.redAccent,
                                )
                              : done
                                  ? const Icon(
                                      key: ValueKey('done'),
                                      Icons.check_circle_rounded,
                                      size: 14,
                                      color: Colors.green,
                                    )
                                  : const SizedBox(
                                      key: ValueKey('idle'), width: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  "$currentIntake ml / ${widget.goal} ml",
                  style: const TextStyle(
                    fontSize: 11,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      done ? Colors.green : primaryOrangeDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── +/– buttons ──────────────────────────────────────────
          Row(
            children: [
              _WaterButton(
                icon: Icons.remove,
                onTap: () => _adjust(-waterCup),
                enabled: currentIntake > 0,
              ),
              const SizedBox(width: 6),
              _WaterButton(
                icon: Icons.add,
                onTap: () => _adjust(waterCup),
                enabled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _WaterButton({
    required this.icon,
    required this.onTap,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? primaryOrangeDark.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? primaryOrangeDark : Colors.grey.shade400,
        ),
      ),
    );
  }
}
