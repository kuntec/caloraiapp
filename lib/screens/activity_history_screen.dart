import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/models/RecentActivityData.dart';
import 'package:calorai/widgets/HorizontalDatePicker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  List<Activities> _activities = [];
  bool _isLoading = true;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final date = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final data = await ApiCall().recentActivity(date, _token);
      if (!mounted) return;
      setState(() {
        _activities = data.activities ?? [];
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteItem(int index) async {
    final item = _activities[index];
    try {
      if (item.isFood) {
        await ApiCall().deleteFoodLog(item.id, _token);
      } else {
        await ApiCall().deleteExerciseLog(item.id, _token);
      }
      if (mounted) setState(() => _activities.removeAt(index));
    } catch (e) {
      await _loadActivities();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Activity History',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w800,
                fontSize: 17,
              ),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_selectedDate),
              style: const TextStyle(
                color: Colors.black45,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Horizontal date picker
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 4),
            child: Horizontaldatepicker(
              currentDate: _selectedDate,
              onDateSelected: (date) {
                setState(() => _selectedDate = date);
                _loadActivities();
              },
            ),
          ),
          const SizedBox(height: 4),

          // Activity list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryOrangeLight))
                : _activities.isEmpty
                    ? _EmptyState(date: _selectedDate)
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                        itemCount: _activities.length,
                        itemBuilder: (ctx, i) {
                          final item = _activities[i];
                          return Dismissible(
                            key: ValueKey('${item.type}_${item.id}_$i'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete,
                                  color: Colors.white, size: 26),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Delete activity?'),
                                      content: Text(
                                          "Remove '${item.title}' from your logs?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Delete',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                            },
                            onDismissed: (_) => _deleteItem(i),
                            child: _HistoryActivityCard(item: item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final DateTime date;
  const _EmptyState({required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off,
              color: Colors.grey.shade300, size: 64),
          const SizedBox(height: 14),
          Text(
            'No activity on\n${DateFormat('MMMM d, yyyy').format(date)}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Activity card (same style as dashboard)
// ─────────────────────────────────────────────────────────────────────────────

class _HistoryActivityCard extends StatelessWidget {
  final Activities item;
  const _HistoryActivityCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isFood = item.isFood;
    final iconBg = isFood
        ? Colors.orange.withOpacity(0.12)
        : Colors.blue.withOpacity(0.12);
    final iconColor = isFood ? Colors.orange : Colors.blue;
    final icon = isFood ? Icons.restaurant : Icons.fitness_center;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 12),
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
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isFood
                      ? (item.subtitle ?? '')
                      : _exerciseSubtitle(item),
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _pill('${item.calories} kcal'),
                    if (isFood && item.macros != null) ...[
                      _pill('P ${_fmt(item.macros!.proteinG)}g'),
                      _pill('C ${_fmt(item.macros!.carbsG)}g'),
                      _pill('F ${_fmt(item.macros!.fatsG)}g'),
                    ],
                    if (!isFood && item.durationMin != null)
                      _pill('${item.durationMin} min'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600)),
      );

  static String _exerciseSubtitle(Activities item) {
    final parts = <String>[];
    if (item.exerciseType != null && item.exerciseType!.isNotEmpty)
      parts.add(item.exerciseType!);
    if (item.intensity != null && item.intensity!.isNotEmpty)
      parts.add('• ${item.intensity}');
    return parts.join(' ');
  }

  static String _fmt(num v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
}
