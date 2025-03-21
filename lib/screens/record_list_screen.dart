import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mood_record.dart';
import '../services/database_helper.dart';

class RecordListScreen extends StatefulWidget {
  const RecordListScreen({super.key});

  @override
  _RecordListScreenState createState() => _RecordListScreenState();
}

class _RecordListScreenState extends State<RecordListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('記録一覧')),
      body: FutureBuilder<List<MoodRecord>>(
        future: DatabaseHelper.instance.getMoodRecordsForEdit(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final record = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    DateFormat('yyyy/MM/dd HH:mm').format(record.date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('気分: ${record.mood}点'),
                      Text('カテゴリ: ${record.category}'),
                      if (record.diary != null) Text('メモ: ${record.diary}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/edit_record',
                      arguments: record,
                    ).then((_) => setState(() {})),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
