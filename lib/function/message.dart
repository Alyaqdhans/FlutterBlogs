import 'package:flutter/material.dart';

class Message {
  
  void success(context, icon, text, color) {
    ScaffoldMessenger.of(context).showSnackBar(  
      SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      )
    );
  }

  void failed(context, icon, error, color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 10),
            Flexible(child: Text(error.toString().replaceAll(RegExp('\\[.+\\]'), '').trim(), style: const TextStyle(color: Colors.white, fontSize: 18))),
          ],
        ),
      )
    );
  }

}