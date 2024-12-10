import 'package:blogs/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "../.env");
  String? apikey = dotenv.env['API_KEY'];
  String? appId = dotenv.env['APP_ID'];
  String? messagingSenderId = dotenv.env['MESSAGING_SENDER_ID'];
  String? projectId = dotenv.env['PROJECT_ID'];

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: apikey!,
      appId: appId!,
      messagingSenderId: messagingSenderId!,
      projectId: projectId!
    )
  );

  runApp(MaterialApp(
    home: const Home(),
    theme: ThemeData(
      useMaterial3: false,
    ),
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
    return const Login();
  }
}