import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';


// I handle the reviews subcollection inside each place document here.
// After every new review comes in I recalculate the average rating on the parent place.


class ReviewService {
  final _db = FirebaseFirestore.instance;


  Stream<List<Review>> getReviews(String placeId) {
    return _db.collection('places').doc(placeId).collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Review.fromFirestore(d, placeId)).toList());
  }


  Future<void> addReview(Review review) async {
    await _db.collection('places').doc(review.placeId)
        .collection('reviews').add(review.toMap());
    await _recalcRating(review.placeId);
  }


  Future<void> _recalcRating(String placeId) async {
    final snap = await _db.collection('places').doc(placeId)
        .collection('reviews').get();
    if (snap.docs.isEmpty) {
      await _db.collection('places').doc(placeId)
          .update({'averageRating': 0.0, 'reviewCount': 0});
      return;
    }
   
    final ratings = snap.docs
        .map((d) => (d.data()['rating'] as num).toDouble()).toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;
    await _db.collection('places').doc(placeId).update({
      'averageRating': double.parse(avg.toStringAsFixed(1)),
      'reviewCount': ratings.length,
    });
  }
}
