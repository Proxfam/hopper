class Review {
  String uid;
  double rating;
  String body;

  Review(this.uid, this.rating, this.body);

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'rating': rating, 'body': body};
  }
}
