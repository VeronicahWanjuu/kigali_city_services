import 'dart:math';


// I use the Haversine formula here to calculate real-world distance
// between two GPS coordinates. It accounts for the Earth's curvature
// so the distance is accurate even if the two points are far apart.


class DistanceUtils {
  static double calculateDistanceKm(
    double lat1, double lon1, double lat2, double lon2,
  ) {
    const r = 6371.0; // Earth's radius in kilometres


    // I have to convert degrees to radians before I can use sin/cos
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }


  static double _rad(double deg) => deg * pi / 180.0;


  // I show short distances in metres and longer ones in kilometres
  static String formatDistance(double km) {
    return km < 1.0 ? '${(km * 1000).toInt()} m' : '${km.toStringAsFixed(1)} km';
  }
}
