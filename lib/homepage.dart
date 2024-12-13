import 'package:blogs/blogs.dart';
import 'package:blogs/profile.dart';
import 'package:blogs/search.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        children: const [
          Blogs(),
          Profile()
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Visibility( // hides search button when mobile keyboard appears
        visible: MediaQuery.of(context).viewInsets.bottom == 0,
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
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(40)
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.grey[800],
        
          unselectedItemColor: Colors.white,
          selectedItemColor: const Color.fromARGB(255, 71, 186, 253),
        
          // unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              _tabController.animateTo(index);
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon((_selectedIndex == 0 ? Icons.home : Icons.home_outlined), size: 30),
              label: "Home"
            ),
            BottomNavigationBarItem(
              icon: Icon((_selectedIndex == 1 ? Icons.person : Icons.person_outlined), size: 30),
              label: "Profile"
            ),
          ],
        ),
      ),
    );
  }
}