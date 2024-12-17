import 'package:blogs/edit.dart';
import 'package:blogs/function/messenger.dart';
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
  List? userBlogs;
  Map<String, bool> loadingStates = {};

  int readMoreLimit = 100;

  Future userData() async {
    if (!mounted) return; // if page is closed
    if (user == null) return;
    
    DocumentSnapshot<Map<String, dynamic>>? userDoc;

    try {
      // trying to get it from cache first
      userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get(const GetOptions(source: Source.cache));
    } catch(error) {
      // get from server if cache fails
      userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get(const GetOptions(source: Source.server));
    }
    
    if (userDoc.data()!.isNotEmpty && mounted) {
      setState(() {
        isAdmin = userDoc!.data()!['admin'];
        userBlogs = userDoc.data()!['blogs'];
      });
    }
  }

  @override
  void initState() {
    super.initState();

    userData();
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
        var favorites = blogData['favorites'] as int;

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
                              children: [
                                Text(
                                  favorites.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold
                                  )
                                ),
                            
                                // Favorite
                                (user != null && userBlogs == null || loadingStates[id] == true)
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator()
                                      ),
                                    )
                                : IconButton(
                                    tooltip: 'Favorite',
                                    onPressed: (user == null)
                                    ? null
                                    : () async {
                                      setState(() {
                                        loadingStates[id] = true;
                                      });

                                      await FirebaseFirestore.instance.runTransaction((transaction) async {
                                        // References
                                        DocumentReference blogRef = FirebaseFirestore.instance.collection('blogs').doc(id);
                                        DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);

                                        // Get the latest blog document
                                        DocumentSnapshot blogSnapshot = await transaction.get(blogRef);
                                        DocumentSnapshot userSnapshot = await transaction.get(userRef);

                                        // Get the current favorites count
                                        int currentFavorites = blogSnapshot['favorites'];

                                        // Use the database state, not the local variable
                                        List<dynamic> currentUserBlogs = userSnapshot['blogs'];
                                        bool dbIsFavorite = currentUserBlogs.contains(id);

                                        if (dbIsFavorite == false) {
                                          // Increment favorites
                                          transaction.update(blogRef, {'favorites': currentFavorites + 1});
                                          currentUserBlogs.add(id);
                                        } else {
                                          // Decrement favorites
                                          transaction.update(blogRef, {'favorites': currentFavorites - 1});
                                          currentUserBlogs.remove(id);
                                        }
                                        // Update local blog list
                                        userBlogs = currentUserBlogs;

                                        // Update user's blogs list
                                        transaction.update(userRef, {'blogs': currentUserBlogs});
                                      });
                                      
                                      setState(() {
                                        loadingStates[id] = false;
                                      });
                                    },
                                    icon: (userBlogs?.contains(id) == true)
                                    ? const Icon(Icons.star, color: Colors.redAccent)
                                    : const Icon(Icons.star_border)
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
                      height: 40,
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
                                    padding: const EdgeInsets.only(right: 50),
                                    scrollDirection: Axis.horizontal,
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: tags.map((tag) {
                                        return Chip(
                                          label: Text(
                                            tag,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                          ),
                                          backgroundColor: Colors.teal,
                                          side: BorderSide.none,
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
                                                  await FirebaseFirestore.instance.collection('blogs').doc(id).delete();

                                                  // Get all users that have this blog ID in their array
                                                  QuerySnapshot<Map<String, dynamic>> usersWithBlog = await FirebaseFirestore.instance.collection('users')
                                                    .where('blogs', arrayContains: id).get();

                                                  // Create a batch instance
                                                  WriteBatch batch = FirebaseFirestore.instance.batch();

                                                  // Add updates to the batch
                                                  for (var userDoc in usersWithBlog.docs) {
                                                    DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userDoc.id);
                                                    
                                                    // Get current blogs array and remove the blog ID
                                                    List blogs = List.from(userDoc.data()['blogs']);
                                                    blogs.remove(id);
                                                    
                                                    // Update the user document with the modified array
                                                    batch.update(userRef, {'blogs': blogs});
                                                  }

                                                  await batch.commit();
                                                  userBlogs!.remove(id);
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