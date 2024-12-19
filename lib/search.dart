import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './widgets/blogcard.dart'; // Import the BlogCard widget.

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _search = TextEditingController();
  List<bool> filters = [
    true,
    true,
    false,
    false
  ]; // Titles, Contents, Users, Tags

  String searchQuery = ''; // To store the search input

  // Method to build Firestore query based on selected filters
  Query<Map<String, dynamic>> getSearchQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('blogs')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (blog, _) => blog,
        );

    // Collect queries based on active filters
    List<Query<Map<String, dynamic>>> queries = [];

    if (filters[0] && searchQuery.isNotEmpty) {
      // Search in titles if "Titles" is selected
      queries.add(
        query
            .where('title', isGreaterThanOrEqualTo: searchQuery)
            .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff'),
      );
    }

    if (filters[1] && searchQuery.isNotEmpty) {
      // Search in contents if "Contents" is selected
      queries.add(
        query
            .where('contents', isGreaterThanOrEqualTo: searchQuery)
            .where('contents', isLessThanOrEqualTo: '$searchQuery\uf8ff'),
      );
    }

    if (filters[2] && searchQuery.isNotEmpty) {
      // Search in username if "Users" is selected
      queries.add(
        query
            .where('username', isGreaterThanOrEqualTo: searchQuery)
            .where('username', isLessThanOrEqualTo: '$searchQuery\uf8ff'),
      );
    }

    if (filters[3] && searchQuery.isNotEmpty) {
      // Search in tags if "Tags" is selected
      queries.add(
        query.where('tags', arrayContains: searchQuery),
      );
    }

    // If no filters are selected or searchQuery is empty, return all queries.
    if (queries.isEmpty) {
      return query;
    }

    // If there are queries, use the first one for simplicity in this example.
    // You can merge them later on the client side if needed.
    return queries[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _search,
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search here...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _search.clear();
                            searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color.fromARGB(255, 230, 244, 255),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
    
            const SizedBox(height: 20),
    
            // Filters (Wrapped in SingleChildScrollView for horizontal scrolling)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ToggleButtons(
                isSelected: filters,
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
                    filters[index] = !filters[index];
                  });
                },
              ),
            ),
    
            const SizedBox(height: 20),
    
            // Search Results
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: getSearchQuery().snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
    
                  return BlogCard(
                    snapshot:
                        snapshot, // Pass the snapshot for the blog card widget
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
