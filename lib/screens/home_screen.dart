import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../models/mood_record.dart';
import '../widgets/mood_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<State> _key = GlobalKey();

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

          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MoodChart(records: snapshot.data!),
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
