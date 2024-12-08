import 'package:blogs/admin.dart';
import 'package:blogs/create.dart';
import 'package:blogs/function/library.dart';
import 'package:blogs/tabs/favorites.dart';
import 'package:blogs/tabs/explore.dart';
import 'package:blogs/tabs/myblogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Blogs extends StatefulWidget {
  const Blogs({super.key});

  @override
  State<Blogs> createState() => _BlogsState();
}

class _BlogsState extends State<Blogs> {
  CustomLibrary msg = CustomLibrary();
  User? user = FirebaseAuth.instance.currentUser;
  bool? isAdmin;

  Future _isAdmin() async {
    if (user == null) return;
    
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    setState(() {
      isAdmin = userDoc.data()?['admin'];
    });
  }

  @override
  void initState() {
    super.initState();
    _isAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: (isAdmin == false) ? 1 : 0,
      length: (isAdmin == false) ? 3 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blogs'),
          centerTitle: true,
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          bottom: TabBar(
            indicatorWeight: 6,
            // indicatorColor: Color.fromARGB(255, 71, 186, 253),

            labelColor: const Color.fromARGB(255, 71, 186, 253),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.8),

            unselectedLabelColor: Colors.white,
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            
            tabs: (isAdmin == false)
            ? [
                const Tab(text: 'My Blogs', icon: Icon(Icons.library_books)),
                const Tab(text: 'Explore', icon: Icon(Icons.public)),
                const Tab(text: 'Favorites', icon: Icon(Icons.star)),
              ]
            : [
                const Tab(text: 'Explore', icon: Icon(Icons.public)),
              ],
          ),
        ),
      
        body: TabBarView(
          children: (isAdmin == false)
          ? [
              const Myblogs(),
              const Explore(),
              const Favorites(),
            ]
          : [
              const Explore(),
            ],
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Container(
          margin: const EdgeInsets.only(
            right: 10,
            bottom: 10,
          ),
          width: 60,
          height: 60,
          child: (user != null)
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      if (isAdmin == false) {return const Create();}
                      else {return const Admin();}
                    })
                  );
                });
              },
              child: (isAdmin == null)
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : Icon((isAdmin == false ? Icons.add : Icons.dashboard), size: 35)
            )
          : FloatingActionButton(
              backgroundColor: Colors.blue.withOpacity(0.5),
              onPressed: () {
                msg.success(context, Icons.info_outline, 'You need to be logged in', Colors.blue[700]);
              },
              child: const Icon(Icons.add, size: 35),
            ),
        ),
      ),
    );
  }
}