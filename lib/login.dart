import 'package:blogs/homepage.dart';
import 'package:blogs/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool hidePassword = true;

  Future login() async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim()
      );

      ScaffoldMessenger.of(context).showSnackBar(  
        SnackBar(
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.horizontal,
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: const Row(
            children: [
              Icon(Icons.check, color: Colors.white, size: 30),
              SizedBox(width: 10),
              Text('Logged in successfully!', style: TextStyle(color: Colors.white, fontSize: 18)),
            ],
          ),
        )
      );

      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) {
          return const Homepage();
        })
      );
    } catch(error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.horizontal,
          backgroundColor: Colors.red,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          content: Row(
            children: [
              const Icon(Icons.close, color: Colors.white, size: 30),
              const SizedBox(width: 10),
              Flexible(child: Text(error.toString().replaceAll(RegExp('\\[.+\\]'), '').trim(), style: const TextStyle(color: Colors.white, fontSize: 18))),
            ],
          ),
        )
      );
    }
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
          const Stack(
            alignment: AlignmentDirectional.center,
            children: [
              SizedBox(
                height: 350,
                child: Card(
                  elevation: 5,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(                                           
                      bottomLeft: Radius.circular(75),
                      bottomRight: Radius.circular(75),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(                                           
                      bottomLeft: Radius.circular(75),
                      bottomRight: Radius.circular(75),
                    ),
                    child: Image(
                      image: AssetImage("assets/media.png"),
                      opacity: AlwaysStoppedAnimation(0.4),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              Text(
                'UTAS\n  BLOGS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 75,
                  color: Colors.white,
                  shadows: [
                    // Shadow(color: Colors.white, offset: Offset(14, 14)),
                    Shadow(color: Colors.black, offset: Offset(7, 7)),
                  ]
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
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

                    const SizedBox(height: 20),

                    Divider(
                      color: Colors.grey[600],
                      thickness: 3,
                    ),

                    const SizedBox(height: 15),

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
                    
                    ListTile(
                      title: SizedBox(
                        height: 45,
                        child: FloatingActionButton.extended(
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
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}