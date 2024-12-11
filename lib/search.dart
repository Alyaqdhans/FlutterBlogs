import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'search',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search'),
          centerTitle: true,
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
        ),
      
        body: const Column(
          children: [
            Text('Welcome')
          ],
        ),
      ),
    );
  }
}