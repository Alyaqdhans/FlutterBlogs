import 'package:blogs/widgets/preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class BlogCard extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;
  const BlogCard({super.key, required this.snapshot});

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(30, 20, 30, 90),
      itemCount: widget.snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        var blogData = widget.snapshot.data!.docs[index];
        DocumentReference userRef = blogData['userRef'];

        var id = blogData.id;
        var title = blogData['title'];
        var contents = blogData['contents'].toString();
        var tags = [blogData['tags'][0], blogData['tags'][1], blogData['tags'][2]];
        var date = (blogData['date'] as Timestamp).toDate();
        var isEdited = blogData['isEdited'];
        var lastEdited = (blogData['lastEdited'] as Timestamp).toDate();

        return FutureBuilder<DocumentSnapshot>(
          future: userRef.get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (userSnapshot.hasError) {
              return const Text('Error loading user');
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return const Text('User not found');
            }

            var username = userSnapshot.data!.get('username');

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Card(
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            
                            Row(
                              children: [
                                // Expand Menu
                                PopupMenuButton(
                                  elevation: 7,
                                  tooltip: 'Extra',
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) {
                                    if (value == 'Edit') {
                                      // Handle edit action
                                    } else if (value == 'Delete') {
                                      // Handle delete action
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'Edit',
                                      child: ListTile(
                                        leading: Icon(Icons.edit, color: Colors.blue),
                                        title: Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue
                                          )
                                        ),
                                      ),
                                    ),

                                    const PopupMenuItem(
                                      value: 'Delete',
                                      child: ListTile(
                                        leading: Icon(Icons.delete, color: Colors.red),
                                        title: Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red
                                          )
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // Favorite
                                IconButton(
                                  tooltip: 'Favorite',
                                  onPressed: () {
                                    
                                  },
                                  icon: const Icon(Icons.star_border)
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Preview of Contents
                        MarkdownBody(
                          data: contents.length > 80 ? '${contents.substring(0, 100)}...' : contents,
                        ),

                        const SizedBox(height: 8),

                        // Floating Action Button for Read More
                        Center(
                          child: SizedBox(
                            height: 30,
                            child: FloatingActionButton.extended(
                              foregroundColor: Colors.blue,
                              backgroundColor: Colors.white,
                              heroTag: 'preview',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PreviewMarkdown(contents: contents, tag: id),
                                  ),
                                );
                              },
                              label: const Text('Read More'),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Created and Edited Dates
                        Text(
                          'Created on: ${DateFormat('d/m/y H:M a').format(date)}',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        if (isEdited)
                          Text(
                            'Edited on: ${DateFormat('d/m/y H:M a').format(lastEdited)}',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),

                        const Divider(),

                        // Username
                        Text(
                          'By $username',
                          style: const TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 10),

                        // Tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: tags.map((tag) {
                            return Chip(
                              label: Text(tag, style: const TextStyle(color: Colors.white)),
                              backgroundColor: Colors.teal,
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}