import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';


enum ReviewState { initial, loading, loaded, error }


class ReviewProvider extends ChangeNotifier {
  final ReviewService _svc;
  ReviewState _state = ReviewState.initial;
  List<Review> _reviews = [];
  String? _error;
  StreamSubscription<List<Review>>? _sub;
  String? _currentPlaceId;


  ReviewState get state => _state;
  List<Review> get reviews => _reviews;
  String? get errorMessage => _error;


  ReviewProvider(this._svc);


  // I cancel the previous subscription when the user opens a different place.
  // Without this, the old place's reviews would briefly show in the new place.
  void loadReviews(String placeId) {
    if (_currentPlaceId == placeId) return; 
    _sub?.cancel();
    _currentPlaceId = placeId;
    _reviews = [];
    _state = ReviewState.loading;
    notifyListeners();
    _sub = _svc.getReviews(placeId).listen(
      (r) { _reviews = r; _state = ReviewState.loaded; notifyListeners(); },
      onError: (e) { _state = ReviewState.error; _error = e.toString(); notifyListeners(); },
    );
  }


  Future<bool> addReview(Review r) async {
    try { await _svc.addReview(r); return true; }
    catch (e) { _error = e.toString().replaceAll('Exception: ', ''); notifyListeners(); return false; }
  }


  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}
