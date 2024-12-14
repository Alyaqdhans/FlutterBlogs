import 'package:blogs/edit.dart';
import 'package:blogs/function/messenger.dart';
import 'package:blogs/function/userdata.dart';
import 'package:blogs/widgets/preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';

class BlogCard extends StatefulWidget {
  final AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;
  final bool checkAdmin;
  const BlogCard({super.key, required this.snapshot, required this.checkAdmin});

  @override
  State<BlogCard> createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  Messenger msg = Messenger();
  Userdata userdata = Userdata();
  User? user = FirebaseAuth.instance.currentUser;
  bool isAdmin = false;

  Future checkIsAdmin(uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await userdata.getData(user!.uid);
      
      if (userDoc.data()!.isNotEmpty) {
        setState(() {
          isAdmin = userDoc.data()!['admin'];
        });
      }
    } catch (e) {
      setState(() {
        isAdmin = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (user == null) return;
    if (widget.checkAdmin) {
      checkIsAdmin(user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 90),
      itemCount: widget.snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        var blogData = widget.snapshot.data!.docs[index];

        var userId = blogData['userid'];
        var username = blogData['username'];
        var id = blogData.id;
        var title = blogData['title'];
        var contents = blogData['contents'].toString();
        var tags = (blogData['tags'] as List).toList();
        var date = (blogData['date'] as Timestamp).toDate();
        var isEdited = blogData['isEdited'];
        var lastEdited = (blogData['lastEdited'] as Timestamp).toDate();
        var favorites = blogData['favorites'];

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
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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
                            Text(
                              favorites.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold
                              )
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

                    const Divider(color: Colors.blue),

                    const SizedBox(height: 8),

                    // Preview of Contents
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MarkdownBody(
                        data: contents.length > 70 ? '${contents.substring(0, 100)}...' : contents,
                        fitContent: false,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Floating Action Button for Read More
                    if (contents.length > 70)
                      Center(
                        child: SizedBox(
                          height: 30,
                          child: FloatingActionButton.extended(
                            elevation: 1,
                            foregroundColor: Colors.blue,
                            backgroundColor: Colors.white,
                            heroTag: id,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PreviewMarkdown(
                                    contents: contents,
                                    title: title,
                                    tag: id
                                  ),
                                ),
                              );
                            },
                            label: const Text('Read More'),
                          ),
                        ),
                      ),

                    const SizedBox(height: 8),

                    const Divider(color: Colors.blue),

                    // Username
                    Text(
                      'By $username',
                      style: TextStyle(color: Colors.grey[600]),
                    ),

                    const SizedBox(height: 5),

                    // Created and Edited Dates
                    Text(
                      'Created on: ${DateFormat('d/M/y h:m a').format(date)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (isEdited)
                      Text(
                        'Edited on: ${DateFormat('d/M/y h:m a').format(lastEdited)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tags
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: tags.map((tag) {
                            return Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13
                                )
                              ),
                              backgroundColor: Colors.teal,
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),

                        if (user != null && user!.uid == userId || isAdmin == true)
                          // Expand Menu
                          PopupMenuButton(
                            elevation: 7,
                            tooltip: 'Extra',
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'Edit') {
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return Edit(
                                    blogData: blogData,
                                    userData: [userId, username]
                                  );
                                }));
                              } else if (value == 'Delete') {
                                final result = await msg.showBottomAction(
                                  context,
                                  'Are you sure you want to delete?',
                                  'This will delete the current blog forever, and ther is no going back!',
                                  'Permanently Delete',
                                  Colors.red[700]
                                );

                                if (result == true) {
                                  await FirebaseFirestore.instance.collection('blogs').doc(id).delete();
                                }
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
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}