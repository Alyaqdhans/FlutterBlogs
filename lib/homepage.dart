import 'package:blogs/blogs.dart';
import 'package:blogs/profile.dart';
import 'package:blogs/search.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<Widget> pages = [
    const Blogs(),
    const Profile()
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentPage],

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0.0,
        child: SizedBox(
          width: 75,
          height: 75,
          child: FloatingActionButton(
            heroTag: 'search',
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            onPressed: () {
              setState(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const Search();
                  })
                );
              });
            },
            child: const Icon(Icons.search, size: 45),
          ),
        ),
      ),

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(                                           
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.grey[800],

          unselectedItemColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 71, 186, 253),

          // unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          
          currentIndex: currentPage,
          onTap: (value) {
            setState(() {
              currentPage = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon((currentPage == 0 ? Icons.home : Icons.home_outlined), size: 30),
              label: "Home"
            ),
            BottomNavigationBarItem(
              icon: Icon((currentPage == 1 ? Icons.person : Icons.person_outlined), size: 30),
              label: "Profile"
            ),
          ],
        ),
      ),
    );
  }
}