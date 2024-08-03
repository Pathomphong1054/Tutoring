import 'package:apptutor_project/ChatListScreen.dart';
import 'package:apptutor_project/StudentProfileScreen.dart';
import 'package:apptutor_project/SubjectCategoryScreen.dart';
import 'package:apptutor_project/TutorProfileScreen.dart';
import 'package:apptutor_project/chat_screen.dart';
import 'package:apptutor_project/notification_screen.dart';
import 'package:apptutor_project/selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage2 extends StatefulWidget {
  final String userName;
  final String userRole;
  final String profileImageUrl;

  const HomePage2({
    Key? key,
    required this.userName,
    required this.userRole,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  _HomePage2State createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  List<dynamic> tutors = [];
  List<dynamic> filteredTutors = [];
  List<dynamic> messages = [];
  bool isLoading = false;
  String? _profileImageUrl;
  String? _userName;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _profileImageUrl = widget.profileImageUrl;
    if (widget.userRole == 'student') {
      _fetchTutors();
    }
    _fetchProfileImage();
    _fetchMessages();
  }

  Future<void> _fetchTutors() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse('http://192.168.92.173/tutoring_app/fetch_tutors.php');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          tutors = data['tutors'];
          _filterTutors();
        });
      } else {
        _showErrorSnackBar('Failed to load tutors');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while fetching tutors');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterTutors() {
    setState(() {
      filteredTutors = tutors.where((tutor) {
        final name = tutor['name'] ?? '';
        final subject = tutor['subject'] ?? '';
        final category = tutor['category'] ?? '';
        final topic = tutor['topic'] ?? '';
        final query = searchQuery.toLowerCase();
        return name.toLowerCase().contains(query) ||
            subject.toLowerCase().contains(query) ||
            category.toLowerCase().contains(query) ||
            topic.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _fetchProfileImage() async {
    var url = Uri.parse(
        'http://192.168.92.173/tutoring_app/get_user_profile.php?username=${_userName}&role=${widget.userRole}');
    try {
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() {
            _profileImageUrl = data['profile_image'];
            _userName = data['name'];
          });
        } else {
          _showErrorSnackBar(
              'Failed to load profile image: ${data['message']}');
        }
      } else {
        _showErrorSnackBar(
            'Failed to load profile image: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while fetching profile image: $e');
    }
  }

  Future<void> _fetchMessages() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse('http://192.168.92.173/tutoring_app/fetch_messages.php');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          messages = data['messages'];
        });
      } else {
        _showErrorSnackBar('Failed to load messages');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while fetching messages');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _onProfileUpdated() {
    _fetchProfileImage();
  }

  void _viewProfile(String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => widget.userRole == 'student'
            ? TutorProfileScreen(
                userName: userName,
                onProfileUpdated: () {},
                canEdit: false,
                userRole: 'tutor',
                currentUser: widget.userName,
                currentUserImage: widget.profileImageUrl,
                username: '',
                profileImageUrl: '',
              )
            : StudentProfileScreen(
                userName: userName,
                onProfileUpdated: _onProfileUpdated,
              ),
      ),
    );
  }

  void _navigateToChatScreen(
      String recipient, String recipientImage, String sessionId) {
    if (sessionId.isEmpty) {
      print('Error: sessionId is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: sessionId is empty')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          currentUser: widget.userName,
          recipient: recipient,
          recipientImage: recipientImage,
          currentUserImage: widget.profileImageUrl,
          sessionId: sessionId,
          currentUserRole: widget.userRole,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blue[800],
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          _buildSearchField(),
          _buildCommonSection(),
          Expanded(
            child: widget.userRole == 'student'
                ? _buildStudentBody()
                : _buildTutorBody(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: _userName != null && _userName!.isNotEmpty
                ? Text(_userName!, style: TextStyle(fontSize: 20))
                : Text('User', style: TextStyle(fontSize: 20)),
            accountEmail: Text(widget.userRole, style: TextStyle(fontSize: 16)),
            currentAccountPicture: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => widget.userRole == 'student'
                        ? StudentProfileScreen(
                            userName: _userName!,
                            onProfileUpdated: _onProfileUpdated,
                          )
                        : TutorProfileScreen(
                            userName: _userName!,
                            onProfileUpdated: _onProfileUpdated,
                            canEdit: true,
                            userRole: 'tutor',
                            currentUser: widget.userName,
                            currentUserImage: widget.profileImageUrl,
                            username: '',
                            profileImageUrl: '',
                          ),
                  ),
                );
                _onProfileUpdated();
              },
              child: CircleAvatar(
                backgroundImage: _profileImageUrl != null &&
                        _profileImageUrl!.isNotEmpty
                    ? NetworkImage(
                        'http://192.168.92.173/tutoring_app/uploads/$_profileImageUrl')
                    : AssetImage('images/default_profile.jpg') as ImageProvider,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue[800],
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings', style: TextStyle(fontSize: 18)),
            onTap: () {},
          ),
          if (widget.userRole == 'tutor')
            ListTile(
              leading: Icon(Icons.class_),
              title: Text('My Class', style: TextStyle(fontSize: 18)),
              onTap: () {},
            ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Log Out', style: TextStyle(fontSize: 18)),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SelectionScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search, color: Colors.blue),
          hintText: 'Search by name, subject, category, or topic',
          hintStyle: TextStyle(fontSize: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (query) {
          setState(() {
            searchQuery = query;
            _filterTutors();
          });
        },
      ),
    );
  }

  Widget _buildCommonSection() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Subject Categories',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryIcon(Icons.language, 'Language', Colors.red),
              _buildCategoryIcon(Icons.calculate, 'Mathematics', Colors.green),
              _buildCategoryIcon(Icons.science, 'Science', Colors.blue),
              _buildCategoryIcon(
                  Icons.computer, 'Computer Science', Colors.orange),
              _buildCategoryIcon(Icons.business, 'Business', Colors.purple),
              _buildCategoryIcon(Icons.art_track, 'Arts', Colors.pink),
              _buildCategoryIcon(
                  Icons.sports, 'Physical Education', Colors.teal),
            ],
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectCategoryScreen(
              category: label,
              userName: widget.userName,
              userRole: widget.userRole,
              profileImageUrl: widget.profileImageUrl,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, size: 40, color: color),
              radius: 40,
            ),
            SizedBox(height: 5),
            Text(label, style: TextStyle(color: Colors.black, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Recommended Tutors',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : Expanded(
                child: ListView.builder(
                  itemCount: filteredTutors.length,
                  itemBuilder: (context, index) {
                    final tutor = filteredTutors[index];
                    final name = tutor['name'] ?? 'No Name';
                    final category = tutor['category'] ?? 'No Category';
                    final subject = tutor['subject'] ?? 'No Subject';
                    final profileImageUrl = tutor['profile_images'] != null &&
                            tutor['profile_images'].isNotEmpty
                        ? 'http://192.168.92.173/tutoring_app/uploads/' +
                            tutor['profile_images']
                        : 'images/default_profile.jpg';
                    final username = tutor['name'] ?? 'No Username';

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TutorProfileScreen(
                              userName: username,
                              userRole: 'Tutor',
                              canEdit: false,
                              onProfileUpdated: () {},
                              currentUser: widget.userName,
                              currentUserImage: widget.profileImageUrl,
                              username: '',
                              profileImageUrl: '',
                            ),
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.white.withOpacity(0.8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: profileImageUrl.contains('http')
                                ? NetworkImage(profileImageUrl)
                                : AssetImage(profileImageUrl) as ImageProvider,
                          ),
                          title: Text(name,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Subjects: $subject',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16)),
                              Text('Category: $category',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16)),
                            ],
                          ),
                          trailing: Icon(Icons.star, color: Colors.yellow),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildTutorBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Welcome, ${_userName}!',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: Text(
            'You are logged in as a ${widget.userRole}.',
            style: TextStyle(fontSize: 18, color: Colors.blue[800]),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Post Messages',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
        SizedBox(height: 10),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : Expanded(
                child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final userName = message['userName'] ?? '';
                    final userImageUrl = message['profileImageUrl'] != null &&
                            message['profileImageUrl'].isNotEmpty
                        ? 'http://192.168.92.173/tutoring_app/uploads/' +
                            message['profileImageUrl']
                        : 'images/default_profile.jpg';
                    final messageText = message['message'] ?? '';
                    final startDate = message['startDate'] ?? '';
                    final endDate = message['endDate'] ?? '';
                    final startTime = message['startTime'] ?? '';
                    final endTime = message['endTime'] ?? '';
                    final sessionId = message['session_id'] ?? '';

                    return GestureDetector(
                      onTap: () {
                        _viewProfile(userName);
                      },
                      child: _buildMessageCard(
                        userName,
                        userImageUrl,
                        messageText,
                        startDate,
                        endDate,
                        startTime,
                        endTime,
                        sessionId,
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  Widget _buildTutorCard(String name, String subjects, String category,
      String topic, String imageUrl) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: imageUrl.contains('http')
              ? NetworkImage(imageUrl)
              : AssetImage(imageUrl) as ImageProvider,
        ),
        title: Text(name, style: TextStyle(color: Colors.black, fontSize: 18)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subjects: $subjects',
                style: TextStyle(color: Colors.black, fontSize: 16)),
            Text('Category: $category',
                style: TextStyle(color: Colors.black, fontSize: 16)),
            Text('Topic: $topic',
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ],
        ),
        trailing: Icon(Icons.star, color: Colors.yellow),
      ),
    );
  }

  Widget _buildMessageCard(
      String userName,
      String userImageUrl,
      String messageText,
      String startDate,
      String endDate,
      String startTime,
      String endTime,
      String sessionId) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () {
                  _viewProfile(userName);
                },
                child: CircleAvatar(
                  backgroundImage: userImageUrl.contains('http')
                      ? NetworkImage(userImageUrl)
                      : AssetImage(userImageUrl) as ImageProvider,
                  radius: 30,
                ),
              ),
              title: Text(userName,
                  style: TextStyle(color: Colors.black, fontSize: 18)),
              subtitle: Text(messageText,
                  style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.grey),
            SizedBox(height: 8.0),
            Text('Start Date: $startDate',
                style: TextStyle(color: Colors.black, fontSize: 14)),
            Text('End Date: $endDate',
                style: TextStyle(color: Colors.black, fontSize: 14)),
            Text('Start Time: $startTime',
                style: TextStyle(color: Colors.black, fontSize: 14)),
            Text('End Time: $endTime',
                style: TextStyle(color: Colors.black, fontSize: 14)),
            SizedBox(height: 12.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  _navigateToChatScreen(userName, userImageUrl, sessionId);
                },
                icon: Icon(Icons.chat),
                label: Text('Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.blue), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Colors.green), label: 'Chat'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Colors.red),
            label: 'Notifications'),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            // Handle Home tap
            break;
          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatListScreen(
                  currentUser: widget.userName,
                  currentUserImage: '',
                ),
              ),
            );
            break;
          case 2:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationScreen(
                          userName: widget.userName,
                          userRole: widget.userRole,
                        )));
            break;
        }
      },
    );
  }
}
