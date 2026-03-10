import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../utils/constants.dart';


// This widget shows a read-only star rating.
// I use RatingBarIndicator, not RatingBar — the indicator version is not interactive.


class StarDisplayWidget extends StatelessWidget {
  final double rating;
  final double size;
  const StarDisplayWidget({required this.rating, this.size = 16, super.key});


  @override
  Widget build(BuildContext context) => RatingBarIndicator(
    rating: rating,
    itemBuilder: (_, __) => const Icon(Icons.star, color: kAccentGold),
    itemCount: 5,
    itemSize: size,
  );
}
