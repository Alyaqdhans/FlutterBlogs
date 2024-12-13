import 'package:blogs/create.dart';
import 'package:blogs/function/messenger.dart';
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
  Messenger msg = Messenger();
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
          bottom: TabBar(
            indicatorWeight: 7,
            indicatorColor: const Color.fromARGB(255, 71, 186, 253),

            labelColor: const Color.fromARGB(255, 71, 186, 253),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.7),

            unselectedLabelColor: Colors.grey[300],
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            
            tabs: const [
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
              heroTag: 'create',
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