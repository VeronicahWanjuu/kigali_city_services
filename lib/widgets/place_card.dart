import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/place_model.dart';
import '../providers/location_provider.dart';
import '../utils/constants.dart';
import '../utils/distance_utils.dart';
import 'star_display_widget.dart';


// I reuse this card in both the Directory screen and My Listings screen.
// It shows the place name, star rating, distance if GPS is available, and category badge.


class PlaceCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onTap;
  const PlaceCard({required this.place, required this.onTap, super.key});


  @override
  Widget build(BuildContext context) {
    // I use context.read here because LocationProvider doesn't change
    // during the lifetime of this card. I just need to read it once
    final loc = context.read<LocationProvider>();
    String dist = '';
    if (loc.hasLocation) {
      final km = DistanceUtils.calculateDistanceKm(
        loc.latitude!, loc.longitude!,
        place.latitude, place.longitude,
      );
      dist = DistanceUtils.formatDistance(km);
    }
    return Card(
      color: kCardDark,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(place.name,
          style: kBodyText.copyWith(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(children: [
              StarDisplayWidget(rating: place.averageRating, size: 13),
              const SizedBox(width: 4),
              Text(
                place.averageRating > 0
                    ? '${place.averageRating} (${place.reviewCount})'
                    : 'No ratings yet',
                style: kCaptionText,
              ),
            ]),
            if (dist.isNotEmpty)
              Text(dist, style: kCaptionText.copyWith(color: kAccentGold)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: kAccentGold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(place.category,
            style: const TextStyle(color: kAccentGold, fontSize: 11)),
        ),
      ),
    );
  }
}
