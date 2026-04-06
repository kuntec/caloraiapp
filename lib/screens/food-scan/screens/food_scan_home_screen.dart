import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/food_scan_service.dart';
import 'food_scan_history_screen.dart';
import 'food_scan_result_screen.dart';

class FoodScanHomeScreen extends StatefulWidget {
  final String userId;

  const FoodScanHomeScreen({super.key, required this.userId});

  @override
  State<FoodScanHomeScreen> createState() => _FoodScanHomeScreenState();
}

class _FoodScanHomeScreenState extends State<FoodScanHomeScreen> {
  final FoodScanService service = FoodScanService();
  final ImagePicker picker = ImagePicker();

  bool isLoading = false;

  Future<void> _pickAndAnalyze(ImageSource source) async {
    try {
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() => isLoading = true);

      final result = await service.analyzeFood(
        userId: widget.userId,
        imageFile: File(picked.path),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FoodScanResultScreen(
            userId: widget.userId,
            scan: result,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text("Take Photo"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndAnalyze(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text("Choose from Gallery"),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndAnalyze(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Food Scan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Scan your meal instantly",
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Take a photo or upload an image to estimate calories, protein, carbs, and fats.",
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _showPickerOptions,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.camera_alt),
                        label: Text(
                          isLoading ? "Analyzing..." : "Scan Food",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FoodScanHistoryScreen(
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
                child: const Text("View Scan History"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
