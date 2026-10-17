import 'dart:io';
import 'package:calorai/constants/constants.dart';
import 'package:calorai/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
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

  /// Shows a dialog explaining why camera access is needed with an
  /// "Open Settings" button so the user can grant the permission themselves.
  Future<void> _showCameraPermissionDialog() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Camera Access Required'),
        content: const Text(
          'CalorAI needs camera access to scan your food and estimate nutrition.\n\n'
          'Please go to Settings → CalorAI → Camera and enable access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Not Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            style: TextButton.styleFrom(foregroundColor: primaryOrangeDark),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAnalyze(ImageSource source) async {
    // For camera source, verify permission before launching the picker.
    if (source == ImageSource.camera) {
      final status = await Permission.camera.status;

      if (status.isPermanentlyDenied) {
        // User previously denied and ticked "Don't ask again" — must go to Settings.
        await _showCameraPermissionDialog();
        return;
      }

      if (status.isDenied) {
        // Not yet decided — request it.
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (result.isPermanentlyDenied && mounted) {
            await _showCameraPermissionDialog();
          }
          return;
        }
      }
    }

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
      // Show a friendly message instead of a raw exception string.
      final msg = e.toString().toLowerCase();
      final friendly = msg.contains('permission') || msg.contains('denied')
          ? 'Camera access was denied. Please enable it in Settings.'
          : 'Could not process the image. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendly)),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      backgroundColor: bg,
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
                  leading: const Icon(
                    Icons.camera_alt,
                    color: primaryOrangeDark,
                  ),
                  title: const Text(
                    "Take Photo",
                    style: TextStyle(color: primaryOrangeDark),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAndAnalyze(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library,
                    color: primaryOrangeDark,
                  ),
                  title: const Text(
                    "Choose from Gallery",
                    style: TextStyle(color: primaryOrangeDark),
                  ),
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
    const bg = Color(0xFFF7F7FB);
    const card = Color(0xFFF3F2F8);
    const ink = primaryOrangeDark;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        foregroundColor: ink,
        centerTitle: true,
        title: const Text(
          "AI Food Scan",
          style: TextStyle(
              color: primaryOrangeDark,
              fontWeight: FontWeight.w800,
              fontSize: 14),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    primaryOrangeLight,
                    Color(0xFFFF5C00),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Scan your meal instantly",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Take a photo or upload an image to estimate calories, protein, carbs, and fats.",
                      style: TextStyle(
                        color: Colors.white,
                      ),
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
                            : const Icon(
                                Icons.camera_alt,
                                color: primaryOrangeDark,
                              ),
                        label: Text(
                          isLoading ? "Analyzing..." : "Scan Food",
                          style: TextStyle(
                              color: primaryOrangeDark,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GradientButton(
              text: "View Scan History",
              enabled: !isLoading,
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
              gradient: const LinearGradient(
                colors: [primary, primary2],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
