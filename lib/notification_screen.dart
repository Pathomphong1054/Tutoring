import 'package:apptutor_project/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationScreen extends StatefulWidget {
  final String userName;
  final String userRole;

  NotificationScreen({required this.userName, required this.userRole});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool hasNewNotifications = false;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final response = await http.get(Uri.parse(
        'http://192.168.92.173/tutoring_app/fetch_notifications.php?username=${widget.userName}&role=${widget.userRole}'));
    if (response.statusCode == 200) {
      try {
        List<dynamic> notificationsData = json.decode(response.body);
        setState(() {
          notifications = notificationsData.cast<Map<String, dynamic>>();
          hasNewNotifications =
              notifications.any((notification) => notification['is_read'] == 0);
        });
      } catch (e) {
        print('Error parsing JSON: $e');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to parse notifications')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications')),
      );
    }
  }

  Future<void> _updateNotificationStatus(int notificationId) async {
    final response = await http.post(
      Uri.parse('http://192.168.92.173/tutoring_app/update_notification.php'),
      body: {'notification_id': notificationId.toString()},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        setState(() {
          notifications.removeWhere(
              (notification) => notification['id'] == notificationId);
          hasNewNotifications =
              notifications.any((notification) => notification['is_read'] == 0);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update notification status')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update notification status')),
      );
    }
  }

  void _navigateToChatScreen(
      String recipient, String recipientImage, String notificationId) async {
    int parsedNotificationId =
        int.parse(notificationId); // แปลง String เป็น int
    await _updateNotificationStatus(parsedNotificationId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUser: widget.userName,
          recipient: recipient,
          recipientImage: recipientImage,
          currentUserImage: '', // ใส่รูปภาพของผู้ใช้ปัจจุบัน
          sessionId: '', // ใส่ session ID ตามที่ต้องการ
          currentUserRole: widget.userRole,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          if (hasNewNotifications)
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: Icon(Icons.circle, color: Colors.red, size: 12.0),
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: Icon(Icons.notifications_active, color: Colors.orange),
            title: Text(notification['sender']),
            subtitle: Text(notification['message']),
            trailing: Text(notification['timestamp']),
            onTap: () {
              _navigateToChatScreen(
                notification['sender'],
                notification['sender_image'] ?? 'images/default_profile.jpg',
                notification['id'],
              );
            },
          );
        },
      ),
    );
  }
}
