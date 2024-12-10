import 'package:blogs/create.dart';
import 'package:blogs/function/library.dart';
import 'package:blogs/tabs/favorites.dart';
import 'package:blogs/tabs/explore.dart';
import 'package:blogs/tabs/myblogs.dart';
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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Blogs'),
          centerTitle: true,
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorWeight: 6,
            // indicatorColor: Color.fromARGB(255, 71, 186, 253),

            labelColor: Color.fromARGB(255, 71, 186, 253),
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.8),

            unselectedLabelColor: Colors.white,
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            
            tabs: [
              Tab(text: 'My Blogs', icon: Icon(Icons.library_books)),
              Tab(text: 'Explore', icon: Icon(Icons.public)),
              Tab(text: 'Favorites', icon: Icon(Icons.star)),
            ]
          ),
        ),
      
        body: const TabBarView(
          children: [
            Myblogs(),
            Explore(),
            Favorites(),
          ]
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
                      return const Create();
                    })
                  );
                });
              },
              child: const Icon(Icons.add, size: 35)
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