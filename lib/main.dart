import 'package:blogs/homepage.dart';
import 'package:blogs/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "assets/.env");
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

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.grey[800], // Status bar color
      statusBarIconBrightness: Brightness.light, // Status bar icon color
      systemNavigationBarColor: Colors.grey[800], // Navigation bar color
      systemNavigationBarIconBrightness: Brightness.light, // Navigation bar icon color
    ),
  );

  runApp(MaterialApp(
    home: const Home(),
    theme: ThemeData(
      useMaterial3: true,
      
      colorScheme: const ColorScheme.light(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))
      )
    ),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Login();
    } else {
      return const Homepage();
    }
  }
}