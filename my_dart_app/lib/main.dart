import 'package:flutter/material.dart';
import 'package:test_notifier/test_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TestNotifier.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Тест уведомлений',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Тест уведомлений')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => TestNotifier.showTestNotification(),
              child: Text('📢 Показать уведомление'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => TestNotifier.showScheduledNotification(
                title: 'Напоминание',
                body: 'Прошло 5 секунд!',
                delaySeconds: 5,
              ),
              child: Text('⏰ Отложить на 5 сек'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => TestNotifier.cancelAll(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('❌ Отменить все'),
            ),
          ],
        ),
      ),
    );
  }
}
