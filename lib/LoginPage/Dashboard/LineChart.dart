import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformanceLineChart extends StatelessWidget {
  const PerformanceLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 0.5,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 1:
                      return const Text('FA-1',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold));
                    case 2:
                      return const Text('FA-2',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold));
                    case 3:
                      return const Text('FA-3',
                          style: TextStyle(
                              fontSize: 10, fontWeight: FontWeight.bold));
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(1, 75), // FA-1
                FlSpot(2, 25), // FA-2
                FlSpot(3, 40), // FA-3
              ],
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.4),
                    Colors.green.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          minX: 0,
          maxX: 4,
          minY: 0,
          maxY: 100,
        ),
      ),
    );
  }
}
