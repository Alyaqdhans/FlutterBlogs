import 'package:blogs/widgets/blogcard.dart';
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
  String? ref;

  Future getPath(uid) async {
    try {
      var userDoc = FirebaseFirestore.instance.collection('users').doc(uid);
      
      setState(() {
        ref = userDoc.path;
      });
    } catch (e) {
      setState(() {
        ref = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (user == null) return;
    getPath(user!.uid);
  }

  @override
  Widget build(BuildContext context) {
    // check if user is logged in
    if (user == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              color: Colors.blue,
              size: 60,
            ),
            
            Text(
              'For logged in users only',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').orderBy('date', descending: true)
          .where('userRef', isEqualTo: ref).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.blue,
                    size: 60,
                  ),
                  
                  Text(
                    'Something went wrong :(',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    color: Colors.blue,
                    size: 70,
                  ),
                  
                  Text(
                    'No data were found',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return BlogCard(snapshot: snapshot);
        }
      ),
    );
  }
}