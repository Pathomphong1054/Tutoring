import 'package:apptutor_project/TutoringScheduleScreen';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class TutorProfileScreen extends StatefulWidget {
  final String userName;
  final String userRole;
  final VoidCallback? onProfileUpdated;
  final bool canEdit;

  const TutorProfileScreen({
    Key? key,
    required this.userName,
    required this.userRole,
    this.onProfileUpdated,
    this.canEdit = false,
  }) : super(key: key);

  @override
  _TutorProfileScreenState createState() => _TutorProfileScreenState();
}

class _TutorProfileScreenState extends State<TutorProfileScreen> {
  File? _profileImage;
  File? _resumeFile;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();
  TextEditingController _subjectController = TextEditingController();
  TextEditingController _topicController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  String? _profileImageUrl;
  String? _resumeImageUrl;
  bool _isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final url = Uri.parse(
        'http://10.5.50.84/tutoring_app/get_tutor_profile.php?username=${widget.userName}',
      );
      print('Fetching profile for username: ${widget.userName}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final profileData = json.decode(response.body);
        print('Profile Data: $profileData');

        if (profileData['status'] == 'success') {
          setState(() {
            _nameController.text = profileData['name'] ?? '';
            _categoryController.text = profileData['category'] ?? '';
            _subjectController.text = profileData['subject'] ?? '';
            _topicController.text = profileData['topic'] ?? '';
            _emailController.text = profileData['email'] ?? '';
            _addressController.text = profileData['address'] ?? '';
            _profileImageUrl = profileData['profile_image'];
            _resumeImageUrl = profileData['resume_image'];
            isLoading = false;
          });
        } else {
          _showSnackBar(
              'Failed to load profile data: ${profileData['message']}');
          setState(() {
            isLoading = false;
          });
        }
      } else {
        _showSnackBar('Failed to load profile data');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      _showSnackBar('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      await _uploadProfileImage(_profileImage!);
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.5.50.84/tutoring_app/upload_profile_image.php'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_images',
          imageFile.path,
        ),
      );
      request.fields['username'] = widget.userName;
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);
        if (jsonData['status'] == "success") {
          String? imageUrl = jsonData['image_url'];
          setState(() {
            _profileImageUrl = imageUrl;
          });
          _showSnackBar('Profile image uploaded successfully');
          widget.onProfileUpdated?.call();
        } else {
          _showSnackBar(
              'Failed to upload profile image: ${jsonData['message']}');
        }
      } else {
        _showSnackBar('Failed to upload profile image');
      }
    } catch (e) {
      _showSnackBar('Error uploading profile image: $e');
    }
  }

  Future<void> _pickResume() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _resumeFile = File(pickedFile.path);
      });
      await _uploadResume(_resumeFile!);
    }
  }

  Future<void> _uploadResume(File resumeFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.5.50.84/tutoring_app/upload_resume.php'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'resumes_images',
          resumeFile.path,
        ),
      );
      request.fields['username'] = widget.userName;
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);
        if (jsonData['status'] == "success") {
          String? resumeUrl = jsonData['resume_url'];
          setState(() {
            _resumeImageUrl = resumeUrl;
          });
          _showSnackBar('Resume uploaded successfully');
        } else {
          _showSnackBar('Failed to upload resume: ${jsonData['message']}');
        }
      } else {
        _showSnackBar('Failed to upload resume');
      }
    } catch (e) {
      _showSnackBar('Error uploading resume: $e');
    }
  }

  Future<void> _updateProfile() async {
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _subjectController.text.isEmpty ||
        _topicController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _addressController.text.isEmpty) {
      _showSnackBar('Please fill in all the fields');
      return;
    }

    final newName = _nameController.text;
    final category = _categoryController.text;
    final subject = _subjectController.text;
    final topic = _topicController.text;
    final email = _emailController.text;
    final address = _addressController.text;

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.5.50.84/tutoring_app/update_tutor_profile.php'),
      );

      if (_profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_images',
            _profileImage!.path,
          ),
        );
      }

      request.fields['username'] = widget.userName;
      request.fields['name'] = newName;
      request.fields['category'] = category;
      request.fields['subject'] = subject;
      request.fields['topic'] = topic;
      request.fields['email'] = email;
      request.fields['address'] = address;

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);
        if (jsonData['status'] == 'success') {
          setState(() {
            _profileImageUrl = jsonData['image_url'];
            _isEditing = false;
          });
          widget.onProfileUpdated?.call();
          _showSnackBar('Profile updated successfully');
        } else {
          _showSnackBar('Failed to update profile: ${jsonData['message']}');
        }
      } else {
        _showSnackBar('Failed to update profile');
      }
    } catch (e) {
      _showSnackBar('Error updating profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutor Profile'),
        backgroundColor: Colors.blue[800],
        actions: widget.canEdit
            ? [
                IconButton(
                  icon: Icon(_isEditing ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (_isEditing) {
                      _updateProfile();
                    } else {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  },
                ),
              ]
            : null,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _nameController.text.isEmpty
              ? Center(child: Text('No profile data available'))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: GestureDetector(
                          onTap: widget.canEdit && _isEditing
                              ? () => _pickImage(ImageSource.gallery)
                              : null,
                          child: CircleAvatar(
                            radius: 70,
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_profileImageUrl != null
                                    ? NetworkImage(
                                        'http://10.5.50.84/tutoring_app/uploads/$_profileImageUrl')
                                    : AssetImage('images/default_profile.jpg')
                                        as ImageProvider),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Icon(
                                Icons.camera_alt,
                                color: widget.canEdit && _isEditing
                                    ? Colors.blue[800]
                                    : Colors.transparent,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TutoringScheduleScreen(
                                    tutorName: widget.userName,
                                    tutorImage: _profileImageUrl ??
                                        'images/default_profile.jpg',
                                  ),
                                ),
                              );
                            },
                            icon: Icon(Icons.schedule),
                            label: Text('Tutoring'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      _buildProfileFieldWithLabel(
                          'Name', _nameController, Icons.person),
                      SizedBox(height: 5),
                      _buildProfileFieldWithLabel(
                          'Category', _categoryController, Icons.category),
                      SizedBox(height: 5),
                      _buildProfileFieldWithLabel(
                          'Subject', _subjectController, Icons.book),
                      SizedBox(height: 5),
                      _buildProfileFieldWithLabel(
                          'Topic', _topicController, Icons.topic),
                      SizedBox(height: 5),
                      _buildProfileFieldWithLabel(
                          'Email', _emailController, Icons.email),
                      SizedBox(height: 5),
                      _buildProfileFieldWithLabel(
                          'Address', _addressController, Icons.location_city),
                      SizedBox(height: 20),
                      _buildResumeSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileFieldWithLabel(
      String label, TextEditingController controller, IconData icon) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: Colors.grey),
              SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.canEdit
                  ? TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: TextStyle(color: Colors.black),
                        prefixStyle: TextStyle(color: Colors.black),
                      ),
                      style: TextStyle(color: Colors.black),
                      enabled: _isEditing,
                    )
                  : _buildProfileInfo(label, controller.text, icon),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResumeSection() {
    return Container(
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
          _resumeImageUrl != null
              ? Image.network(
                  'http://10.5.50.84/tutoring_app/uploads/$_resumeImageUrl')
              : Text(
                  'No resume uploaded',
                  style: TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
          if (widget.canEdit && _isEditing) ...[
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _pickResume(),
              child: Text('Upload Resume'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
