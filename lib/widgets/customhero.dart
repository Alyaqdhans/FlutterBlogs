import 'package:flutter/material.dart';

class CustomHero extends StatelessWidget {
  const CustomHero({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Card(
                elevation: 5,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(                                           
                    bottom: Radius.circular(75),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image(
                  image: AssetImage("assets/media.png"),
                  opacity: AlwaysStoppedAnimation(0.4),
                  fit: BoxFit.cover,
                ),
              ),
            ),
        
            Text(
              'UTAS\n  BLOGS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 60,
                color: Colors.white,
                shadows: [
                  // Shadow(color: Colors.black, offset: Offset(21, 21)),
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