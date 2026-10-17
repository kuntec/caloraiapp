import 'dart:math';
import 'package:calorai/api/api_call.dart';
import 'package:calorai/widgets/weekly_calorie_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Data model for one day of macro + calorie data
// ─────────────────────────────────────────────────────────────────────────────
class _DayData {
  final DateTime date;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  const _DayData({
    required this.date,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────────────────────────────────────
class WeeklyProgressScreen extends StatefulWidget {
  const WeeklyProgressScreen({super.key});

  @override
  State<WeeklyProgressScreen> createState() => _WeeklyProgressScreenState();
}

class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  bool _loading = true;
  List<_DayData> _days = [];
  double _targetCalories = 2000;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      final targetCal = (prefs.getDouble('targetCalories') ??
              prefs.getInt('targetCalories')?.toDouble()) ??
          2000.0;

      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 6));
      final startStr = DateFormat('yyyy-MM-dd').format(start);
      final endStr = DateFormat('yyyy-MM-dd').format(now);

      final raw = await ApiCall().getWeeklyMetrics(startStr, endStr, token);

      final days = raw.map((m) {
        final dateStr = (m['date'] as String?)?.substring(0, 10) ?? '';
        final n = m['nutrientsConsumed'] as Map<String, dynamic>? ?? {};
        return _DayData(
          date: DateTime.tryParse(dateStr) ?? now,
          calories: (n['calories'] as num?)?.toDouble() ?? 0,
          protein: (n['protein_g'] as num?)?.toDouble() ?? 0,
          carbs: (n['carbs_g'] as num?)?.toDouble() ?? 0,
          fats: (n['fats_g'] as num?)?.toDouble() ?? 0,
        );
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      if (mounted) {
        setState(() {
          _days = days;
          _targetCalories = targetCal;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  List<WeeklyCaloriePoint> get _calPoints => _days
      .map((d) => WeeklyCaloriePoint(date: d.date, calories: d.calories))
      .toList();

  double get _avgCalories {
    if (_days.isEmpty) return 0;
    return _days.map((d) => d.calories).reduce((a, b) => a + b) / _days.length;
  }

  double get _totalCalories {
    if (_days.isEmpty) return 0;
    return _days.map((d) => d.calories).reduce((a, b) => a + b);
  }

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1A1A1A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Weekly Progress',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFEEEEEE)),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8B00)))
          : RefreshIndicator(
              color: const Color(0xFFFF8B00),
              onRefresh: _load,
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  // ── Summary tiles ─────────────────────────────────────────
                  _SummaryTiles(
                    avgCalories: _avgCalories,
                    totalCalories: _totalCalories,
                    target: _targetCalories,
                    activeDays: _days.where((d) => d.calories > 0).length,
                  ),
                  const SizedBox(height: 16),

                  // ── Calorie line chart ────────────────────────────────────
                  _ChartCard(
                    title: 'Calories',
                    subtitle: '7-day trend',
                    icon: Icons.show_chart_rounded,
                    child: SizedBox(
                      height: 200,
                      child: _days.isEmpty
                          ? _emptyPlaceholder('No calorie data yet')
                          : CustomPaint(
                              size: const Size(double.infinity, 200),
                              painter: _CaloriePainter(
                                points: _calPoints,
                                targetCalories: _targetCalories,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Macros bar chart ──────────────────────────────────────
                  _ChartCard(
                    title: 'Macros',
                    subtitle: 'Protein · Carbs · Fats (g)',
                    icon: Icons.bar_chart_rounded,
                    child: Column(
                      children: [
                        // Legend
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            _LegendDot(
                                color: Color(0xFF4CAF50), label: 'Protein'),
                            SizedBox(width: 16),
                            _LegendDot(
                                color: Color(0xFF2196F3), label: 'Carbs'),
                            SizedBox(width: 16),
                            _LegendDot(color: Color(0xFFFF8B00), label: 'Fats'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: _days.isEmpty
                              ? _emptyPlaceholder('No macro data yet')
                              : CustomPaint(
                                  size: const Size(double.infinity, 180),
                                  painter: _MacroPainter(days: _days),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Daily summary table ───────────────────────────────────
                  _DailySummaryTable(days: _days),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _emptyPlaceholder(String msg) => Center(
        child: Text(msg,
            style: const TextStyle(color: Colors.black38, fontSize: 13)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  Summary tiles
// ─────────────────────────────────────────────────────────────────────────────
class _SummaryTiles extends StatelessWidget {
  final double avgCalories;
  final double totalCalories;
  final double target;
  final int activeDays;

  const _SummaryTiles({
    required this.avgCalories,
    required this.totalCalories,
    required this.target,
    required this.activeDays,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _Tile(
            label: 'Avg / Day',
            value: avgCalories.round().toString(),
            unit: 'kcal',
            color: const Color(0xFFFF8B00),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Tile(
            label: 'Total Week',
            value: totalCalories.round().toString(),
            unit: 'kcal',
            color: const Color(0xFF2196F3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _Tile(
            label: 'Active Days',
            value: '$activeDays',
            unit: '/ 7',
            color: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _Tile(
      {required this.label,
      required this.value,
      required this.unit,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: value,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: color)),
                TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF888888),
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Chart card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const _ChartCard(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF8B00), size: 18),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A))),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFAAAAAA))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Calorie line chart (larger version of dashboard chart)
// ─────────────────────────────────────────────────────────────────────────────
class _CaloriePainter extends CustomPainter {
  final List<WeeklyCaloriePoint> points;
  final double targetCalories;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _leftPad = 48.0;
  static const _rightPad = 12.0;
  static const _topPad = 12.0;
  static const _bottomPad = 30.0;

  _CaloriePainter({required this.points, required this.targetCalories});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final chartW = size.width - _leftPad - _rightPad;
    final chartH = size.height - _topPad - _bottomPad;

    final maxCal =
        max(points.map((p) => p.calories).reduce(max), targetCalories);
    const minCal = 0.0;
    final calRange = maxCal - minCal == 0 ? 1 : maxCal - minCal;

    // grid
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 1;
    final yStyle = TextStyle(
        fontSize: 9, color: Colors.grey.shade500, fontWeight: FontWeight.w500);

    for (int i = 0; i <= 4; i++) {
      final y = _topPad + chartH * (1 - i / 4);
      canvas.drawLine(
          Offset(_leftPad, y), Offset(_leftPad + chartW, y), gridPaint);
      _text(canvas, ((minCal + calRange * i / 4)).round().toString(),
          Offset(0, y - 5), yStyle,
          maxWidth: 44);
    }

    // target dashed line
    if (targetCalories > 0) {
      final ty = _topPad + chartH * (1 - (targetCalories - minCal) / calRange);
      final tp = Paint()
        ..color = const Color(0xFFFF8B00).withOpacity(0.4)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      final dp = Path();
      double x = _leftPad;
      bool draw = true;
      while (x < _leftPad + chartW) {
        if (draw) {
          dp.moveTo(x, ty);
          dp.lineTo(min(x + 6, _leftPad + chartW), ty);
        }
        x += 10;
        draw = !draw;
      }
      canvas.drawPath(dp, tp);
    }

    // positions
    final n = points.length;
    final step = chartW / max(n - 1, 1);
    final offsets = <Offset>[];
    for (int i = 0; i < n; i++) {
      final x = _leftPad + i * step;
      final normY = (points[i].calories - minCal) / calRange;
      offsets.add(Offset(x, _topPad + chartH * (1 - normY)));
    }

    // gradient fill
    final fillPath = Path()..moveTo(offsets.first.dx, _topPad + chartH);
    for (final o in offsets) fillPath.lineTo(o.dx, o.dy);
    fillPath.lineTo(offsets.last.dx, _topPad + chartH);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFF8B00).withOpacity(0.25),
            const Color(0xFFFF8B00).withOpacity(0.0),
          ],
        ).createShader(Rect.fromLTWH(_leftPad, _topPad, chartW, chartH)),
    );

    // smooth line
    final linePaint = Paint()
      ..color = const Color(0xFFFF8B00)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final linePath = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (int i = 1; i < offsets.length; i++) {
      final p = offsets[i - 1], c = offsets[i];
      final cp1 = Offset((p.dx + c.dx) / 2, p.dy);
      final cp2 = Offset((p.dx + c.dx) / 2, c.dy);
      linePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, c.dx, c.dy);
    }
    canvas.drawPath(linePath, linePaint);
    // dots & day labels
    final dayLabelStyle = TextStyle(
        fontSize: 10, color: Colors.grey.shade600, fontWeight: FontWeight.w600);
    for (int i = 0; i < offsets.length; i++) {
      final o = offsets[i];
      canvas.drawCircle(
          o,
          5.5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          o,
          4,
          Paint()
            ..color = const Color(0xFFFF8B00)
            ..style = PaintingStyle.fill);
      final wd = points[i].date.weekday;
      _text(canvas, _dayLabels[wd - 1],
          Offset(o.dx - 12, size.height - _bottomPad + 6), dayLabelStyle,
          maxWidth: 28, centered: true);
    }
  }

  void _text(Canvas canvas, String text, Offset pos, TextStyle style,
      {double maxWidth = 60, bool centered = false}) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: maxWidth);
    final dx = centered ? pos.dx - tp.width / 2 : pos.dx;
    tp.paint(canvas, Offset(dx, pos.dy));
  }

  @override
  bool shouldRepaint(_CaloriePainter old) => old.points != points;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Macros grouped bar chart
// ─────────────────────────────────────────────────────────────────────────────
class _MacroPainter extends CustomPainter {
  final List<_DayData> days;

  static const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _leftPad = 40.0;
  static const _rightPad = 8.0;
  static const _topPad = 8.0;
  static const _bottomPad = 28.0;

  static const _proteinColor = Color(0xFF4CAF50);
  static const _carbsColor = Color(0xFF2196F3);
  static const _fatsColor = Color(0xFFFF8B00);

  _MacroPainter({required this.days});

  @override
  void paint(Canvas canvas, Size size) {
    if (days.isEmpty) return;

    final chartW = size.width - _leftPad - _rightPad;
    final chartH = size.height - _topPad - _bottomPad;

    final maxMacro = days
        .expand((d) => [d.protein, d.carbs, d.fats])
        .fold<double>(1.0, (prev, v) => v > prev ? v : prev);

    // grid
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 1;
    final yStyle = TextStyle(
        fontSize: 9, color: Colors.grey.shade400, fontWeight: FontWeight.w500);

    for (int i = 0; i <= 4; i++) {
      final y = _topPad + chartH * (1 - i / 4);
      canvas.drawLine(
          Offset(_leftPad, y), Offset(_leftPad + chartW, y), gridPaint);
      _text(canvas, (maxMacro * i / 4).round().toString(), Offset(0, y - 5),
          yStyle,
          maxWidth: 36);
    }

    final n = days.length;
    final groupW = chartW / n;
    const barCount = 3;
    const spacing = 2.0;
    final barW = (groupW - spacing * (barCount + 1)) / barCount;

    for (int i = 0; i < n; i++) {
      final d = days[i];
      final groupLeft = _leftPad + i * groupW;
      final barValues = [d.protein, d.carbs, d.fats];
      final barColors = [_proteinColor, _carbsColor, _fatsColor];

      for (int j = 0; j < barCount; j++) {
        final x = groupLeft + spacing * (j + 1) + barW * j;
        final normH = (barValues[j] / maxMacro).clamp(0.0, 1.0);
        final barH = normH * chartH;
        final y = _topPad + chartH - barH;

        final rRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, barW, barH),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        );
        canvas.drawRRect(
            rRect, Paint()..color = barColors[j].withOpacity(0.85));
      }

      // Day label
      final wd = days[i].date.weekday;
      _text(
          canvas,
          _dayLabels[wd - 1],
          Offset(groupLeft + groupW / 2 - 12, size.height - _bottomPad + 6),
          TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600),
          maxWidth: 28,
          centered: true);
    }
  }

  void _text(Canvas canvas, String text, Offset pos, TextStyle style,
      {double maxWidth = 60, bool centered = false}) {
    final tp = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr)
      ..layout(maxWidth: maxWidth);
    final dx = centered ? pos.dx - tp.width / 2 : pos.dx;
    tp.paint(canvas, Offset(dx, pos.dy));
  }

  @override
  bool shouldRepaint(_MacroPainter old) => old.days != days;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Legend dot
// ─────────────────────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Daily summary table
// ─────────────────────────────────────────────────────────────────────────────
class _DailySummaryTable extends StatelessWidget {
  final List<_DayData> days;
  const _DailySummaryTable({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: const [
                Icon(Icons.table_rows_rounded,
                    color: Color(0xFFFF8B00), size: 18),
                SizedBox(width: 8),
                Text('Daily Summary',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A))),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Column labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Expanded(
                    flex: 3,
                    child: Text('Date',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFAAAAAA)))),
                Expanded(
                    flex: 2,
                    child: Text('Kcal',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFAAAAAA)))),
                Expanded(
                    flex: 2,
                    child: Text('Prot',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4CAF50)))),
                Expanded(
                    flex: 2,
                    child: Text('Carb',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2196F3)))),
                Expanded(
                    flex: 2,
                    child: Text('Fat',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFF8B00)))),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          if (days.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No data for this week',
                    style: TextStyle(color: Colors.black38, fontSize: 13)),
              ),
            )
          else
            ...days.asMap().entries.map((entry) {
              final i = entry.key;
              final d = entry.value;
              final bg = i.isOdd ? const Color(0xFFFAFAFA) : Colors.white;
              final hasData = d.calories > 0;
              return Container(
                color: bg,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        DateFormat('EEE, MMM d').format(d.date),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasData
                                ? const Color(0xFF1A1A1A)
                                : const Color(0xFFCCCCCC)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        hasData ? d.calories.round().toString() : '—',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: hasData
                                ? const Color(0xFF1A1A1A)
                                : const Color(0xFFCCCCCC)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        hasData ? '${d.protein.round()}g' : '—',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasData
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFCCCCCC)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        hasData ? '${d.carbs.round()}g' : '—',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasData
                                ? const Color(0xFF2196F3)
                                : const Color(0xFFCCCCCC)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        hasData ? '${d.fats.round()}g' : '—',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasData
                                ? const Color(0xFFFF8B00)
                                : const Color(0xFFCCCCCC)),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
