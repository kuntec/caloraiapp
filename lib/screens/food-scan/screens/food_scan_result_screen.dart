import 'package:calorai/api/api_call.dart';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/models/FoodData.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_scan_model.dart';
import '../services/food_scan_service.dart';
import '../widgets/detected_food_card.dart';
import '../widgets/scan_summary_card.dart';

class FoodScanResultScreen extends StatefulWidget {
  final String userId;
  final FoodScanModel scan;

  const FoodScanResultScreen({
    super.key,
    required this.userId,
    required this.scan,
  });

  @override
  State<FoodScanResultScreen> createState() => _FoodScanResultScreenState();
}

class _FoodScanResultScreenState extends State<FoodScanResultScreen> {
  late FoodScanModel scan;
  final service = FoodScanService();

  bool confirming = false;
  bool adding = false;
  bool deleting = false;

  @override
  void initState() {
    super.initState();
    scan = widget.scan;
  }

  Future<void> _confirmScan() async {
    try {
      setState(() => confirming = true);

      final updated = await service.confirmScan(
        scanId: scan.id,
        userId: widget.userId,
      );

      setState(() => scan = updated);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food scan confirmed")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => confirming = false);
    }
  }

  /// Detect meal type from the current time of day.
  String _mealTypeForNow() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 11) return 'breakfast';
    if (hour >= 11 && hour < 15) return 'lunch';
    if (hour >= 15 && hour < 20) return 'dinner';
    return 'snack';
  }

  Future<void> _addToLog() async {
    try {
      setState(() => adding = true);

      // ── Step 1: Mark the scan record as added (existing flag) ──────
      await service.addToLog(
        scanId: scan.id,
        userId: widget.userId,
      );

      // ── Step 2: Actually write to the food log ─────────────────────
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token") ?? '';

      // Build a descriptive name from detected items
      final names = scan.detectedItems.map((i) => i.name).take(2).join(' + ');
      final mealName = names.isNotEmpty ? names : 'AI Scanned Meal';

      // Build a Food object from scan totals
      final food = Food(
        name: mealName,
        brand: 'CalorAI Scan',
        description: scan.detectedItems.length > 1
            ? '${scan.detectedItems.length} items detected'
            : null,
        servingSize: 1,
        servingUnit: 'serving',
        servingsPerContainer: 1,
        source: 'user',
        nutrients: Nutrients(
          calories: scan.totalCalories,
          proteinG: scan.totalProtein,
          carbsG: scan.totalCarbs,
          fatsG: scan.totalFats,
          saturatedFatG: 0,
          polyunsaturatedFatG: 0,
          monounsaturatedFatG: 0,
          transFatG: 0,
          cholesterolMg: 0,
          fiberG: 0,
          sugarG: 0,
          sodiumMg: 0,
          potassiumMg: 0,
          vitaminAMcg: 0,
          vitaminCMg: 0,
          calciumMg: 0,
          ironMg: 0,
        ),
      );

      // Create the food entry on the backend
      final foodData = await ApiCall().addFood(food, token);
      final createdId = foodData.food?.id ?? '';

      if (createdId.isNotEmpty) {
        final now = DateTime.now();
        final date = DateFormat('yyyy-MM-dd').format(now);
        final time = DateFormat('hh:mm a').format(now);
        final mealType = _mealTypeForNow();

        await ApiCall().addFoodLog(
          date, time, mealType, createdId, 1, 'ai-scan', token,
        );
      }

      // ── Step 3: Refresh the scan to update UI chips ────────────────
      try {
        final refreshed = await service.getSingleScan(
          scanId: scan.id,
          userId: widget.userId,
        );
        if (mounted) setState(() => scan = refreshed);
      } catch (_) {
        // Not critical — UI will still show success snackbar
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Added to today's food log ✓"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => adding = false);
    }
  }

  Future<void> _deleteScan() async {
    try {
      setState(() => deleting = true);

      await service.deleteScan(
        scanId: scan.id,
        userId: widget.userId,
      );

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Food scan deleted")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => deleting = false);
    }
  }

  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F7FB);
    const ink = primaryOrangeDark;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: ink,
        centerTitle: true,
        title: const Text(
          "Food Scan Result",
          style: TextStyle(
              color: primaryOrangeDark,
              fontWeight: FontWeight.w800,
              fontSize: 14),
        ),
        actions: [
          IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: primaryOrangeDark,
                    ),
                  )
                : const Icon(Icons.delete_outline),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (scan.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                scan.imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _statusChip(scan.status, Colors.orange),
              if (scan.isConfirmed) _statusChip("Confirmed ✓", Colors.green),
              if (scan.addedToFoodLog) _statusChip("Logged ✓", Colors.blue),
            ],
          ),
          const SizedBox(height: 16),
          ScanSummaryCard(
            calories: scan.totalCalories,
            protein: scan.totalProtein,
            carbs: scan.totalCarbs,
            fats: scan.totalFats,
          ),
          const SizedBox(height: 18),
          const Text(
            "Detected Foods",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...scan.detectedItems.map((item) => DetectedFoodCard(item: item)),
          if (scan.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(scan.notes),
              ),
            ),
          ],
          const SizedBox(height: 16),

          // ── Citations / Data Sources ───────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info_outline, size: 14, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      "About Nutritional Estimates",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Calorie and macro estimates are generated by AI image analysis and are based on the USDA FoodData Central database (fdc.nal.usda.gov) and standard nutritional reference values from the FDA Dietary Guidelines.",
                  style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.5),
                ),
                const SizedBox(height: 6),
                const Text(
                  "These are estimates only and may vary based on portion size, preparation method, and ingredient variations. CalorAI does not provide medical or dietary advice. Consult a qualified healthcare professional for personalised nutrition guidance.",
                  style: TextStyle(fontSize: 11, color: Colors.black54, height: 1.5),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryOrangeDark),
                  ),
                  onPressed:
                      scan.isConfirmed || confirming ? null : _confirmScan,
                  child: confirming
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Confirm",
                          style: TextStyle(
                              fontSize: 16, color: primaryOrangeDark)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scan.addedToFoodLog
                        ? Colors.green
                        : primaryOrangeDark,
                  ),
                  onPressed: adding || scan.addedToFoodLog ? null : _addToLog,
                  child: adding
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          scan.addedToFoodLog ? "Logged ✓" : "Add to Log",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this item?'),
                Text('This action cannot be undone.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(ctx).pop();
                _deleteScan();
              },
            ),
          ],
        );
      },
    );
  }
}
