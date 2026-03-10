import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_model.dart';

// PlaceService: all Firestore operations for the "places" collection.
class PlaceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const _col = 'places';

  // getPlaces returns a real-time Stream.
  // Every time Firestore data changes the UI auto-updates.
  Stream<List<PlaceModel>> getPlaces() {
    return _db.collection(_col)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(PlaceModel.fromFirestore).toList());
  }

  // createPlace: imageUrl is always null (Storage removed)
  Future<void> createPlace(PlaceModel place) async {
    final ref = _db.collection(_col).doc();
    final data = place.toMap();
    data['imageUrl'] = null;  // no Storage = no image
    await ref.set(data);
  }

  
  Future<void> updatePlace(PlaceModel place) async {
    final data = place.toMap();
    data['imageUrl'] = null;
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _db.collection(_col).doc(place.id).update(data);
  }


  Future<void> deletePlace(String id) async {
    await _db.collection(_col).doc(id).delete();
  }
}
