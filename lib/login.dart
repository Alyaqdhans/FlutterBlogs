import 'package:blogs/function/library.dart';
import 'package:blogs/homepage.dart';
import 'package:blogs/register.dart';
import 'package:blogs/widgets/heroform.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  CustomLibrary msg = CustomLibrary();
  User? user = FirebaseAuth.instance.currentUser;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool hidePassword = true;

  bool isLoading = false;

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
        throw 'Your account is disabled by an administrator';
      }

      msg.success(context, Icons.check, 'Logged in successfully!', Colors.green);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return const Homepage();
        })
      );
    } catch(error) {
      msg.failed(context, Icons.close, error, Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),

      body: ListView(
        children: [
          const Heroform(),
          
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
                        'Explore',
                        style: TextStyle(
                          color: Colors.grey[800],
                        ),
                      ),
                    ),

                    ListTile(
                      title: SizedBox(
                        height: 45,
                        child: FloatingActionButton.extended(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(color: Colors.grey)
                          ),
                          backgroundColor: Colors.white,
                          icon: Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.grey[800],
                          ),
                          label: Text(
                            'Guest Account',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.grey[800]
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return const Homepage();
                              })
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Divider(
                      color: Colors.grey[300],
                      thickness: 2,
                    ),

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
                              fixedSize: const Size.fromWidth(150),
                              maximumSize: const Size.fromHeight(36)
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}