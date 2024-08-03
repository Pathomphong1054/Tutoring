import 'package:apptutor_project/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'TutorProfileScreen.dart';
import 'StudentProfileScreen.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final String userName;
  final String userRole;
  final String profileImageUrl;

  const SubjectDetailScreen({
    Key? key,
    required this.subject,
    required this.userName,
    required this.userRole,
    required this.profileImageUrl,
  }) : super(key: key);

  @override
  _SubjectDetailScreenState createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  List<dynamic> tutors = [];
  List<dynamic> messages = [];
  bool isLoading = false;
  final TextEditingController _postController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    _fetchTutorsBySubject();
    _fetchMessages();
  }

  Future<void> _fetchTutorsBySubject() async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(
        'http://192.168.92.173/tutoring_app/fetch_tutors_by_subject.php?subject=${widget.subject['name']}');
    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          tutors = data['tutors'];
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

  Future<void> _postMessage() async {
    String message = _postController.text.trim();
    if (message.isNotEmpty &&
        startDate != null &&
        endDate != null &&
        startTime != null &&
        endTime != null) {
      // Construct the message object
      var messageObject = {
        'message': message,
        'startDate': startDate!.toIso8601String(),
        'endDate': endDate!.toIso8601String(),
        'startTime': startTime!.format(context),
        'endTime': endTime!.format(context),
        'userName': widget.userName,
        'profileImageUrl': widget.profileImageUrl,
        'subject': widget.subject['name'],
      };

      // Print message object for debugging
      print('Posting message: $messageObject');

      // Post message to the database
      var url = Uri.parse('http://192.168.92.173/tutoring_app/post_message.php');
      var response =
          await http.post(url, body: json.encode(messageObject), headers: {
        'Content-Type': 'application/json',
      });

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle successful post
        var responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message posted successfully')),
          );
          // Clear the form
          _postController.clear();
          setState(() {
            startDate = null;
            endDate = null;
            startTime = null;
            endTime = null;
          });
          _fetchMessages(); // Fetch the updated list of messages
        } else {
          _showErrorSnackBar(
              'Failed to post message: ${responseData['message']}');
        }
      } else {
        _showErrorSnackBar('Failed to post message');
      }
    } else {
      _showErrorSnackBar(
          'Message, start date, end date, start time, and end time cannot be empty');
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          startTime = pickedTime;
        } else {
          endTime = pickedTime;
        }
      });
    }
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
          currentUserRole: widget.userRole, // Pass currentUserRole here
        ),
      ),
    );
  }

  void _viewProfile(String userName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (widget.userRole == 'tutor') {
            return StudentProfileScreen(
              userName: userName,
              onProfileUpdated: () {},
            );
          } else {
            return TutorProfileScreen(
              userName: userName,
              userRole: 'tutor',
              canEdit: false,
              currentUser: widget.userName,
              currentUserImage: widget.profileImageUrl,
              onProfileUpdated: () {},
              username: '',
              profileImageUrl: '',
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject['name']),
        backgroundColor: Colors.blue[800],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subject['description'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Post a new message:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextField(
                          controller: _postController,
                          decoration: InputDecoration(
                            hintText: 'Enter your message',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: _postMessage,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          startDate == null
                                              ? 'Select Start Date'
                                              : 'Start Date: ${startDate!.toLocal()}'
                                                  .split(' ')[0],
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.calendar_today),
                                        onPressed: () =>
                                            _selectDate(context, true),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          endDate == null
                                              ? 'Select End Date'
                                              : 'End Date: ${endDate!.toLocal()}'
                                                  .split(' ')[0],
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.calendar_today),
                                        onPressed: () =>
                                            _selectDate(context, false),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          startTime == null
                                              ? 'Select Start Time'
                                              : 'Start Time: ${startTime!.format(context)}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.access_time),
                                        onPressed: () =>
                                            _selectTime(context, true),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          endTime == null
                                              ? 'Select End Time'
                                              : 'End Time: ${endTime!.format(context)}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.access_time),
                                        onPressed: () =>
                                            _selectTime(context, false),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Tutors for ${widget.subject['name']}:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tutors.length,
                      itemBuilder: (context, index) {
                        final tutor = tutors[index];
                        final name = tutor['name'] ?? 'No Name';
                        final category = tutor['category'] ?? 'No Category';
                        final subject = tutor['subject'] ?? 'No Subject';
                        final profileImageUrl =
                            tutor['profile_images'] != null &&
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
                                  currentUser:
                                      widget.userName, // ใช้ค่าจาก widget
                                  currentUserImage: widget.profileImageUrl,
                                  username: '',
                                  profileImageUrl: '', // ใช้ค่าจาก widget
                                ),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white.withOpacity(0.8),
                            child: ListTile(
                              leading: GestureDetector(
                                onTap: () {
                                  _viewProfile(username);
                                },
                                child: CircleAvatar(
                                  backgroundImage:
                                      profileImageUrl.contains('http')
                                          ? NetworkImage(profileImageUrl)
                                          : AssetImage(profileImageUrl)
                                              as ImageProvider,
                                ),
                              ),
                              title: Text(name,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 18)),
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
                  SizedBox(height: 20),
                  Text(
                    'Messages:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final userName = message['userName'] ?? 'Unknown';
                        final userImageUrl =
                            message['profileImageUrl'] != null &&
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

                        return _buildMessageCard(
                          userName,
                          userImageUrl,
                          messageText,
                          startDate,
                          endDate,
                          startTime,
                          endTime,
                          sessionId,
                        );
                      },
                    ),
                  ),
                ],
              ),
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
}
