import 'package:blogs/function/library.dart';
import 'package:blogs/register.dart';
import 'package:blogs/widgets/heroform.dart';
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
  final TextEditingController _password = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  String? university;
  List universities = ["UTAS", "UNizwa", "SQU", "MEC"];

  bool hidePassword = true;

  bool isLoading = false;
  bool isResetting = false;
  bool isSigningout = false;

  Future login() async {
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim()
      );

      msg.success(context, Icons.check, 'Logged in successfully!', Colors.green);

      setState(() {
        user = FirebaseAuth.instance.currentUser;
      });
    } catch(error) {
      msg.failed(context, Icons.close, error, Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future update() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_username.text.trim().isEmpty) throw ErrorHint('Username is empty');

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        // 'email': _email.text.trim(),
        'username': _username.text.trim(),
        'birthday': _birthday.text.trim(),
        'university': university,
      });

      await user?.updateDisplayName(_username.text.trim());

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

      msg.success(context, Icons.info_outline, 'You might need to wait up to 2 minutes', Colors.blue[700]);
    } catch(error) {
      msg.failed(context, Icons.close, error, Colors.red);
    }
  }

  Future logout() async {
    setState(() {
      isSigningout = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      await FirebaseAuth.instance.signOut();
      
      setState(() {
        user = null;
      });
    } catch(error) {
      msg.failed(context, Icons.close, error, Colors.red);
    } finally {
      setState(() {
        isSigningout = false;
        _password.text = "";
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _username.dispose();
    _birthday.dispose();
    super.dispose();
  }

  // moved method and values outside builder so it only run once
  late Future userFuture;
  Future _userData() async {
    DocumentSnapshot<Map<String, dynamic>>? userDoc;

    try {
      // trying to get it from cache first
      userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get(const GetOptions(source: Source.cache));
    } catch(error) {
      userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get(const GetOptions(source: Source.server));
    }

    if (userDoc.data()!.isNotEmpty) {
      _email.text = userDoc.data()!['email'];
      _username.text = userDoc.data()!['username'];
      _birthday.text = userDoc.data()!['birthday'];
      university = userDoc.data()!['university'];
    }
  }

  @override
  void initState() {
    super.initState();

    if (!mounted) return; // if page is closed
    if (user == null) {
      userFuture = Future.value(); // An empty future to avoid late initialization error.
      return;
    }
    userFuture = _userData();
  }

  @override
  Widget build(BuildContext context) {
    // when user is in guest account
    if (user == null) {
      return Scaffold(
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
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Login',
                          style: TextStyle(
                            color: Colors.grey[800]
                          ),
                        ),
                      ),

                      ListTile(
                        title: TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email),
                            labelText: 'Email',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onFieldSubmitted: ((value) => login()),
                        ),
                      ),

                      const SizedBox(height: 10),
                      
                      Stack(
                        alignment: AlignmentDirectional.centerEnd,
                        children: [
                          ListTile(
                            title: TextFormField(
                              obscureText: hidePassword,
                              controller: _password,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                labelText: 'Password',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              onFieldSubmitted: ((value) => login()),
                            ),
                          ),

                          Container(
                            alignment: const Alignment(0.85, 0),
                            child: Focus(
                              descendantsAreFocusable: false,
                              canRequestFocus: false,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    hidePassword = !hidePassword;
                                  });
                                },
                                icon: Icon((hidePassword ? Icons.visibility_off : Icons.visibility), color: Colors.blue)
                              ),
                            ),
                          ),
                        ]
                      ),

                      const SizedBox(height: 10),
                      
                      ListTile(
                        title: SizedBox(
                          height: 45,
                          child: (isLoading == false)
                          ? FloatingActionButton.extended(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              label: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20
                                  ),
                                ),
                              onPressed: () {
                                login();
                              },
                            )
                          : FloatingActionButton.extended(
                              backgroundColor: Colors.grey[500],
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              label: const SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(color: Colors.white)
                              ),
                              onPressed: null,
                            ),
                        ),
                      ),
                      
                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            
                            const SizedBox(width: 10),

                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return const Register();
                                  })
                                );
                              },
                            ),
                            
                          ],
                        ),
                      ),
                    ],
                  )
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    // when user is logged in
    return Scaffold(
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

                    FutureBuilder(
                      future: userFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

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
                                child: (isLoading == false)
                                ? FloatingActionButton.extended(
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
                                  )
                                : FloatingActionButton.extended(
                                    backgroundColor: Colors.grey[500],
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    label: const SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(color: Colors.white)
                                    ),
                                    onPressed: null,
                                  ),
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
                                icon: const Icon(Icons.key, color: Colors.orange),
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
                                    Colors.orange[600]
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
                              child: (isSigningout == false)
                              ? FloatingActionButton.extended(
                                  foregroundColor: Colors.red[900],
                                  backgroundColor: const Color.fromARGB(255, 255, 214, 211),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: const BorderSide(color: Colors.red, width: 2)
                                  ),
                                  icon: const Icon(Icons.logout, color: Colors.red),
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
                                      Colors.redAccent
                                    );

                                    if (result == true) logout();
                                  },
                                )
                              : FloatingActionButton.extended(
                                  backgroundColor: Colors.grey[500],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  label: const SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(color: Colors.white)
                                  ),
                                  onPressed: null,
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
    );
  }
}