// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:student_app/LoginPage/Dashboard/Examination.dart';

class AvgPercentageChart extends StatelessWidget {
  final Subject subject;
  final bool isAverage;
  final double averagePercentage;
  final double maxValue = 100.0;

  const AvgPercentageChart({
    super.key,
    required this.subject,
    required this.isAverage,
    this.averagePercentage = 46.7,
  });

  // --- Left Y-axis Titles ---
  Widget _getLeftTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.black54,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    if (value % 25 == 0) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8,
        child: Text(value.toInt().toString(), style: style),
      );
    }
    return const SizedBox.shrink();
  }

  // --- Right Y-axis Titles ---
  Widget _getRightTitles(double value, TitleMeta meta) {
    if (value == maxValue) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8,
        child: const Text(
          "100%",
          style: TextStyle(color: Colors.black54, fontSize: 12),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  BarChartData _mainBarData() {
    final barColor = averagePercentage >= 50
        ? const Color(0xFF4CAF50) // Success green
        : const Color.fromARGB(255, 30, 136, 229); // Deep blue for low average

    return BarChartData(
      alignment: BarChartAlignment.center,
      maxY: maxValue,
      minY: 0,
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.black26, width: 1.2),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) => const FlLine(
          color: Color(0xFFE0E0E0),
          strokeWidth: 0.8,
        ),
        checkToShowHorizontalLine: (value) => value % 25 == 0,
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          axisNameWidget: const Text(
            'Percentage (%)',
            style: TextStyle(color: Color.fromARGB(255, 30, 136, 229), fontSize: 16),
          ),
          axisNameSize: 30,
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: 25,
            getTitlesWidget: _getLeftTitles,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: _getRightTitles,
            reservedSize: 40,
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      barGroups: [
        BarChartGroupData(
          x: 0,
          barRods: [
            BarChartRodData(
              toY: averagePercentage,
              color: barColor,
              width: 45,
              borderRadius: BorderRadius.circular(4),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxValue,
                color: const Color(0xFFF5F5F5),
              ),
            ),
          ],
        ),
      ],
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          HorizontalLine(
            y: averagePercentage,
            color: barColor.withOpacity(0.9),
            strokeWidth: 2,
            dashArray: [8, 4],
            label: HorizontalLineLabel(
              show: true,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              style: TextStyle(
                color: barColor,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              labelResolver: (line) => '${line.y.toStringAsFixed(1)}%',
            ),
          ),
        ],
      ),
      barTouchData: BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.black.withOpacity(0.8),
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            return BarTooltipItem(
              'AVERAGE\n',
              const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13),
              children: [
                TextSpan(
                  text: '${rod.toY.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final barColor = averagePercentage >= 50
        ? const Color(0xFF4CAF50)
        : const Color(0xFF1E88E5);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'OVERALL PERFORMANCE',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.4,
          ),
        ),
        backgroundColor:  Color(0xFF1565C0),
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Gradient Header
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  "AVERAGE PERCENTAGE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Bar Chart
            Expanded(
              child: BarChart(_mainBarData()),
            ),

            const SizedBox(height: 20),

            // Legend Section
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(barColor, "Average Score"),
                const SizedBox(width: 20),
                _buildLegendItem(Colors.grey.shade300, "100% Scale",
                    borderColor: Colors.grey.shade500),
              ],
            ),

            const SizedBox(height: 25),

            // Back Button or Action Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              label: const Text(
                "Back",
                style: TextStyle(
                    fontWeight: FontWeight.w600, letterSpacing: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, {Color? borderColor}) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: borderColor != null
                ? Border.all(color: borderColor, width: 0.7)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ],
    );
  }
}
