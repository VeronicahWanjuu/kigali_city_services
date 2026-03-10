import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants.dart';


// I show 5 skeleton cards while the listings are loading from Firestore.
// It's much better UX than showing a blank screen or a plain spinner.


class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Shimmer.fromColors(
          baseColor: kCardDark,
          highlightColor: kCardDark.withValues(alpha: 0.4),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: kCardDark,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
