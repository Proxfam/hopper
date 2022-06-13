import 'driver.dart';

class Review {
  String uid;
  double rating;
  String body;
  Driver driver;

  Review(this.uid, this.rating, this.body, this.driver);

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'rating': rating, 'body': body};
  }
}
