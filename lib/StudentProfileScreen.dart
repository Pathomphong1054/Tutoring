import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentProfileScreen extends StatefulWidget {
  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  File? _image;
  String? studentName;
  String? studentAddress;
  String? profileImageUrl;

  Future<void> _fetchStudentData() async {
    var url = Uri.parse(
        'http://192.168.207.193/tutoring_app/get_student_profile.php');

    try {
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          studentName = data['name'];
          studentAddress = data['address'];
          profileImageUrl = data['profile_image_url'];
        });
      } else {
        print('Failed to load student profile');
      }
    } catch (e) {
      print('Error fetching student profile: $e');
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    var uri = Uri.parse('http://192.168.207.193/tutoring_app/upload_image.php');
    var request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = json.decode(responseData);

        setState(() {
          profileImageUrl = data['url'];
        });
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      await _uploadImage(_image!);
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Profile'),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : _image != null
                          ? FileImage(_image!)
                          : NetworkImage(
                                  'https://example.com/student_profile.jpg')
                              as ImageProvider,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Name: ${studentName ?? 'Loading...'}',
              style: TextStyle(fontSize: 18),
            ),
            Text(
              'Address: ${studentAddress ?? 'Loading...'}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
