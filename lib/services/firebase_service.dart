import 'package:cloud_firestore/cloud_firestore.dart';

// Import the firebase_core and cloud_firestore plugin
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseApp secondaryApp = Firebase.app('SecondaryApp');
  FirebaseFirestore firestore =
      FirebaseFirestore.instanceFor(app: secondaryApp);
}
