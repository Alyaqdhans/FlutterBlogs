import 'package:blogs/function/library.dart';
import 'package:blogs/homepage.dart';
import 'package:blogs/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Loginform extends StatefulWidget {
  const Loginform({super.key});

  @override
  State<Loginform> createState() => _LoginformState();
}

class _LoginformState extends State<Loginform> {
  CustomLibrary msg = CustomLibrary();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool hidePassword = true;

  bool isLoading = false;

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
    return Column(
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
            child: (isLoading == false ? (
              FloatingActionButton.extended(
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
    );
  }
}