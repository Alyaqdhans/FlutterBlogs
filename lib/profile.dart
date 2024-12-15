import 'package:blogs/admin.dart';
import 'package:blogs/function/dropdowndata.dart';
import 'package:blogs/function/messenger.dart';
import 'package:blogs/register.dart';
import 'package:blogs/widgets/customhero.dart';
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
  Messenger msg = Messenger();
  DropdownData ddd = DropdownData();
  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  String? university;
  List? universities;
  bool? isAdmin;

  bool hidePassword = true;

  bool isLoading = false;
  bool isResetting = false;
  bool isSigningout = false;

  Future login() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) throw 'Email or Password field is empty';

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim()
      );

      // check if account is disabled
      user = FirebaseAuth.instance.currentUser;
      var userData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      bool isActive = userData.data()!['active'];
      if (isActive == false) {
        await FirebaseAuth.instance.signOut();
        setState(() {
          user = null;
        });
        throw 'Your account is disabled by an administrator';
      }

      setState(() {
        user = FirebaseAuth.instance.currentUser;
      });

      msg.success(context, Icons.check, 'Logged in successfully!', Colors.green);
      getUserData();

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
      if (_username.text.trim().isEmpty) throw 'Username is empty';

      await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
        // 'email': _email.text.trim(),
        'username': _username.text.trim(),
        'birthday': _birthday.text,
        'university': university,
      });

      await user?.updateDisplayName(_username.text.trim());

      // Get user blogs
      QuerySnapshot<Map<String, dynamic>> userBlogs = await FirebaseFirestore.instance.collection('blogs')
        .where('userid', isEqualTo: user!.uid).get();
      // Create a batch instance
      WriteBatch batch = FirebaseFirestore.instance.batch();
      // Add updates to the batch
      for (var doc in userBlogs.docs) {
        DocumentReference docRef = FirebaseFirestore.instance.collection('blogs').doc(doc.id);
        batch.update(docRef, {'username': _username.text.trim()});
      }
      // Commit the batch
      await batch.commit();

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
        isAdmin = null;
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

  // moved stream outside builder so it only run once
  Stream<DocumentSnapshot<Map<String, dynamic>>>? userStream;

  Future getUserData() async {
    if (!mounted) return; // if page is closed
    if (user == null) return;

    // caching stream in variable so it doesnt refresh
    userStream = FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots();
    
    // listen to user data from stream and update them
    userStream!.listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data()!;

        setState(() {
          _email.text = data['email'];
          _username.text = data['username'];
          _birthday.text = data['birthday'];
          university = data['university'];
          isAdmin = data['admin'];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();

    universities = ddd.getUniversities();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    // when user is in guest account
    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.grey[200],

        appBar: AppBar(
          title: const Text('Guest'),
          centerTitle: true,
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
        ),

        body: ListView(
          padding: const EdgeInsets.only(bottom: 50),
          children: [
            const CustomHero(),
            
            Container(
              padding: const EdgeInsets.all(10),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 5),
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
                              heroTag: 'profile',
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
                      
                      const SizedBox(height: 5),

                      ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 15
                                ),
                              ),
                            ),
                            
                            const SizedBox(width: 10),
                      
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                fixedSize: const Size(130, 35),
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
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: (isAdmin == true)
      ? Container(
        margin: const EdgeInsets.only(
          right: 10,
          bottom: 10,
        ),
        width: 60,
        height: 60,
        child: FloatingActionButton(
          heroTag: 'dashboard',
          onPressed: () {
            setState(() {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return const Admin();
                })
              );
            });
          },
          child: const Icon(Icons.dashboard, size: 35)
        ),
      )
      : null,

      body: ListView(
        padding: const EdgeInsets.only(bottom: 50),
        children: [
          const CustomHero(),
          
          Container(
            padding: const EdgeInsets.all(10),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
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
                      builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.data!.data()!.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 10, 0, 30),
                              child: Text('(no user data were found)'),
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
                            
                            ListTile(
                              title: TextFormField(
                                maxLength: 20,
                                controller: _username,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person),
                                  labelText: 'Username',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                              ),
                            ),
                                                
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
                                    initialDate: DateFormat('d/M/y').parse(_birthday.text.toString()),
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
                                                
                            ListTile(
                              title: DropdownButtonFormField(
                                isExpanded: true,
                                borderRadius: BorderRadius.circular(15),
                                value: university,
                                items: universities!.map((e) {
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
                                
                    ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: SizedBox(
                              height: 45,
                              child: FloatingActionButton.extended(
                                foregroundColor: Colors.orange[800],
                                backgroundColor: Colors.orange[100],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: const BorderSide(color: Colors.orange, width: 2)
                                ),
                                // icon: const Icon(Icons.key, color: Colors.orange),
                                label: const Text(
                                    'Reset Password',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.5
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
                      
                          const SizedBox(width: 15),
                      
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                              height: 45,
                              child: (isSigningout == false)
                              ? FloatingActionButton.extended(
                                  foregroundColor: Colors.red[800],
                                  backgroundColor: const Color.fromARGB(255, 255, 214, 211),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: const BorderSide(color: Colors.red, width: 2)
                                  ),
                                  // icon: const Icon(Icons.logout, color: Colors.red),
                                  label: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.5
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