import 'package:blogs/function/library.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  User? user = FirebaseAuth.instance.currentUser;
  CustomLibrary msg = CustomLibrary();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();
  String? university;
  List universities = ["UTAS", "UNizwa", "SQU", "MEC"];
  String? department;
  List departments = ["IT", "Engineering", "Business", "English", "Math", "Fashion", "Pharmacy", "Photography"];
  final TextEditingController _course = TextEditingController();

  bool isLoading = false;

  Future create() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_title.text.trim().isEmpty
      || _content.text.trim().isEmpty
      || university!.isEmpty
      || department!.isEmpty
      || _course.text.trim().isEmpty) throw 'Some fields are empty';

      await FirebaseFirestore.instance.collection('blogs').add({
        'user': user!.displayName,
        'title': _title.text.trim(),
        'contents': _content.text.trim(),
        'university': university,
        'department': department,
        'course': _course.text.trim().toLowerCase(),
        'date': DateTime.now(),
        'isEdited': false,
        'lastEdited': DateTime.now()
      });

      msg.success(context, Icons.check, 'Blog created successfully!', Colors.green);
      Navigator.pop(context);

    } catch(error) {
      msg.failed(context, Icons.close, error, Colors.red);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
    
      appBar: AppBar(
        title: const Text('Create Blog'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'mark',
        child: const Icon(Icons.question_mark),
        onPressed: () {
          showDialog(
            barrierDismissible: true,
            context: context,
            builder: (context) => Hero(
              tag: 'mark',
              child: AlertDialog(
                // title: const Text('How to use Markdown formatting'),
                content: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Image.asset('assets/markdown.png'),
                )
              ),
            ),
          );
        }
      ),
    
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _title,
                      decoration: InputDecoration(
                        labelText: 'Blog Title',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    TextFormField(
                      maxLines: 10,
                      controller: _content,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        labelText: 'Blog Contents',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    ListTile(
                      title: Text(
                        'Tags',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    
                    ListTile(
                      title: DropdownButtonFormField(
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(15),
                        items: universities.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e)
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            university = value.toString();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'University',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 5),
              
                    ListTile(
                      title: DropdownButtonFormField(
                        isExpanded: true,
                        borderRadius: BorderRadius.circular(15),
                        items: departments.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e)
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            department = value.toString();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Departments',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                    ),
              
                    const SizedBox(height: 5),
              
                    ListTile(
                      title: TextFormField(
                        controller: _course,
                        decoration: InputDecoration(
                          labelText: 'Course ID',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                        ),
                      ),
                    ),
                  
                    const SizedBox(height: 20),
                    
                    ListTile(
                      title: (isLoading == false)
                      ? FloatingActionButton.extended(
                          heroTag: 'create',
                          icon: const Icon(Icons.library_add),
                          label: const Text(
                            'Create',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20
                            )
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          onPressed: () {
                            create();
                          }
                        )
                      : FloatingActionButton.extended(
                          heroTag: null,
                          backgroundColor: Colors.grey[500],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          label: const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(color: Colors.white)
                          ),
                          onPressed: null,
                        ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}