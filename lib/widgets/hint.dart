import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MarkdownDemo extends StatefulWidget {
  const MarkdownDemo({super.key});

  @override
  State<MarkdownDemo> createState() => _MarkdownDemoState();
}

class _MarkdownDemoState extends State<MarkdownDemo> {
  String hint = """
# **&copy; Markdown syntax guide**
---
` `

## Headers
---
# This is a Heading h1
## This is a Heading h2
###### This is a Heading h6

## Emphasis
---
*This text will be italic*  
_This will also be italic_

**This text will be bold**  
__This will also be bold__

_You **can** combine them_

## Lists
---
### Unordered

* Item 1
* Item 2
* Item 2a
* Item 2b
    * Item 3a
    * Item 3b

### Ordered

1. Item 1
2. Item 2
3. Item 3
    1. Item 3a
    2. Item 3b

## Images
---
This is a sample image.

![This is an alt text.](https://picsum.photos/id/870/200/300.jpg)

## Links
---
You may be using [Markdown Live Preview](https://markdownlivepreview.com/).

## Blockquotes
---
> Markdown is a lightweight markup language with plain-text-formatting syntax, created in 2004 by John Gruber with Aaron Swartz.

>> Markdown is often used to format readme files, for writing messages in online discussion forums, and to create rich text using a plain text editor.

## Tables
---
| Left columns  | Right columns (centered) |
| ------------- |:-------------:|
| left foo      | right foo     |
| left bar      | right bar     |
| left baz      | right baz     |

## Blocks of code
---
```
let message = 'Hello world';
alert(message);
```

## Inline code
---
This web site is using `markedjs/marked`.

## Breaking lines (using code syntax)
---
### small space
` `
### large space
```
```

###### **end of guide**
<div style="text-align: right"> your-text-here </div>
""";

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[200],
      
        appBar: AppBar(
          title: const Text('Hints'),
          centerTitle: true,
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
    
          bottom: TabBar(
            indicatorWeight: 7,
            indicatorColor: const Color.fromARGB(255, 71, 186, 253),
    
            labelColor: const Color.fromARGB(255, 71, 186, 253),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.7),
    
            unselectedLabelColor: Colors.grey[300],
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            
            tabs: const [
              Tab(text: 'You See', icon: Icon(Icons.visibility)),
              Tab(text: 'You Type', icon: Icon(Icons.edit)),
            ]
          ),
        ),
      
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'markdown',
          icon: const Icon(Icons.navigate_before, size: 30),
          label: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
          onPressed: () {
            Navigator.pop(context);
          }
        ),
      
        body: TabBarView(
          children: [
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: MarkdownBody(
                      data: hint,
                      fitContent: false
                    )
                  ),
                ),
              ],
            ),
    
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextFormField(
                    readOnly: true,
                    initialValue: hint,
                    maxLines: (MediaQuery.of(context).size.height).floor(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
              ),
            )
          ]
        )
      ),
    );
  }
}