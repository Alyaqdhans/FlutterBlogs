import 'dart:async';

import 'package:blogs/edit.dart';
import 'package:blogs/function/messenger.dart';
import 'package:blogs/search.dart';
import 'package:blogs/widgets/preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Messenger msg = Messenger();
  User? user = FirebaseAuth.instance.currentUser;
  bool? isAdmin;
  Map<String, bool> loadingStates = {};
  Map<String, int> favoriteCounts = {};
  Map<String, bool> userFavorites = {};
  Map<String, StreamSubscription> favoriteStreams = {};

  int readMoreLimit = 100;

  Future userData() async {
    if (!mounted) return; // if page is closed
    if (user == null) return;
    
    DocumentSnapshot<Map<String, dynamic>>? userDoc;

    userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    
    if (userDoc.data()!.isNotEmpty && mounted) {
      setState(() {
        isAdmin = userDoc!.data()!['admin'];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    userData();
  }

  @override
  void dispose() {
    // Cancel all streams when widget is disposed
    for (var stream in favoriteStreams.values) {
      stream.cancel();
    }
    super.dispose();
  }

  // Add this method to setup stream for each blog
  void listenToFavorites(String blogId) {
    if (favoriteStreams.containsKey(blogId)) return;

    final stream = FirebaseFirestore.instance.collection('blogs')
      .doc(blogId).collection('favorites').snapshots();

    favoriteStreams[blogId] = stream.listen((snapshot) {
      if (mounted) {
        setState(() {
          favoriteCounts[blogId] = snapshot.docs.length;
          userFavorites[blogId] = snapshot.docs.any((doc) => doc.id == user?.uid);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 90),
      itemCount: widget.snapshot.data!.docs.length,
      itemBuilder: (context, index) {
        var blogData = widget.snapshot.data!.docs[index];

        var userid = blogData['userid'];
        var username = blogData['username'];
        var id = blogData.id;
        var title = blogData['title'];
        var contents = blogData['contents'].toString();
        var tags = (blogData['tags'] as List).toList();
        var date = (blogData['date'] as Timestamp).toDate();
        var isEdited = blogData['isEdited'];
        var lastEdited = (blogData['lastEdited'] as Timestamp).toDate();

        // Setup stream for this blog
        listenToFavorites(id);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
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
                    SizedBox(
                      height: 40,
                      child: Row(
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
                          
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Favorite
                                (favoriteCounts[id] == null || userFavorites[id] == null || loadingStates[id] == true)
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15),
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator()
                                      ),
                                    )
                                : Row(
                                  children: [
                                    Text(
                                      (favoriteCounts[id]).toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold
                                      )
                                    ),

                                    IconButton(
                                        tooltip: 'Favorite',
                                        onPressed: (user == null)
                                        ? null
                                        : () async {
                                          setState(() {
                                            loadingStates[id] = true;
                                          });
                                    
                                          try {
                                            DocumentReference userBlogRef = FirebaseFirestore.instance.collection('users')
                                              .doc(user!.uid).collection('blogs').doc(id);
                                            DocumentReference blogFavoriteRef = FirebaseFirestore.instance.collection('blogs')
                                              .doc(id).collection('favorites').doc(user!.uid);
                                    
                                            DocumentSnapshot userBlogDoc = await userBlogRef.get();
                                    
                                            if (!userBlogDoc.exists) {
                                              // Add to favorites
                                              await userBlogRef.set({
                                                'timestamp': DateTime.now(),
                                              });
                                              await blogFavoriteRef.set({
                                                'timestamp': DateTime.now(),
                                              });
                                            } else {
                                              // Remove from favorites
                                              await userBlogRef.delete();
                                              await blogFavoriteRef.delete();
                                            }
                                          } catch (error) {
                                            msg.failed(context, Icons.close, error, Colors.red);
                                          }
                                    
                                          setState(() {
                                            loadingStates[id] = false;
                                          });
                                        },
                                        icon: userFavorites[id] == true
                                        ? const Icon(Icons.star, color: Colors.redAccent)
                                        : const Icon(Icons.star_border)
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(color: Colors.blue),

                    const SizedBox(height: 8),

                    // Preview of Contents
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: MarkdownBody(
                        data: contents.length > readMoreLimit ? '${contents.substring(0, readMoreLimit)}...' : contents,
                        fitContent: false,
                      ),
                    ),

                    if (contents.length > readMoreLimit)
                      const SizedBox(height: 8),

                    // Floating Action Button for Read More
                    if (contents.length > readMoreLimit)
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
                      'Created on: ${DateFormat('d/M/y h:mm a').format(date)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (isEdited)
                      Text(
                        'Edited on: ${DateFormat('d/M/y h:mm a').format(lastEdited)}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),

                    const SizedBox(height: 5),

                    SizedBox(
                      height: 50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Tags
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.only(left: 5, right: 60),
                                    scrollDirection: Axis.horizontal,
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: tags.map((tag) {
                                        return GestureDetector(
                                          child: Chip(
                                            label: Text(
                                              tag,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 13,
                                              ),
                                            ),
                                            backgroundColor: Colors.teal,
                                            side: BorderSide.none,
                                          ),
                                          onTap: () {
                                            // if on search page replace the page
                                            bool isOnSearchPage = Navigator.canPop(context);
                                            
                                            if (isOnSearchPage) {
                                              Navigator.pushReplacement(
                                                context, 
                                                MaterialPageRoute(builder: (context) => Search(
                                                  filterName: tag,
                                                  filterIndex: 3,
                                                ))
                                              );
                                            } else {
                                              Navigator.push(
                                                context, 
                                                MaterialPageRoute(builder: (context) => Search(
                                                  filterName: tag,
                                                  filterIndex: 3,
                                                ))
                                              );
                                            }
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                
                                // Extra options
                                (isAdmin == null && (user != null && userid != user!.uid))
                                ? const Align(
                                    alignment: Alignment.centerRight,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator()
                                        ),
                                      ),
                                )
                                : (user == null || !(user!.uid == userid || isAdmin == true))
                                  ? const SizedBox.shrink()
                                  : Align(
                                      alignment: Alignment.centerRight,
                                      child: Material(
                                        color: Colors.white,
                                        shape: const RoundedRectangleBorder(),
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 5),
                                          child: PopupMenuButton(
                                            elevation: 7,
                                            tooltip: 'Extra',
                                            icon: const Icon(Icons.more_vert),
                                            onSelected: (value) async {
                                              if (value == 'Edit') {
                                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                  return Edit(blogData: blogData);
                                                }));
                                              } else if (value == 'Delete') {
                                                final result = await msg.showBottomAction(
                                                  context,
                                                  'Are you sure you want to delete?',
                                                  'This will delete the current blog forever, and there is no going back!',
                                                  'Permanently Delete',
                                                  Colors.red[700],
                                                );
                                          
                                                if (result == true) {
                                                  // Delete the blog document
                                                  await FirebaseFirestore.instance.collection('blogs').doc(id).delete();

                                                  // Get all users that have this blog ID in their subcollection
                                                  QuerySnapshot<Map<String, dynamic>> usersWithBlog = await FirebaseFirestore.instance.collection('users').get();

                                                  // Create a batch instance
                                                  WriteBatch batch = FirebaseFirestore.instance.batch();

                                                  // Iterate over each user document
                                                  for (var userDoc in usersWithBlog.docs) {
                                                    // Reference to the user's blog subcollection document
                                                    DocumentReference userBlogRef = FirebaseFirestore.instance.collection('users')
                                                      .doc(userDoc.id).collection('blogs').doc(id);

                                                    // Check if the document exists in the subcollection
                                                    DocumentSnapshot userBlogSnapshot = await userBlogRef.get();
                                                    if (userBlogSnapshot.exists) {
                                                      // Add delete operation to the batch
                                                      batch.delete(userBlogRef);
                                                    }
                                                  }

                                                  // Commit the batch
                                                  await batch.commit();
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
                                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                                  ),
                                                ),
                                              ),
                        
                                              const PopupMenuItem(
                                                value: 'Delete',
                                                child: ListTile(
                                                  leading: Icon(Icons.delete, color: Colors.red),
                                                  title: Text(
                                                    'Delete',
                                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),
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