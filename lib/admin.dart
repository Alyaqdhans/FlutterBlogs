import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.yellow,
                    size: 60,
                  ),
                  
                  Text(
                    'Something went wrong :(',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white
                    ),
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
                child: CircularProgressIndicator(color: Colors.white),
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
                    color: Colors.yellow,
                    size: 60,
                  ),
                  
                  Text(
                    'No data were found',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
            child: ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var id = snapshot.data!.docs[index].id;
                var username = snapshot.data!.docs[index]['username'];
                var email = snapshot.data!.docs[index]['email'];
                var isAdmin = snapshot.data!.docs[index]['admin'];
                
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: ListTile(
                        title: Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                                      
                        subtitle: Text(
                          email,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Admin'),
                            Switch(
                              value: isAdmin,
                              onChanged: (user!.uid == id)
                              ? null
                              : (value) async {
                                  await FirebaseFirestore.instance.collection('users').doc(id).update({'admin': value});
                                },
                            ),
                                      
                            const SizedBox(width: 15),
                                      
                            IconButton(
                              icon: const Icon(Icons.lock_open_outlined),
                              onPressed: () async {
                                
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              
            ),
          );
        },
      ),
      
    );
  }
}