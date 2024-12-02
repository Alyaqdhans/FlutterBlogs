import 'package:flutter/material.dart';

class Heroform extends StatelessWidget {
  const Heroform({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SizedBox(
              height: 350,
              child: Card(
                elevation: 5,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(                                           
                    bottomLeft: Radius.circular(75),
                    bottomRight: Radius.circular(75),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(                                           
                    bottomLeft: Radius.circular(75),
                    bottomRight: Radius.circular(75),
                  ),
                  child: Image(
                    image: AssetImage("assets/media.png"),
                    opacity: AlwaysStoppedAnimation(0.4),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        
            Text(
              'UTAS\n  BLOGS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 75,
                color: Colors.white,
                shadows: [
                  // Shadow(color: Colors.white, offset: Offset(14, 14)),
                  Shadow(color: Colors.black, offset: Offset(7, 7)),
                ]
              ),
            ),
          ],
        ),

        SizedBox(height: 10),
      ],
    );
  }
}