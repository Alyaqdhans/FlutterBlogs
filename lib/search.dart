import 'package:blogs/widgets/errors/spinner.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './widgets/blogcard.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _search = TextEditingController();
  int selectedFilterIndex = 0; // Track the selected filter index
  String searchQuery = '';

  // Build Firestore query based on selected filters
  Stream<QuerySnapshot<Map<String, dynamic>>> getSearchResults() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('blogs')
      .withConverter<Map<String, dynamic>>(
        fromFirestore: (snapshot, _) => snapshot.data()!,
        toFirestore: (blog, _) => blog,
      );

    switch (selectedFilterIndex) {
      case 0: // Title filter
        query = query
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff');
        break;
      case 1: // Content filter
        query = query
          .where('contents', isGreaterThanOrEqualTo: searchQuery)
          .where('contents', isLessThanOrEqualTo: '$searchQuery\uf8ff');
        break;
      case 2: // Username filter
        query = query
          .where('username', isGreaterThanOrEqualTo: searchQuery)
          .where('username', isLessThanOrEqualTo: '$searchQuery\uf8ff');
        break;
      case 3: // Tags filter
        query = query.where('tags', arrayContains: searchQuery);
        break;
      default:
        return const Stream.empty();
    }

    // Return the final query stream
    return query.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // SearchBar
                SearchBar(
                  controller: _search,
                  leading: const Icon(Icons.search),
                  trailing: [
                    (_search.text.isEmpty)
                    ? const SizedBox()
                    : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _search.clear();
                          searchQuery = '';
                        });
                      },
                    ),
                  ],
                  hintText: 'Search something...',
                  padding: WidgetStateProperty.all(const EdgeInsets.only(left: 20, right: 10)),
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
            
                // Filter Buttons
                ToggleButtons(
                  isSelected: [
                    selectedFilterIndex == 0,
                    selectedFilterIndex == 1,
                    selectedFilterIndex == 2,
                    selectedFilterIndex == 3,
                  ],
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width / 5,
                    minHeight: 40,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  children: const [
                    Text("Titles"),
                    Text("Contents"),
                    Text("Users"),
                    Text("Tags"),
                  ],
                  onPressed: (int index) {
                    setState(() {
                      selectedFilterIndex = index;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: getSearchResults(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Spinner(),
                  );
                }
      
                if (_search.text.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 100,
                            color: Colors.grey,
                          ),
                      
                          Text(
                            'Search to get started',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 40,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    )
                  );
                }
      
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 100,
                            color: Colors.blue,
                          ),
                      
                          Text(
                            'No results were found',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 40,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                    )
                  );
                }
      
                return BlogCard(snapshot: snapshot);
              },
            ),
          ),
        ],
      ),
    );
  }
}
