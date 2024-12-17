import 'package:blogs/widgets/blogcard.dart';
import 'package:blogs/widgets/errors/haserror.dart';
import 'package:blogs/widgets/errors/isempty.dart';
import 'package:blogs/widgets/errors/loggedonly.dart';
import 'package:blogs/widgets/errors/spinner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  User? user = FirebaseAuth.instance.currentUser;
  List userBlogs = [];

  Future userData() async {
    if (!mounted) return; // if page is closed
    if (user == null) return;

    QuerySnapshot<Map<String, dynamic>>? userDoc;

    userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('blogs').get();
    
    if (mounted) {
      setState(() {
        userBlogs = userDoc!.docs.map((doc) => doc.id).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    userData();
  }

  @override
  Widget build(BuildContext context) {
    // check if user is logged in
    if (user == null) {
      return const Loggedonly();
    }

    if (userBlogs.isEmpty) {
      return Container(
        color: Colors.grey[200],
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.heart_broken_outlined,
                  color: Colors.blue,
                  size: 70,
                ),
                
                Text(
                  "You didn't favorite anything yet",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs')
        .where(FieldPath.documentId, whereIn: userBlogs).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Spinner();
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