import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/place_model.dart';
import '../../providers/place_provider.dart';
import '../../providers/location_provider.dart';
import '../../utils/constants.dart';
import '../directory/place_detail_screen.dart';


// I centre the map on Kigali city centre by default
const _kigaliLat = -1.9441;
const _kigaliLng = 30.0619;


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}


class _MapScreenState extends State<MapScreen> {
  PlaceModel? _selected;


  @override
  Widget build(BuildContext context) {
    final places = context.watch<PlaceProvider>().allPlaces;
    final loc    = context.watch<LocationProvider>();
    return Stack(children: [
      FlutterMap(
        options: MapOptions(
          initialCenter: const LatLng(_kigaliLat, _kigaliLng),
          initialZoom: 13,
          // tapping empty space dismisses the popup card
          onTap: (_, __) => setState(() => _selected = null),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.kigali.kigali_directory',
          ),
          MarkerLayer(markers: [
            // blue dot for my location, only if GPS permission was granted
            if (loc.hasLocation)
              Marker(
                point: LatLng(loc.latitude!, loc.longitude!),
                width: 20, height: 20,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue, shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            // gold pin for every place listing
            ...places.map((p) => Marker(
              point: LatLng(p.latitude, p.longitude),
              width: 36, height: 36,
              child: GestureDetector(
                onTap: () => setState(() => _selected = p),
                child: const Icon(Icons.location_pin, color: kAccentGold, size: 36),
              ),
            )),
          ]),
        ],
      ),
      // popup card at the bottom when a marker is tapped
      if (_selected != null)
        Positioned(
          bottom: 16, left: 16, right: 16,
          child: Card(
            color: kCardDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(_selected!.name,
                style: kBodyText.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(_selected!.category, style: kCaptionText),
              trailing: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PlaceDetailScreen(place: _selected!))),
                child: const Text('View'),
              ),
            ),
          ),
        ),
    ]);
  }
}
