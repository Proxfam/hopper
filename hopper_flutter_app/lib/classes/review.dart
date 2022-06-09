class Review {
  String uid;

  Review(this.uid);

  Map<String, dynamic> toJson() {
    return {'uid': uid};
  }
}
