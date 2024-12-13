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
        stream: FirebaseFirestore.instance.collection('users').orderBy('date').snapshots(),
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
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
    
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 30),
            itemCount: snapshot.data!.docs.length + 1,
            itemBuilder: (context, index) {
              // Display a info hint to explain controls
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Card(
                    color: Colors.grey[300],
                    shadowColor: Colors.white,
                    elevation: 3,
                    child: ListTile(
                      title: const Text(
                        "Username",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: const Text('Email Address'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.green[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                            ),
                          ),
                    
                          const SizedBox(width: 15),
                    
                          Text(
                            'Disable',
                            style: TextStyle(
                              color: Colors.red[900],
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
    
              var userData = snapshot.data!.docs[index - 1];
    
              var id = userData.id;
              var username = userData['username'];
              var email = userData['email'];
              var isActive = userData['active'];
              var isAdmin = userData['admin'];
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Card(
                  color: Colors.blue[200],
                  shadowColor: Colors.white,
                  elevation: 3,
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
                          Switch(
                            activeColor: Colors.green[800],
                            value: isAdmin,
                            onChanged: (user!.uid == id || !isActive)
                            ? null
                            : (value) async {
                                await FirebaseFirestore.instance.collection('users').doc(id).update({'admin': value});
                              },
                          ),
                          
                          const SizedBox(width: 10),
    
                          IconButton(
                            icon: (isActive)
                            ? const Icon(Icons.lock)
                            : Icon(Icons.lock, color: Colors.red[900]),
                            onPressed: (user!.uid == id || isAdmin)
                            ? null
                            : () async {
                              await FirebaseFirestore.instance.collection('users').doc(id).update({'active': !isActive});
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
            
          );
        },
      ),
      
    );
  }
}