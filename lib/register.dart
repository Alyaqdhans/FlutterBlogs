import 'package:blogs/function/dropdowndata.dart';
import 'package:blogs/function/messenger.dart';
import 'package:blogs/main.dart';
import 'package:blogs/widgets/customhero.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  Messenger msg = Messenger();
  DropdownData ddd = DropdownData();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  String? university;
  List? universities;

  bool hidePassword = true;
  bool hideConfirm = true;
  bool passMatch = false;

  bool isLoading = false;
  
  Future register() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_email.text.trim().isEmpty || _password.text.trim().isEmpty) throw 'Email or Password field is empty';
      if (_password.text.trim() != _confirm.text.trim()) throw "Passwords don't match";

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim()
      )
      .then((result) {
        return result.user!.updateDisplayName(_username.text.trim());
      });

      if (_username.text.trim().isEmpty) throw 'Username is empty';

      User? user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'email': _email.text.trim(),
        'username': _username.text.trim(),
        'birthday': _birthday.text,
        'university': university,
        'date': DateTime.now(),
        'active': true,
        'admin': false,
      });

      msg.success(context, Icons.check, 'Registred successfully!', Colors.green);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return const Home();
      }));
    } catch(error) {
      msg.failed(context, Icons.close, error, Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    universities = ddd.getUniversities();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _username.dispose();
    _birthday.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
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
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 20),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Register',
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
                              prefixIcon: const Icon(Icons.lock_outlined),
                              labelText: 'Password',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                passMatch = _password.text.trim() == _confirm.text.trim() && _password.text.trim().isNotEmpty;
                              });
                            },
                          ),
                        ),

                        Align(
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

                    Stack(
                      alignment: AlignmentDirectional.centerEnd,
                      children: [
                        ListTile(
                          title: TextFormField(
                            obscureText: hideConfirm,
                            controller: _confirm,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'Confirm Password',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onChanged: (value) {
                              setState(() {
                                passMatch = _password.text.trim() == _confirm.text.trim() && _password.text.trim().isNotEmpty;
                              });
                            },
                          ),
                        ),

                        Align(
                          alignment: const Alignment(0.85, 0),
                          child: Focus(
                            descendantsAreFocusable: false,
                            canRequestFocus: false,
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  hideConfirm = !hideConfirm;
                                });
                              },
                              icon: Icon((hideConfirm ? Icons.visibility_off : Icons.visibility), color: Colors.blue)
                            ),
                          ),
                        ),

                        Align(
                          alignment: const Alignment(0.65, 0),
                          child: IgnorePointer(
                            child: (passMatch)
                            ? const Icon(Icons.check, color: Colors.green)
                            : const Icon(Icons.close, color: Colors.red),
                          ),
                        ),
                      ]
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
                            initialDate: (_birthday.text.isNotEmpty) ? DateFormat('d/M/y').parse(_birthday.text.toString()) : null,
                            firstDate: DateTime.utc(1900),
                            lastDate: DateTime.now()
                          );
                      
                          if (selected != null) {
                            setState(() {
                              _birthday.text = DateFormat('d/M/y').format(selected).toString();
                            });
                          }
                        },
                      ),
                    ),

                    ListTile(
                      title: DropdownButtonFormField(
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(15),
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
                        child: (isLoading == false ? (
                          FloatingActionButton.extended(
                            heroTag: 'profile',
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            label: const Text(
                                'Register',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20
                                ),
                              ),
                            onPressed: () {
                              register();
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}