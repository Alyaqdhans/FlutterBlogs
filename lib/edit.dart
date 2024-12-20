import 'package:blogs/function/dropdowndata.dart';
import 'package:blogs/function/messenger.dart';
import 'package:blogs/widgets/hint.dart';
import 'package:blogs/widgets/preview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Edit extends StatefulWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> blogData;
  const Edit({super.key, required this.blogData});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  User? user = FirebaseAuth.instance.currentUser;
  Messenger msg = Messenger();
  DropdownData ddd = DropdownData();

  final TextEditingController _title = TextEditingController();
  final TextEditingController _content = TextEditingController();
  String? university;
  List? universities;
  String? department;
  List? departments;
  final TextEditingController _course = TextEditingController();

  String? universityBlog;
  String? departmentBlog;
  
  bool isLoading = false;

  Future edit(id) async {
    setState(() {
      isLoading = true;
    });

    try {
      if (_title.text.trim().isEmpty
      || _content.text.trim().isEmpty
      || university!.isEmpty
      || department!.isEmpty
      || _course.text.trim().isEmpty) throw 'Some fields are empty';

      await FirebaseFirestore.instance.collection('blogs').doc(id).update({
        'title': _title.text.trim(),
        'contents': _content.text.trim(),
        'tags': [university, department, _course.text.trim().toUpperCase()],
        'isEdited': true,
        'lastEdited': DateTime.now(),
      });

      msg.success(context, Icons.check, 'Blog edited successfully!', Colors.green);
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
  void initState() {
    super.initState();
    universities = ddd.getUniversities();
    departments = ddd.getDepartments();

    _content.text = widget.blogData['contents'].toString();
    universityBlog = widget.blogData['tags'][0];
    departmentBlog = widget.blogData['tags'][1];
    _course.text = widget.blogData['tags'][2];

    university = universityBlog;
    department = departmentBlog;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    var id = widget.blogData.id;
    var title = widget.blogData['title'];
    
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text('Edit Blog'),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'markdown',
        child: const Icon(Icons.question_mark),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return const MarkdownDemo();
          }));
        }
      ),

      body: ListView(
        padding: const EdgeInsets.only(bottom: 60),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    TextFormField(
                      maxLength: 30,
                      controller: _title..text = title,
                      decoration: InputDecoration(
                        labelText: 'Blog Title',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    TextFormField(
                      maxLength: 2000,
                      maxLines: 10,
                      controller: _content,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        labelText: 'Blog Contents',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),

                    ListTile(
                      title: SizedBox(
                        width: 120,
                        height: 30,
                        child: FloatingActionButton.extended(
                          heroTag: 'preview',
                          icon: const Icon(Icons.visibility, size: 20),
                          label: const Text(
                            'Preview',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) {
                                return PreviewMarkdown(
                                    contents: _content.text.trim(),
                                    title: 'Preview',
                                    tag: 'preview'
                                  );
                                }
                              )
                            );
                          },
                        ),
                      ),
                    ),
                                        
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
                        value: universityBlog,
                        items: universities!.map((e) {
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
                        value: departmentBlog,
                        items: departments!.map((e) {
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
                        maxLength: 8,
                        controller: _course,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            String text = newValue.text.toUpperCase();
                            String letters = text.replaceAll(RegExp(r'[^A-Z]'), '');
                            String numbers = text.replaceAll(RegExp(r'[^0-9]'), '');

                            // Ensure only the first 4 characters are letters
                            if (letters.length > 4) {
                              letters = letters.substring(0, 4);
                            }

                            // Ensure only the last 4 characters are numbers
                            if (numbers.length > 4) {
                              numbers = numbers.substring(0, 4);
                            }

                            // Combine letters and numbers
                            String finalText = letters + numbers;

                            // Limit the final text to 8 characters
                            if (finalText.length > 8) {
                              finalText = finalText.substring(0, 8);
                            }

                            return TextEditingValue(
                              text: finalText,
                              selection: TextSelection.collapsed(offset: finalText.length),
                            );
                          }),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Course ID',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                          helperText: 'XXXX0000 (must be 8 characters)',
                        ),
                      ),
                    ),
                  
                    const SizedBox(height: 20),
                    
                    ListTile(
                      title: (isLoading == false)
                      ? SizedBox(
                          height: 45,
                          child: FloatingActionButton.extended(
                            heroTag: null,
                            icon: const Icon(Icons.edit),
                            label: const Text(
                              'Edit',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20
                              )
                            ),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            onPressed: () {
                              edit(id);
                            }
                          ),
                        )
                      : SizedBox(
                        height: 45,
                          child: FloatingActionButton.extended(
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