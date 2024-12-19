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
    if (searchQuery.isEmpty) {
      // If no search query is entered, return an empty stream (no results)
      return const Stream.empty();
    }

    // Firestore query reference
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection('blogs')
        .withConverter<Map<String, dynamic>>(
          fromFirestore: (snapshot, _) => snapshot.data()!,
          toFirestore: (blog, _) => blog,
        );

    // Apply the filter based on the selected filter
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

    // Return the final query stream (filtered based on active filters)
    return query.snapshots();
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
            // SearchBar widget (assuming you have a SearchBar widget)
            SearchBar(
              controller: _search,
              backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(255, 230, 244, 255)),
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _search.clear();
                      searchQuery = '';
                    });
                  },
                ),
              ],
              hintText: 'Search here...',
              padding: WidgetStateProperty.all(
                  const EdgeInsets.only(left: 20, right: 10)),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
            const SizedBox(height: 20),
            // Filter Buttons (Single selection logic)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ToggleButtons(
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
                    selectedFilterIndex = index; // Update selected filter
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            // If search query is empty
            if (searchQuery.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Please enter text to search.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            // Results
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: getSearchResults(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: Icon(
                      Icons.search_off_outlined,
                      size: 60,
                      color: Colors.blue,
                    ));
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child:
                          Text('No results found. Try refining your search.'),
                    );
                  }

                  // Pass the results directly to BlogCard
                  return BlogCard(snapshot: snapshot);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
