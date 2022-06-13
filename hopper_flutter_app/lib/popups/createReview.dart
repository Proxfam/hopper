import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../classes/review.dart';

class createReview extends StatelessWidget {
  const createReview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);

    TextEditingController _body = TextEditingController();

    double _ratingValue = 0;

    return AlertDialog(
      title: Text("How was your ride?", style: themeData.textTheme.headline1),
      content: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Form(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                  decoration:
                      const InputDecoration(labelText: "Write a review"),
                  controller: _body),
              const SizedBox(height: 10),
              RatingBar(
                  initialRating: 5,
                  glow: false,
                  allowHalfRating: false,
                  ratingWidget: RatingWidget(
                      empty: const Icon(
                        Icons.star_border_outlined,
                        color: Colors.amber,
                      ),
                      full: Icon(Icons.star, color: Colors.amber),
                      half: Icon(Icons.pedal_bike)),
                  onRatingUpdate: (value) {
                    _ratingValue = value;
                  })
            ],
          ))),
      actions: [
        TextButton(
            onPressed: () => {
                  // Review(FirebaseAuth.instance.currentUser!.uid, _ratingValue,
                  //     _body.text)
                },
            child: Text(
              "Submit",
              style: themeData.textTheme.subtitle1,
            ))
      ],
    );
  }
}
