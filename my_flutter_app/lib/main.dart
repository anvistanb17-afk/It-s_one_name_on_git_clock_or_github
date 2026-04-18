import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Инициализация Supabase с вашими учетными данными
  await Supabase.initialize(
    url: 'https://pwkwpiznnuoyktzgrcce.supabase.co',
    anonKey:
        'sb_publishable_F-Ba1Eo1lzmmWdQxS4EGnA_qSBQcEwi',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Админка чата',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AdminChatScreen(),
    );
  }
}

class AdminChatScreen extends StatefulWidget {
  const AdminChatScreen({super.key});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _subscribeToRealtimeMessages();
  }

  // Функция для разовой загрузки всех сообщений
  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Запрос к таблице 'messages'. 
      // Если ваша таблица называется иначе, замените 'messages' на нужное имя.
      final data = await supabase
          .from('messages')
          .select('*, profiles(*)') // Пример: если есть связь с профилями
          .order('created_at', ascending: true);

      setState(() {
        _messages = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Подписка на новые сообщения в реальном времени
  void _subscribeToRealtimeMessages() {
    supabase
        .channel('public:messages') // Уникальное имя канала
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          callback: (payload) {
            setState(() {
              _messages.add(payload.newRecord);
            });
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Админ-панель: Все сообщения'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMessages,
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text('Ошибка загрузки: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchMessages,
                child: const Text('Попробовать снова'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(child: Text('Сообщений пока нет.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        // Адаптируйте поля под структуру вашей таблицы (например, 'content', 'created_at')
        final content = message['content'] ?? 'Без текста';
        final createdAt = message['created_at'] ?? '';
        final userId = message['user_id'] ?? 'Аноним';

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            title: Text(content),
            subtitle: Text('User ID: $userId'),
            trailing: Text(
              _formatTimestamp(createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  // Простой форматер для timestamp (можно использовать intl)
  String _formatTimestamp(String timestamp) {
    if (timestamp.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
    } catch (e) {
      return '';
    }
  }
}
