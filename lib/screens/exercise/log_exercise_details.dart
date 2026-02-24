import 'package:calorai/constants/constants.dart';
import 'package:calorai/constants/utility.dart';
import 'package:calorai/screens/exercise/add_burned_calories.dart';
import 'package:flutter/material.dart';

class RunSetupScreen extends StatefulWidget {
  dynamic title;
  RunSetupScreen({super.key, required this.title});

  @override
  State<RunSetupScreen> createState() => _RunSetupScreenState();
}

class _RunSetupScreenState extends State<RunSetupScreen> {
  // 0 = Low, 1 = Medium, 2 = High
  int intensityIndex = 1;

  final List<int> presetMins = const [15, 30, 60, 90];
  int selectedMins = 30;
  late final TextEditingController minutesCtrl =
      TextEditingController(text: selectedMins.toString());

  @override
  void dispose() {
    minutesCtrl.dispose();
    super.dispose();
  }

  void _selectPreset(int mins) {
    setState(() {
      selectedMins = mins;
      minutesCtrl.text = mins.toString();
      minutesCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: minutesCtrl.text.length),
      );
    });
  }

  void _onMinutesChanged(String v) {
    final parsed = int.tryParse(v);
    if (parsed == null) return;
    setState(() => selectedMins = parsed);
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F7FB);
    const card = Color(0xFFF3F2F8);
    const ink = Color(0xFF0E0E10);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.maybePop(context),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Icon(Icons.directions_run, size: 18, color: ink),
                      const SizedBox(width: 8),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 44), // to balance the back button width
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Set intensity
                    Row(
                      children: const [
                        Icon(Icons.wb_sunny_outlined, size: 20, color: ink),
                        SizedBox(width: 10),
                        Text(
                          "Set intensity",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left text block
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _IntensityLine(
                                  title: "High",
                                  subtitle:
                                      "Sprinting – 14 mph (4 minute miles)",
                                  dim: intensityIndex != 2,
                                  emphasize: intensityIndex == 2,
                                ),
                                const SizedBox(height: 14),
                                _IntensityLine(
                                  title: "Medium",
                                  subtitle: "Jogging – 6 mph (10 minute miles)",
                                  dim: intensityIndex != 1,
                                  emphasize: intensityIndex == 1,
                                ),
                                const SizedBox(height: 14),
                                _IntensityLine(
                                  title: "Low",
                                  subtitle:
                                      "Chill walk – 3 mph (20 minute miles)",
                                  dim: intensityIndex != 0,
                                  emphasize: intensityIndex == 0,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Right vertical slider
                          SizedBox(
                            width: 52,
                            height: 170,
                            child: RotatedBox(
                              quarterTurns: 3, // makes it vertical
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 6,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 10,
                                  ),
                                  overlayShape: const RoundSliderOverlayShape(
                                    overlayRadius: 18,
                                  ),
                                ),
                                child: Slider(
                                  min: 0,
                                  max: 2,
                                  divisions: 2,
                                  value: intensityIndex.toDouble(),
                                  onChanged: (v) => setState(
                                      () => intensityIndex = v.round()),
                                  activeColor: ink,
                                  inactiveColor: const Color(0xFFD8D6E3),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 26),

                    // Duration header
                    Row(
                      children: const [
                        Icon(Icons.timer_outlined, size: 20, color: ink),
                        SizedBox(width: 10),
                        Text(
                          "Duration",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: ink,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Chips
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: presetMins.map((m) {
                        final selected = m == selectedMins;
                        return _PillButton(
                          text: "$m mins",
                          selected: selected,
                          onTap: () => _selectPreset(m),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // Manual input
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E2EA)),
                      ),
                      child: TextField(
                        controller: minutesCtrl,
                        keyboardType: TextInputType.number,
                        onChanged: _onMinutesChanged,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "30",
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: ink,
                        ),
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Bottom Continue button
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ink,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // Use intensityIndex + selectedMins
                    // 0 Low, 1 Medium, 2 High
                    debugPrint(
                        "Intensity: $intensityIndex, Minutes: $selectedMins");
                    MyUtility.changePage(
                        context,
                        AddBurnedCaloriesScreen(
                          type: "run",
                          name: "Manual Calorie",
                          intensity: "low",
                          durationMinutes: selectedMins,
                          caloriesBurned: 0,
                        ));
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntensityLine extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool dim;
  final bool emphasize;

  const _IntensityLine({
    required this.title,
    required this.subtitle,
    required this.dim,
    required this.emphasize,
  });

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF0E0E10);

    return Opacity(
      opacity: dim ? 0.45 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: emphasize ? 26 : 15,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
              color: ink,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _PillButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    //const ink = Color(0xFF0E0E10);
    const ink = primaryOrangeDark;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? ink : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: ink
              //color: selected ? ink : const Color(0xFFBDBDC7),
              ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : ink,
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFF0F0F6),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF0E0E10),
        ),
      ),
    );
  }
}
