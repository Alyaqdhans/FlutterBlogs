import 'package:blogs/function/message.dart';
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
  Message msg = Message();
  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  String university = "";
  List universities = ["UTAS", "UNizwa", "SQU", "MEC"];

  Future update() async {
    try {
      if (_username.text.trim().isEmpty) throw ErrorHint('Username is empty');

      await FirebaseFirestore.instance.collection('users').add({
        'email': _email.text.trim(),
        'username': _username.text.trim(),
        'birthday': _birthday.text.trim(),
        'university': university,
      });

      msg.success(context, Icons.check, 'Registred successfully!', Colors.green);

      Navigator.pop(context);
    } catch(error) {
      msg.failed(context, Icons.close, error, Colors.red);
    }
  }

  Future reset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _email.text.trim()
      );

      msg.success(context, Icons.email, 'Reset request has been sent!', Colors.orange);

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

  Future logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      msg.success(context, Icons.logout, 'Logged out successfully!', Colors.orange);

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

  @override
  Widget build(BuildContext context) {
    // check if user logged in or not
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
                          } else {
                            setState(() {
                              _birthday.text = "";
                            });
                          }
                        },
                      ),
                    ),
                
                    const SizedBox(height: 10),
                
                    ListTile(
                      title: DropdownButtonFormField(
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(15),
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
                        child: FloatingActionButton.extended(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          label: const Text(
                              'Update',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                              ),
                            ),
                          onPressed: () {
                            update();
                          },
                        ),
                      ),
                    ),
                
                    const SizedBox(height: 5),
                
                    ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: FloatingActionButton.extended(
                                backgroundColor: Colors.orange[600],
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                label: const Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                    ),
                                  ),
                                onPressed: () async {
                                  final result = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Are you sure you want to reset?'),
                                      content: const Text('You will receive an email on the registered account.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold))
                                        ),

                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Reset', style: TextStyle(fontWeight: FontWeight.bold))
                                        ),
                                      ],
                                    )
                                  );

                                  if (result == true) reset();
                                },
                              ),
                            ),
                          ),
                      
                          const SizedBox(width: 10),
                      
                          Expanded(
                            child: SizedBox(
                              height: 45,
                              child: FloatingActionButton.extended(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                label: const Text(
                                    'Logout',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18
                                    ),
                                  ),
                                onPressed: () async {
                                  final result = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Are you sure you want to logout?'),
                                      content: const Text('You will be logged out from current account.'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold))
                                        ),
                                    
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold))
                                        ),
                                      ],
                                    )
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