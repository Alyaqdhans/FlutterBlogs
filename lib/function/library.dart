import 'package:flutter/material.dart';

class CustomLibrary {
  
  success(context, icon, text, color) {
    ScaffoldMessenger.of(context).showSnackBar(  
      SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: color.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(width: 10),
            Flexible(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18))),
          ],
        ),
      )
    );
  }

  failed(context, icon, error, color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        backgroundColor: color.withOpacity(0.8),
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

  Future<bool?> showBottomAction(context, title, content, actionTitle, actionColor) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 60,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: const BorderSide(color: Colors.blue, width: 2),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      actionTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}