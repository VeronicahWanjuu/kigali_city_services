import 'package:cloud_firestore/cloud_firestore.dart';


// I manage the bookmarks/{uid}/places/{placeId} subcollection here.


class BookmarkService {
  final _db = FirebaseFirestore.instance;


  Stream<List<String>> getBookmarkIds(String uid) {
    return _db.collection('bookmarks').doc(uid).collection('places')
        .snapshots()
        .map((s) => s.docs.map((d) => d.id).toList());
  }


  Future<void> addBookmark(String uid, String placeId) async {
    await _db.collection('bookmarks').doc(uid)
        .collection('places').doc(placeId).set({
      'placeId': placeId,
      'savedAt': FieldValue.serverTimestamp(),
    });
  }


  Future<void> removeBookmark(String uid, String placeId) async {
    await _db.collection('bookmarks').doc(uid)
        .collection('places').doc(placeId).delete();
  }
}
