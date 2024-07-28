import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  final String currentUser;
  final String recipient;
  final String recipientImage;
  final String currentUserImage;

  const ChatScreen({
    required this.currentUser,
    required this.recipient,
    required this.recipientImage,
    required this.currentUserImage,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.5.50.84/tutoring_app/fetch_chat.php?sender=${widget.currentUser}&recipient=${widget.recipient}'));
      if (response.statusCode == 200) {
        List<dynamic> messages = json.decode(response.body);
        setState(() {
          _messages = messages.cast<Map<String, dynamic>>();
        });
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load messages: $e')),
      );
    }
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      final response = await http.post(
        Uri.parse('http://10.5.50.84/tutoring_app/send_message.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender': widget.currentUser,
          'recipient': widget.recipient,
          'message': message,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _messages.add({
            'sender': widget.currentUser,
            'recipient': widget.recipient,
            'message': message,
          });
          _controller.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.recipient}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                bool isCurrentUser = message['sender'] == widget.currentUser;
                return ListTile(
                  leading: isCurrentUser
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(widget.currentUserImage),
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(widget.recipientImage),
                        ),
                  title: Text(
                    message['message'],
                    textAlign: isCurrentUser ? TextAlign.end : TextAlign.start,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
