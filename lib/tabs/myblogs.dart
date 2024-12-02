import 'package:flutter/material.dart';

class Myblogs extends StatefulWidget {
  const Myblogs({super.key});

  @override
  State<Myblogs> createState() => _MyblogsState();
}

class _MyblogsState extends State<Myblogs> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          Text('My Blogs')
        ],
      ),
    );
  }
}