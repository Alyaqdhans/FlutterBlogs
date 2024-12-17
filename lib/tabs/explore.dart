import 'package:blogs/widgets/blogcard.dart';
import 'package:blogs/widgets/errors/haserror.dart';
import 'package:blogs/widgets/errors/isempty.dart';
import 'package:blogs/widgets/errors/spinner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Spinner();
          }
          
          if (snapshot.hasError) {
            return const Haserror();
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Isempty();
          }

          return BlogCard(snapshot: snapshot);
        }
      ),
    );
  }
}
