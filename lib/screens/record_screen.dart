import 'package:flutter/material.dart';
import '../models/mood_record.dart';
import '../services/database_helper.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  _RecordScreenState createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  int _mood = 50;
  String? _selectedCategory;
  final _diaryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('気分を記録')),
      body: FutureBuilder<List<String>>(
        future: DatabaseHelper.instance.getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('今の気分は？ ($_mood点)', style: const TextStyle(fontSize: 18)),
                Slider(
                  value: _mood.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) => setState(() => _mood = value.round()),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: const Text('カテゴリを選択'),
                  items: snapshot.data!.map((category) {
                    return DropdownMenuItem(
                        value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _diaryController,
                  decoration: const InputDecoration(
                    labelText: 'ひとこと（任意）',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectedCategory == null ? null : _saveMoodRecord,
                  child: const Text('記録する'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _saveMoodRecord() async {
    final record = MoodRecord(
      date: DateTime.now(),
      mood: _mood,
      category: _selectedCategory!,
      diary: _diaryController.text.isEmpty ? null : _diaryController.text,
    );

    await DatabaseHelper.instance.insertMoodRecord(record);
    Navigator.pop(context);
  }
}
