// import 'package:flutter/material.dart';

// class SubjectsScreen extends StatelessWidget {
//   final String category;
//   final List<Map<String, dynamic>> subjects;

//   const SubjectsScreen(
//       {Key? key, required this.category, required this.subjects})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('$category Subjects'),
//         backgroundColor: Colors.blue[800],
//       ),
//       body: ListView.builder(
//         // itemCount: subjects.length,
//         itemBuilder: (context, index) {
//           final subject = subjects[index];
//           return ListTile(
//             leading: Icon(subject['icon'], color: Colors.blue),
//             title: Text(subject['name']),
//             subtitle: Text(subject['description']),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => SubjectDetailScreen(subject: subject),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class SubjectDetailScreen extends StatelessWidget {
//   final Map<String, dynamic> subject;

//   const SubjectDetailScreen({Key? key, required this.subject})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(subject['name']),
//         backgroundColor: Colors.blue[800],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               subject['description'],
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 20),
//             Text(
//               'Topics to be covered:',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             ...subject['topics'].map<Widget>((topic) => ListTile(
//                   leading: Icon(Icons.check, color: Colors.green),
//                   title: Text(topic),
//                 )),
//           ],
//         ),
//       ),
//     );
//   }
// }
