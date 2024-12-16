import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _search = TextEditingController();
  List<bool> filters = [true, true, false, false];

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
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              SearchBar(
                controller: _search,
                backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 230, 244, 255)),
                leading: const Icon(Icons.search),
                trailing: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _search.text = "";
                      });
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
                hintText: 'Search here...',
                padding: WidgetStateProperty.all(const EdgeInsets.only(left: 20, right: 10)),
              ),

              const SizedBox(height: 20),
              
              ToggleButtons(
                isSelected: filters,
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width / 5,
                  minHeight: 40
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

              const SizedBox(height: 20),

              
              
            ],
          ),
        ),
      ),
    );
  }
}
