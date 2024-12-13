import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('blogs').orderBy('date', descending: true).snapshots(),
        builder: (context, snapshot) {
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

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(),
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

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 90),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var username = snapshot.data!.docs[index]['user'];
              var title = snapshot.data!.docs[index]['title'];
              var contents = snapshot.data!.docs[index]['contents'];
              var university = snapshot.data!.docs[index]['university'];
              var department = snapshot.data!.docs[index]['department'];
              var course = snapshot.data!.docs[index]['course'];
              var date = snapshot.data!.docs[index]['date'];
              var isEdited = snapshot.data!.docs[index]['isEdited'];
              var lastEdited = snapshot.data!.docs[index]['lastEdited'];
          
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Card(
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  
                            const Icon(Icons.favorite),
                          ],
                        ),
                  
                        subtitle: Column(
                          children: [
                            Divider(
                              color: Colors.grey[300],
                              thickness: 2,
                            ),
                  
                            MarkdownBody(
                              data: contents,
                              fitContent: false
                            ),
                  
                            Text(
                              username,
                            ),
                  
                            Divider(
                              color: Colors.grey[300],
                              thickness: 2,
                            ),
                  
                            
                          ],
                        ),
                        
                      ),
                    ),
                  ),
                ),
                
              );
            },
          );

        }
      ),
    );
  }
}
