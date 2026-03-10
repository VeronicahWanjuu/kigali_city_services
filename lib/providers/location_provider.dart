import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';


enum LocationState { initial, loading, loaded, denied, error }


// I use this provider to manage GPS permission and the user's current position.


class LocationProvider extends ChangeNotifier {
  LocationState _state = LocationState.initial;
  Position? _pos;
  String? _error;


  LocationState get state => _state;
  double? get latitude => _pos?.latitude;
  double? get longitude => _pos?.longitude;
  bool get hasLocation => _pos != null;
  String? get errorMessage => _error;


  Future<void> requestLocation() async {
    _state = LocationState.loading;
    notifyListeners();
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _state = LocationState.error;
        _error = 'Location services disabled on device.';
        notifyListeners();
        return;
      }
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) {
          _state = LocationState.denied;
          _error = 'Location permission denied.';
          notifyListeners();
          return;
        }
      }
      if (perm == LocationPermission.deniedForever) {
        _state = LocationState.denied;
        _error = 'Location permanently denied. Enable in phone settings.';
        notifyListeners();
        return;
      }
      // I set a 10 second timeout so the app doesn't freeze on weak GPS signal
      _pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
      _state = LocationState.loaded;
    } catch (_) {
      _state = LocationState.error;
      _error = 'Could not get location. App continues without it.';
    }
    notifyListeners();
  }
}
