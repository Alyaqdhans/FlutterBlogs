import 'package:blogs/register.dart';
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          const ClipRRect(
            borderRadius: BorderRadius.only(                                           
              bottomLeft: Radius.circular(75),
              bottomRight: Radius.circular(75),
            ),
            child: Image(
              image: AssetImage("assets/media.png"),
              opacity: AlwaysStoppedAnimation(0.5)
            )
          ),

          const SizedBox(height: 30),
          
          Container(
            padding: const EdgeInsets.all(20),
            child: Card(
              surfaceTintColor: Colors.grey,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        'Explore the app?',
                        style: TextStyle(
                          color: Colors.grey[800],
                        ),
                      ),
                    ),

                    ListTile(
                      title: Container(
                        height: 45,
                        child: FloatingActionButton.extended(
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
                          onPressed: () {},
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Divider(
                      color: Colors.grey[800],
                      thickness: 3,
                    ),

                    const SizedBox(height: 15),

                    ListTile(
                      title: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontWeight: FontWeight.bold,
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
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'Password',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),

                        Container(
                          alignment: const Alignment(0.85, 0),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility)
                          ),
                        ),
                      ]
                    ),
                    
                    ListTile(
                      title: SizedBox(
                        height: 40,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            ),
                          ),
                          onPressed: () {},
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
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.blue,
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