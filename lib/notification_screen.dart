import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final response = await http.get(
        Uri.parse('http://10.5.50.84/tutoring_app/fetch_notifications.php'));
    if (response.statusCode == 200) {
      List<dynamic> notificationsData = json.decode(response.body);
      setState(() {
        notifications = notificationsData.cast<Map<String, dynamic>>();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notifications')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return ListTile(
            leading: Icon(Icons.notifications_active, color: Colors.orange),
            title: Text(notification['title']),
            subtitle: Text(notification['message']),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              // Handle tap event
            },
          );
        },
      ),
    );
  }
}
