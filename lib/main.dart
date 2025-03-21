import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/record_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/record_list_screen.dart';
import 'screens/edit_record_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '気分記録',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false, // デバッグバナーを非表示に
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/record': (context) => RecordScreen(),
        '/settings': (context) => SettingsScreen(),
        '/record_list': (context) => RecordListScreen(),
        '/edit_record': (context) => EditRecordScreen(),
      },
    );
  }
}
