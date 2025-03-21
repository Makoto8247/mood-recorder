import 'package:flutter/material.dart';
import '../models/mood_record.dart';
import '../services/database_helper.dart';

class EditRecordScreen extends StatefulWidget {
  @override
  _EditRecordScreenState createState() => _EditRecordScreenState();
}

class _EditRecordScreenState extends State<EditRecordScreen> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _mood;
  String? _selectedCategory;
  late TextEditingController _diaryController;
  late MoodRecord _record;
  bool _initialized = false; // 初期化フラグを追加

  @override
  void initState() {
    super.initState();
    _diaryController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // 初回のみ初期化を実行
      _record = ModalRoute.of(context)!.settings.arguments as MoodRecord;
      _selectedDate = _record.date;
      _selectedTime = TimeOfDay.fromDateTime(_record.date);
      _mood = _record.mood;
      _selectedCategory = _record.category;
      _diaryController.text = _record.diary ?? '';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('記録を編集'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: DatabaseHelper.instance.getCategories(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                      '日付: ${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
                ListTile(
                  title: Text('時刻: ${_selectedTime.format(context)}'),
                  trailing: Icon(Icons.access_time),
                  onTap: _selectTime,
                ),
                Text('気分: ${_mood}点', style: TextStyle(fontSize: 18)),
                Slider(
                  value: _mood.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  onChanged: (value) => setState(() => _mood = value.round()),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: Text('カテゴリを選択'),
                  items: snapshot.data!.map((category) {
                    return DropdownMenuItem(
                        value: category, child: Text(category));
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedCategory = value),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _diaryController,
                  decoration: InputDecoration(
                    labelText: 'ひとこと（任意）',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _updateRecord,
                  child: Text('更新'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _updateRecord() async {
    if (_selectedCategory == null) return;

    final updatedRecord = MoodRecord(
      id: _record.id,
      date: _selectedDate,
      mood: _mood,
      category: _selectedCategory!,
      diary: _diaryController.text.isEmpty ? null : _diaryController.text,
    );

    await DatabaseHelper.instance.updateMoodRecord(updatedRecord);
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('確認'),
        content: Text('この記録を削除してもよろしいですか？'),
        actions: [
          TextButton(
            child: Text('キャンセル'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('削除'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteMoodRecord(_record.id!);
      Navigator.pop(context);
    }
  }
}
