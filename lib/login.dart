import 'package:blogs/homepage.dart';
import 'package:blogs/widgets/heroform.dart';
import 'package:blogs/widgets/loginform.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {  
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

                    const Loginform(),
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