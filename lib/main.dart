import 'package:blogs/homepage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAiavt0nVOycGQRZQiv0faNhHd11DILytg",
      appId: "1:776364872459:android:17a59ab37697c5927ac80e",
      messagingSenderId: "776364872459",
      projectId: "flutterblogs-2f978"
    )
  );

  runApp(const MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return const Homepage();
  }
}