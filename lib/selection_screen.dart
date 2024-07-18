import 'package:apptutor_project/StudentProfileScreen.dart';
import 'package:apptutor_project/TutorProfileScreen.dart';
import 'package:apptutor_project/registration/LoginScreen_student.dart';
import 'package:apptutor_project/registration/LoginScreen_tutor.dart';

import 'package:flutter/material.dart';

class SelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Register as Tutor or Student',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800],
                ),
              ),
            ),
            SizedBox(height: 40),
            _buildOptionCard(
              context,
              'Register as Tutor',
              'images/apptutor.png',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      //builder: (context) => TutorRegistrationScreen()),
                      builder: (context) => LoginScreen()),
                  //builder: (context) => TutorProfileScreen()),
                );
              },
            ),
            SizedBox(height: 20),
            _buildOptionCard(
              context,
              'Register as Student',
              'images/apptutor.png',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      //builder: (context) => StudentRegistrationScreen()),
                      builder: (context) => LoginScreen_student()),
                      //builder: (context) => StudentProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String imagePath,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                imagePath,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
