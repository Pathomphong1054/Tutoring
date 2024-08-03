import 'package:apptutor_project/home_pagetutor.dart';
import 'package:apptutor_project/registration/student_registration_screen.dart';
import 'package:apptutor_project/registration/students_password_reset_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreenStudent extends StatefulWidget {
  @override
  _LoginScreenStudentState createState() => _LoginScreenStudentState();
}

class _LoginScreenStudentState extends State<LoginScreenStudent> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> login(BuildContext context) async {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://192.168.92.173/tutoring_app/loginstudent.php'),
      body: {
        'email': email,
        'password': password,
      },
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'success') {
        final String userName = responseData['name'];
        final String userRole = responseData['role'];
        final String profileImageUrl = responseData['profile_image'] != null
            ? 'http://192.168.92.173/tutoring_app/uploads/' +
                responseData['profile_image']
            : 'images/default_profile.jpg';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage2(
              userName: userName,
              userRole: userRole,
              profileImageUrl: profileImageUrl,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Server error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Login'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/background.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Center(
                        child: Image.asset(
                          'images/apptutor.png',
                          height: 150,
                          width: 150,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Login to your account:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () => login(context),
                                child: Text('Login'),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    StudentRegistrationScreen(),
                              ),
                            );
                          },
                          child: Text('Don\'t have an account? Register here'),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UpdatePasswordScreen (userRole: 'student'),
                              ),
                            );
                          },
                          child: Text('Forgot Password? Reset here'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
