import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/place_model.dart';
import '../services/place_service.dart';

enum PlaceState { initial, loading, loaded, error }

// PlaceProvider manages all listing data for the whole app.

class PlaceProvider extends ChangeNotifier {
  final PlaceService _svc;
  PlaceState _state = PlaceState.initial;
  List<PlaceModel> _all = [];
  String _query = '';
  String _cat = 'All';
  String? _error;
  StreamSubscription<List<PlaceModel>>? _sub;

  PlaceState get state => _state;
  String get searchQuery => _query;
  String get selectedCategory => _cat;
  String? get errorMessage => _error;
  List<PlaceModel> get allPlaces => _all;

  List<PlaceModel> get filteredPlaces => _all.where((p) {
    final matchQ = _query.isEmpty ||
        p.name.toLowerCase().contains(_query.toLowerCase());
    final matchC = _cat == 'All' || p.category == _cat;
    return matchQ && matchC;
  }).toList();

  int getCategoryCount(String cat) {
    if (cat == 'All') return _all.length;
    return _all.where((p) => p.category == cat).length;
  }

  List<PlaceModel> getUserPlaces(String uid) =>
      _all.where((p) => p.createdBy == uid).toList();

  PlaceProvider(this._svc);

  void startListening() {
    if (_sub != null) return;
    _state = PlaceState.loading;
    notifyListeners();
    _sub = _svc.getPlaces().listen(
      (places) {
        _all = places;
        _state = PlaceState.loaded;
        notifyListeners();
      },
      onError: (e) {
        _state = PlaceState.error;
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void setSearchQuery(String q) { _query = q; notifyListeners(); }
  void setCategory(String c) { _cat = c; notifyListeners(); }
  void clearFilters() { _query = ''; _cat = 'All'; notifyListeners(); }


  Future<bool> createPlace(PlaceModel place) async {
    try {
      await _svc.createPlace(place);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePlace(PlaceModel place) async {
    try {
      await _svc.updatePlace(place);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePlace(String id, String? imageUrl) async {
    try {
      await _svc.deletePlace(id);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() { _sub?.cancel(); super.dispose(); }
}
