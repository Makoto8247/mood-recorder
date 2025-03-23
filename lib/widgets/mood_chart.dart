import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/mood_record.dart';

class MoodChart extends StatelessWidget {
  final List<MoodRecord> records;
  static const maxDateRange = 7;

  const MoodChart({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final backgroundBars = [
      LineChartBarData(
        spots: [
          FlSpot(0, 30),
          FlSpot(maxDateRange.toDouble(), 30),
        ],
        isCurved: false,
        color: Colors.transparent,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.red.withOpacity(0.2),
          spotsLine: BarAreaSpotsLine(show: false),
        ),
      ),
      LineChartBarData(
        spots: [
          FlSpot(0, 60),
          FlSpot(maxDateRange.toDouble(), 60),
        ],
        isCurved: false,
        color: Colors.transparent,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.green.withOpacity(0.2),
          cutOffY: 30,
          applyCutOffY: true,
          spotsLine: BarAreaSpotsLine(show: false),
        ),
      ),
      LineChartBarData(
        spots: [
          FlSpot(0, 100),
          FlSpot(maxDateRange.toDouble(), 100),
        ],
        isCurved: false,
        color: Colors.transparent,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.blue.withOpacity(0.2),
          cutOffY: 60,
          applyCutOffY: true,
          spotsLine: BarAreaSpotsLine(show: false),
        ),
      ),
    ];

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        minX: 0,
        maxX: maxDateRange.toDouble(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 1,
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        backgroundColor: Colors.white,
        lineBarsData: [
          ...backgroundBars,
          LineChartBarData(
            spots: records.map((record) {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final recordDate = DateTime(
                record.date.year,
                record.date.month,
                record.date.day,
              );
              final daysAgo = today.difference(recordDate).inDays;
              return FlSpot(
                (maxDateRange - daysAgo).toDouble(),
                record.mood.toDouble(),
              );
            }).toList(),
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
        titlesData: FlTitlesData(
          show: true,
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              reservedSize: 35,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final date = DateTime.now().subtract(
                  Duration(days: (maxDateRange - value).toInt()),
                );
                return Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    DateFormat('M/d').format(date),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey),
        ),
        lineTouchData: const LineTouchData(enabled: true),
        showingTooltipIndicators: [],
      ),
    );
  }
}
