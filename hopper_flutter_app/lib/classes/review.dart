import 'package:cloud_firestore/cloud_firestore.dart';

import 'driver.dart';

class Review {
  late var docref;
  String uid;
  double rating;
  String body;
  Driver driver;

  Review(this.uid, this.rating, this.body, this.driver);

  void uploadToDb() {
    FirebaseFirestore.instance
        .collection('${driver.docref.path}/reviews')
        .add(toJson())
        .then((value) {
      docref = value;
    });
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'rating': rating, 'body': body};
  }
}
