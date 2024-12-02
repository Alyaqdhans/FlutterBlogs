import 'package:blogs/function/message.dart';
import 'package:blogs/widgets/heroform.dart';
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
  Message msg = Message();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _birthday = TextEditingController();
  String university = "";
  List universities = ["UTAS", "UNizwa", "SQU", "MEC"];

  bool hidePassword = true;
  bool hideConfirm = true;

  Future register() async {
    try {
      if (_password.text.trim() != _confirm.text.trim()) throw ErrorHint("Passwords doesn't match");

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim()
      )
      .then((result) {
        return result.user!.updateProfile(
          displayName: _username.text.trim(),
        );
      });

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
                                  hideConfirm = !hideConfirm;
                                });
                              },
                              icon: Icon((hideConfirm ? Icons.visibility_off : Icons.visibility), color: Colors.blue)
                            ),
                          ),
                        ),
                      ]
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
                              'Register',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                              ),
                            ),
                          onPressed: () {
                            register();
                          },
                        ),
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