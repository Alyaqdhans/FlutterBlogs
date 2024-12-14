import 'package:blogs/function/messenger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PreviewMarkdown extends StatefulWidget {
  final String contents;
  final String title;
  final String tag;
  const PreviewMarkdown({super.key, required this.contents, required this.tag, required this.title});

  @override
  State<PreviewMarkdown> createState() => _PreviewMarkdownState();
}

class _PreviewMarkdownState extends State<PreviewMarkdown> {
  Messenger msg = Messenger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
    
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        foregroundColor: Colors.white,
      ),
    
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        heroTag: widget.tag,
        icon: const Icon(Icons.navigate_before, size: 30),
        label: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
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
                child: MarkdownBody(
                  data: widget.contents,
                  fitContent: false,
                  selectable: true,
                )
              ),
            ),
          ],
        )
      : const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.visibility_off,
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
        )
    );
  }
}