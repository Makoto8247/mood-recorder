class MoodRecord {
  final int? id;
  final DateTime date;
  final int mood;
  final String category;
  final String? diary;

  MoodRecord({
    this.id,
    required this.date,
    required this.mood,
    required this.category,
    this.diary,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mood': mood,
      'category': category,
      'diary': diary,
    };
  }

  factory MoodRecord.fromMap(Map<String, dynamic> map) {
    return MoodRecord(
      id: map['id'],
      date: DateTime.parse(map['date']),
      mood: map['mood'],
      category: map['category'],
      diary: map['diary'],
    );
  }
}
