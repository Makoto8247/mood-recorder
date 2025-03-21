import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/database_helper.dart';
import '../models/mood_record.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 画面遷移後に再描画するためのキー
  final GlobalKey<State> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('気分記録')),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Text('メニュー',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('トップ'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('記録'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/record')
                    .then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text('記録一覧'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/record_list')
                    .then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('設定'),
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
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          final records = snapshot.data!;
          // 表示範囲の計算
          final now = DateTime.now();
          final oldestDate = records.isEmpty
              ? records.first.date // データがある場合は最古のデータから
              : now.subtract(Duration(days: 7)); // データがない場合は8日前から

          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 100,
                      minX: 0, // 0から始める
                      maxX: 7, // 7日分 (0-7で8日分)
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 20,
                        verticalInterval: 1, // 1日ごとのグリッド線
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
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
                              final date = DateTime.now().subtract(
                                Duration(days: (7 - value).toInt()),
                              );
                              return Padding(
                                padding: EdgeInsets.only(top: 5),
                                child: Text(
                                  DateFormat('M/d').format(date),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
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
                            final daysAgo =
                                DateTime.now().difference(record.date).inDays;
                            return FlSpot(
                              7 - daysAgo.toDouble(), // 7から引くことで右から左へ
                              record.mood.toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: Theme.of(context).primaryColor,
                          barWidth: 3,
                          dotData: FlDotData(show: true),
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
        child: Icon(Icons.add),
      ),
    );
  }
}
