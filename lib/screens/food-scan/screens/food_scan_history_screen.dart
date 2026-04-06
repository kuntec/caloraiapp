import 'package:flutter/material.dart';
import '../models/food_scan_model.dart';
import '../services/food_scan_service.dart';
import 'food_scan_result_screen.dart';

class FoodScanHistoryScreen extends StatefulWidget {
  final String userId;

  const FoodScanHistoryScreen({super.key, required this.userId});

  @override
  State<FoodScanHistoryScreen> createState() => _FoodScanHistoryScreenState();
}

class _FoodScanHistoryScreenState extends State<FoodScanHistoryScreen> {
  final service = FoodScanService();
  bool isLoading = true;
  List<FoodScanModel> scans = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final result = await service.getHistory(widget.userId);
      setState(() {
        scans = result;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "";
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Scan History"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : scans.isEmpty
              ? const Center(child: Text("No food scans found"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: scans.length,
                  itemBuilder: (context, index) {
                    final scan = scans[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: scan.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  scan.imageUrl,
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.fastfood),
                        title: Text(
                          "${scan.totalCalories.toStringAsFixed(0)} kcal",
                        ),
                        subtitle: Text(
                          "${scan.detectedItems.length} items • ${_formatDate(scan.createdAt)}",
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FoodScanResultScreen(
                                userId: widget.userId,
                                scan: scan,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
