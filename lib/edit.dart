import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Edit extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> blogData;
  final List userData;
  const Edit({super.key, required this.blogData, required this.userData});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  @override
  Widget build(BuildContext context) {
    var userId = widget.userData[0];
    var username = widget.userData[1];

    var id = widget.blogData.id;
    var title = widget.blogData['title'];
    var contents = widget.blogData['contents'].toString();
    var tags = [widget.blogData['tags'][0], widget.blogData['tags'][1], widget.blogData['tags'][2]];
    var date = (widget.blogData['date'] as Timestamp).toDate();
    var isEdited = widget.blogData['isEdited'];
    var lastEdited = (widget.blogData['lastEdited'] as Timestamp).toDate();
    var favorites = widget.blogData['favorites'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Blog'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),

      body: const Column(
        children: [
          Text('Welcome')
        ],
      ),
    );
  }
}