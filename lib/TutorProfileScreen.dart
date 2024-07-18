import 'package:apptutor_project/TutoringScheduleScreen';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class TutorProfileScreen extends StatefulWidget {
  final String userName; // รับ userName ที่ส่งมาจาก LoginScreen

  const TutorProfileScreen({Key? key, required this.userName})
      : super(key: key);

  @override
  _TutorProfileScreenState createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  File? _profileImage;
  File? _resumeFile;
  String? _name;
  String? _subject;
  String? _email;
  String? _address;
  String? _profileImageUrl;
  String? _resumeImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // ฟังก์ชันเพื่อดึงข้อมูลโปรไฟล์จาก API
  Future<void> _fetchProfileData() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.207.193/tutoring_app/get_tutor_profile.php?username=${widget.userName}'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        setState(() {
          _name = profileData['name'];
          _subject = profileData['subject'];
          _email = profileData['email'];
          _address = profileData['address'];
          _profileImageUrl = profileData['profile_images'];

          print('Name: $_name');
          print('Subject: $_subject');
          print('Email: $_email');
          print('Address: $_address');
        });
      } else {
        _showSnackBar('Failed to load profile data');
      }
    } catch (e) {
      print('Error: $e');
      _showSnackBar('Error: $e');
    }
  }

  // ฟังก์ชันเพื่อแสดงข้อความแจ้งเตือน
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  // ฟังก์ชันเพื่อเลือกภาพจากแกลเลอรี
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      // เรียกฟังก์ชันอัปโหลดรูปภาพ
      await _uploadProfileImage(_profileImage!);
    }
  }

  // ฟังก์ชันเพื่อเลือกไฟล์ Resume จากแกลเลอรี
  Future<void> _pickResume() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _resumeFile = File(pickedFile.path);
      });

      // เรียกฟังก์ชันอัปโหลด Resume
      await _uploadResume(_resumeFile!);
    }
  }

  // ฟังก์ชันสำหรับอัปโหลดรูปภาพโปรไฟล์
  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'http://192.168.207.193/tutoring_app/upload_profile_image.php'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_images',
          imageFile.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);

        String imageUrl = jsonData['image_url'];

        setState(() {
          _profileImageUrl = imageUrl;
        });

        _showSnackBar('Profile image uploaded successfully');
      } else {
        _showSnackBar('Failed to upload profile image');
      }
    } catch (e) {
      print('Error uploading profile image: $e');
      _showSnackBar('Error uploading profile image');
    }
  }

  // ฟังก์ชันสำหรับอัปโหลด Resume
  Future<void> _uploadResume(File resumeFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://192.168.207.193/tutoring_app/upload_resume.php'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'resume_file',
          resumeFile.path,
        ),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);

        String resumeUrl = jsonData['resume_url'];

        setState(() {
          _resumeImageUrl = resumeUrl;
        });

        _showSnackBar('Resume uploaded successfully');
      } else {
        _showSnackBar('Failed to upload resume');
      }
    } catch (e) {
      print('Error uploading resume: $e');
      _showSnackBar('Error uploading resume');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blue[800],
      ),
      body: _name == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      radius: 70,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : (_profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : AssetImage('images/apptutor.png')
                                  as ImageProvider),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: Text('Change Profile Picture'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Name: $_name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Subject: $_subject',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Email: $_email',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Address: $_address',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TutoringScheduleScreen()),
                        );
                      },
                      child: Text('Tutoring'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding:
                            EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resume',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _resumeImageUrl != null
                              ? 'Resume URL: $_resumeImageUrl'
                              : 'Resume URL: No resume uploaded',
                          style: TextStyle(
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _pickResume(),
                          child: Text('Upload Resume'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
