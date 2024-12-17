import 'package:blogs/widgets/blogcard.dart';
import 'package:blogs/widgets/errors/haserror.dart';
import 'package:blogs/widgets/errors/isempty.dart';
import 'package:blogs/widgets/errors/loggedonly.dart';
import 'package:blogs/widgets/errors/spinner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Myblogs extends StatefulWidget {
  const Myblogs({super.key});

  @override
  State<Myblogs> createState() => _MyblogsState();
}

class _MyblogsState extends State<Myblogs> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // check if user is logged in
    if (user == null) {
      return const Loggedonly();
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').orderBy('date', descending: true)
        .where('userid', isEqualTo: user!.uid).snapshots(),
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