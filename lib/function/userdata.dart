import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Userdata {
  getData(uid) async {
    DocumentSnapshot<Map<String, dynamic>>? userDoc;
    User? user = FirebaseAuth.instance.currentUser;

    try {
      // trying to get it from cache first
      userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get(const GetOptions(source: Source.cache));
    } catch(error) {
      // get from server if cache fails
      userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get(const GetOptions(source: Source.server));
    }
    
    return userDoc;
  }
}