import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import '../models/mood_record.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 画面遷移後に再描画するためのキー
  final GlobalKey<State> _key = GlobalKey();
  // グラフの表示期間（日数）
  static const maxDateRange = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('気分記録')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: const Text('メニュー',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('トップ'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('記録'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/record')
                    .then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('記録一覧'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/record_list')
                    .then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('設定'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings')
                    .then((_) => setState(() {}));
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<MoodRecord>>(
        key: _key,
        future: DatabaseHelper.instance.getAllMoodRecords(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data!;

          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      minX: 0, // 0から始める
                      maxX: maxDateRange.toDouble(), // 7日分 (0-7で8日分)
                      gridData: const FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 20,
                        verticalInterval: 1, // 1日ごとのグリッド線
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 20,
                            reservedSize: 35,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              // 日付計算を修正：maxDateRangeから1を引く
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
                      lineBarsData: [
                        LineChartBarData(
                          spots: records.map((record) {
                            final now = DateTime.now();
                            // 日付を00:00:00に揃えて比較
                            final today =
                                DateTime(now.year, now.month, now.day);
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
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/record')
            .then((_) => setState(() {})),
        child: const Icon(Icons.add),
      ),
    );
  }
}
