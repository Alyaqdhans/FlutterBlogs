import 'package:blogs/function/library.dart';
import 'package:blogs/homepage.dart';
import 'package:blogs/widgets/heroform.dart';
import 'package:blogs/widgets/loginform.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  CustomLibrary msg = CustomLibrary();
  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  String? university;
  List universities = ["UTAS", "UNizwa", "SQU", "MEC"];

  bool isLoading = false;

  Future update(id) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_username.text.trim().isEmpty) throw ErrorHint('Username is empty');

      await FirebaseFirestore.instance.collection('users').doc(id).update({
        // 'email': _email.text.trim(),
        'username': _username.text.trim(),
        'birthday': _birthday.text.trim(),
        'university': university,
      });

      msg.success(context, Icons.check, 'Updated successfully!', Colors.green);
    } catch(error) {
      msg.failed(context, Icons.close, error, Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future reset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _email.text.trim()
      );

      msg.success(context, Icons.mail_outline, 'Reset request has been sent!', Colors.orange[700]);
    } catch(error) {
      msg.failed(context, Icons.close, error, Colors.red);
    }
  }

  Future logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      msg.success(context, Icons.logout, 'Logged out successfully!', Colors.redAccent);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return const Homepage();
        })
      );
    } catch(error) {
      msg.failed(context, Icons.close, error, Colors.red);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    _birthday.dispose();
    super.dispose();
  }

  // moved stream and values outside builder so it only run once
  late final Stream<QuerySnapshot> userStream;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userStream = FirebaseFirestore.instance.collection('users')
      .where('email', isEqualTo: user!.email).snapshots();

      userStream.first.then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          _email.text = snapshot.docs[0]['email'];
          _username.text = snapshot.docs[0]['username'];
          _birthday.text = snapshot.docs[0]['birthday'];
          university = snapshot.docs[0]['university'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return (user == null ? Scaffold(
      appBar: AppBar(
        title: const Text('Guest Profile'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),

      body: ListView(
        children: [
          const Heroform(),
          
          Container(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: const Loginform()
              ),
            ),
          ),
        ],
      ),
    ) : Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),

      body: ListView(
        children: [
          const Heroform(),
          
          Container(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Details',
                        style: TextStyle(
                          color: Colors.grey[800]
                        ),
                      ),
                    ),

                    StreamBuilder(
                      stream: userStream,
                      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                              child: Text('(no user data were found)'),
                            ),
                          );
                        }

                        var id = snapshot.data!.docs[0].id;

                        return Column(
                          children: [
                            ListTile(
                              title: TextFormField(
                                readOnly: true,
                                controller: _email,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.email),
                                  labelText: 'Email',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                            
                            ListTile(
                              title: TextFormField(
                                controller: _username,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person),
                                  labelText: 'Username',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ),
                        
                            const SizedBox(height: 10),
                        
                            ListTile(
                              title: TextFormField(
                                readOnly: true,
                                controller: _birthday,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.cake),
                                  labelText: 'Birthday',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                onTap: () async {
                                  DateTime? selected = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime.utc(1900),
                                    lastDate: DateTime.now()
                                  );
                              
                                  if (selected != null) {
                                    setState(() {
                                      _birthday.text = DateFormat('d/M/y').format(selected).toString();
                                    });
                                  }
                                }
                              ),
                            ),
                        
                            const SizedBox(height: 10),
                        
                            ListTile(
                              title: DropdownButtonFormField(
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(15),
                                value: (university != "" ? university : null), // handle if no value found in database
                                items: universities.map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    university = value.toString();
                                  });
                                },
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.badge),
                                  labelText: 'University',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),
                    
                            ListTile(
                              title: SizedBox(
                                height: 45,
                                child: (isLoading == false ? (
                                  FloatingActionButton.extended(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    label: const Text(
                                        'Update',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20
                                        ),
                                      ),
                                    onPressed: () {
                                      update(id);
                                    },
                                  )
                                ) : (
                                  FloatingActionButton.extended(
                                    backgroundColor: Colors.grey[500],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    label: const SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(color: Colors.white)
                                    ),
                                    onPressed: null,
                                  )
                                )),
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                
                    const SizedBox(height: 5),
                
                    ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 45,
                              child: FloatingActionButton.extended(
                                foregroundColor: Colors.orange[900],
                                backgroundColor: Colors.orange[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(color: Colors.orange, width: 2)
                                ),
                                icon: Icon(Icons.key, color: Colors.orange[600]),
                                label: const Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                    ),
                                  ),
                                onPressed: () async {
                                  final result = await msg.showBottomAction(
                                    context,
                                    'Are you sure you want to reset?',
                                    'You will receive an email on the registered account.',
                                    'Reset Password',
                                    Colors.orange[700]
                                  );

                                  if (result == true) reset();
                                },
                              ),
                            ),
                          ),
                      
                          const SizedBox(width: 10),
                      
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 45,
                              child: FloatingActionButton.extended(
                                foregroundColor: Colors.red[900],
                                backgroundColor: const Color.fromARGB(255, 255, 214, 211),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(color: Colors.red, width: 2)
                                ),
                                icon: Icon(Icons.logout, color: Colors.red[600]),
                                label: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                    ),
                                  ),
                                onPressed: () async {
                                  final result = await msg.showBottomAction(
                                    context,
                                    'Are you sure you want to logout?',
                                    'You will be logged out from current account.',
                                    'Logout',
                                    Colors.red
                                  );

                                  if (result == true) logout();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                
                    const SizedBox(height: 20),
                  ],
                )
              ),
            ),
          ),

          const SizedBox(height: 50),
        ],
      ),
    ));
  }
}