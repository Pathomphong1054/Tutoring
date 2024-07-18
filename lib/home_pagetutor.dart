import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'TutorProfileScreen.dart';
import 'chat_screen.dart';
import 'notification_screen.dart';
import 'selection_screen.dart';

class HomePage2 extends StatefulWidget {
  final String userName;

  const HomePage2({Key? key, required this.userName}) : super(key: key);

  @override
  _HomePage2State createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  List<dynamic> tutors = [];

  @override
  void initState() {
    super.initState();
    _fetchTutors();
  }

  Future<void> _fetchTutors() async {
    var url = Uri.parse('http://192.168.207.193/tutoring_app/fetch_tutors.php');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        tutors = data['tutors'];
      });
    } else {
      print('Failed to load tutors');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blue[800],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: widget.userName.isNotEmpty
                  ? Text(widget.userName)
                  : Text('User'), // แสดงชื่อผู้ใช้
              currentAccountPicture: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TutorProfileScreen(userName: widget.userName)),
                  );
                },
                child: CircleAvatar(
                  backgroundImage:
                      NetworkImage('https://example.com/apptutor.png'),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue[800],
              ),
              accountEmail: null,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Handle Settings tap
              },
            ),
            ListTile(
              leading: Icon(Icons.class_),
              title: Text('My Class'),
              onTap: () {
                // Handle My Class tap
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Log Out'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectionScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[200]!,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search TextField
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  hintText: 'Search by name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              // Subject Categories
              Text(
                'Subject Categories',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              SizedBox(height: 10),
              // Horizontal Scroll of Category Icons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryIcon(Icons.book, 'Thai language', Colors.red),
                    _buildCategoryIcon(Icons.language, 'English', Colors.green),
                    _buildCategoryIcon(Icons.calculate, 'Math', Colors.blue),
                    _buildCategoryIcon(Icons.science, 'Physics', Colors.orange),
                    _buildCategoryIcon(
                        Icons.biotech, 'Chemistry', Colors.purple),
                    _buildCategoryIcon(Icons.eco, 'Biology', Colors.brown),
                    _buildCategoryIcon(Icons.space_bar, 'Science', Colors.cyan),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Recommended Tutors
              Text(
                'Recommended Tutors',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              SizedBox(height: 10),
              // ListView of Tutor Cards
              Expanded(
                child: ListView.builder(
                  itemCount: tutors.length,
                  itemBuilder: (context, index) {
                    return _buildTutorCard(
                      tutors[index]['name'] ?? 'No Name',
                      tutors[index]['subject'] ?? 'No Subject',
                      tutors[index]['profile_images'] ??
                          'https://example.com/apptutor.png',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blue),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.green),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Colors.red),
            label: 'Notifications',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Handle Home tap
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, size: 40, color: color),
            radius: 40,
          ),
          SizedBox(height: 5),
          Text(label,
              style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
        ],
      ),
    );
  }

  Widget _buildTutorCard(String name, String subjects, String imageUrl) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
        ),
        title: Text(name,
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
        subtitle: Text('Subjects: $subjects',
            style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0))),
        trailing: Icon(Icons.star, color: Colors.yellow),
      ),
    );
  }
}
