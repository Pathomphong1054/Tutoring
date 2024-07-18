import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.notifications_active, color: Colors.orange),
            title: Text('New message'),
            subtitle: Text('You have a new message from a tutor.'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.notifications_active, color: Colors.orange),
            title: Text('Session reminder'),
            subtitle: Text('Your tutoring session starts in 1 hour.'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
