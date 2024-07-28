// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'TutorProfileScreen.dart';

// class TutorsBySubjectScreen extends StatefulWidget {
//   final String subject;

//   const TutorsBySubjectScreen({Key? key, required this.subject}) : super(key: key);

//   @override
//   _TutorsBySubjectScreenState createState() => _TutorsBySubjectScreenState();
// }

// class _TutorsBySubjectScreenState extends State<TutorsBySubjectScreen> {
//   List<dynamic> tutors = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchTutorsBySubject();
//   }

//   Future<void> _fetchTutorsBySubject() async {
//     setState(() {
//       isLoading = true;
//     });

//     var url = Uri.parse(
//         'http://10.5.50.84/tutoring_app/fetch_tutors_by_subject.php?subject=${widget.subject}');
//     try {
//       var response = await http.get(url);

//       if (response.statusCode == 200) {
//         var data = json.decode(response.body);
//         setState(() {
//           tutors = data['tutors'];
//         });
//       } else {
//         _showErrorSnackBar('Failed to load tutors');
//       }
//     } catch (e) {
//       _showErrorSnackBar('An error occurred while fetching tutors');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text(message)));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Tutors for ${widget.subject}'),
//         backgroundColor: Colors.blue[800],
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: tutors.length,
//               itemBuilder: (context, index) {
//                 final tutor = tutors[index];
//                 final name = tutor['name'] ?? 'No Name';
//                 final category = tutor['category'] ?? 'No Category';
//                 final subject = tutor['subject'] ?? 'No Subject';
//                 final profileImageUrl = tutor['profile_images'] != null &&
//                         tutor['profile_images'].isNotEmpty
//                     ? 'http://10.5.50.84/tutoring_app/uploads/' +
//                         tutor['profile_images']
//                     : 'images/default_profile.jpg';
//                 final username = tutor['name'] ?? 'No Username';

//                 return GestureDetector(
//                   onTap: () {
//                     print("Navigating to profile of user: $username");

//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => TutorProfileScreen(
//                           userName: username,
//                           userRole: 'Tutor',
//                           canEdit: false,
//                         ),
//                       ),
//                     );
//                   },
//                   child: Card(
//                     color: Colors.white.withOpacity(0.8),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: profileImageUrl.contains('http')
//                             ? NetworkImage(profileImageUrl)
//                             : AssetImage(profileImageUrl) as ImageProvider,
//                       ),
//                       title: Text(name,
//                           style: TextStyle(color: Colors.black, fontSize: 18)),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Subjects: $subject',
//                               style:
//                                   TextStyle(color: Colors.black, fontSize: 16)),
//                           Text('Category: $category',
//                               style:
//                                   TextStyle(color: Colors.black, fontSize: 16)),
//                         ],
//                       ),
//                       trailing: Icon(Icons.star, color: Colors.yellow),
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
