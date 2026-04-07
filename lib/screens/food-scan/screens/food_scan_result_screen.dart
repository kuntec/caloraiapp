import 'package:calorai/constants/constants.dart';
import 'package:flutter/material.dart';
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

  Future<void> _addToLog() async {
    try {
      setState(() => adding = true);

      await service.addToLog(
        scanId: scan.id,
        userId: widget.userId,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Marked as added to food log")),
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
    const card = Color(0xFFF3F2F8);
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
            //onPressed: deleting ? null : _deleteScan,
            onPressed: () {
              _showDeleteDialog(context);
            },
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
              if (scan.isConfirmed) _statusChip("Confirmed", Colors.green),
              if (scan.addedToFoodLog) _statusChip("Added to Log", Colors.blue),
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
                    backgroundColor: primaryOrangeDark,
                  ),
                  onPressed: adding ? null : _addToLog,
                  child: adding
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Add to Log",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
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
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss without action
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                _deleteScan();
                // TODO: Add your delete logic here
                Navigator.of(context).pop(); // Dismiss and proceed
              },
            ),
          ],
        );
      },
    );
  }
}
