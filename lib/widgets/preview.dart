import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PreviewMarkdown extends StatefulWidget {
  final String contents;
  const PreviewMarkdown({super.key, required this.contents});

  @override
  State<PreviewMarkdown> createState() => _PreviewMarkdownState();
}

class _PreviewMarkdownState extends State<PreviewMarkdown> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'preview',
      child: Scaffold(
        backgroundColor: Colors.grey[200],
      
        appBar: AppBar(
          title: const Text('Preview'),
          centerTitle: true,
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
        ),
      
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          heroTag: null,
          icon: const Icon(Icons.navigate_before),
          label: const Text('Back'),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
      
        body: (widget.contents.isEmpty == false)
        ? ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: MarkdownBody(data: widget.contents)
                ),
              ),
            ],
          )
        : const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(50),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.folder_off,
                      color: Colors.blue,
                      size: 70,
                    ),
                    
                    Text(
                      'No contents to preview',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
      ),
    );
  }
}