import 'package:cloud_firestore/cloud_firestore.dart';


// I store reviews in a subcollection inside each place:
// places/{placeId}/reviews/{reviewId}


class Review {
  final String id;
  final String placeId;     // I need this to know which place the review belongs to
  final String userId;
  final String userName;
  final double rating;      
  final String comment;
  final DateTime createdAt;


  Review({
    required this.id, required this.placeId,
    required this.userId, required this.userName,
    required this.rating, required this.comment,
    required this.createdAt,
  });


  factory Review.fromFirestore(DocumentSnapshot doc, String placeId) {
    final d = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id, placeId: placeId,
      userId: d['userId'] ?? '',
      userName: d['userName'] ?? '',
      rating: (d['rating'] ?? 0.0).toDouble(),
      comment: d['comment'] ?? '',
      createdAt: d['createdAt'] != null
          ? (d['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }


  Map<String, dynamic> toMap() => {
    'placeId': placeId, 'userId': userId, 'userName': userName,
    'rating': rating, 'comment': comment,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
