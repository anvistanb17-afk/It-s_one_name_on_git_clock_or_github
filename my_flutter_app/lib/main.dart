import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://pwkwpiznnuoyktzgrcce.supabase.co',
    anonKey: 'sb_publishable_F-Ba1Eo1lzmmWdQxS4EGnA_qSBQcEwi',
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
  }

  Future<void> _fetchMessages() async {
    try {
      final data = await supabase
          .from('messages')
          .select('*')
          .order('created_at', ascending: false)
          .limit(100);

      if (mounted) {
        setState(() {
          _messages = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сообщения'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _fetchMessages();
            },
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
              Text('Ошибка: $_error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchMessages();
                },
                child: const Text('Попробовать снова'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(child: Text('Сообщений пока нет'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final content = message['content'] ?? message['message'] ?? message['text'] ?? 'Без текста';
        final createdAt = message['created_at'] ?? message['timestamp'] ?? '';
        final userId = message['user_id'] ?? message['sender_id'] ?? 'Аноним';

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            title: Text(content),
            subtitle: Text('User: $userId'),
            trailing: createdAt.isNotEmpty
                ? Text(
                    DateTime.tryParse(createdAt)?.toString().substring(11, 16) ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  )
                : null,
          ),
        );
      },
    );
  }
}
