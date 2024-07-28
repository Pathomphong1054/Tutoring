import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUser;

  const ChatListScreen({required this.currentUser, required String recipient, required String recipientImage, required String currentUserImage});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.5.50.84/tutoring_app/fetch_conversations.php?user=${widget.currentUser}'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        List<dynamic> conversations = json.decode(response.body);
        print('Conversations: $conversations');
        setState(() {
          _conversations = conversations.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load conversations');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load conversations: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: ListView.builder(
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: conversation['recipient_image'] != null
                  ? NetworkImage(
                      'http://10.5.50.84/tutoring_app/uploads/${conversation['recipient_image']}')
                  : AssetImage('assets/default_profile.jpg') as ImageProvider,
            ),
            title: Text(conversation['conversation_with']),
            subtitle: Text(conversation['last_message'] ?? ''),
            trailing: Text(
              conversation['timestamp'] != null
                  ? _formatTimestamp(conversation['timestamp'])
                  : '',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    currentUser: widget.currentUser,
                    recipient: conversation['recipient_username'],
                    recipientImage: conversation['recipient_image'] != null
                        ? 'http://10.5.50.84/tutoring_app/uploads/${conversation['recipient_image']}'
                        : 'assets/default_profile.jpg',
                    currentUserImage:
                        'path_to_current_user_image', // Add logic to fetch current user image
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    final DateTime dateTime = DateTime.parse(timestamp);
    final DateTime now = DateTime.now();

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return '${dateTime.hour}:${dateTime.minute}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
