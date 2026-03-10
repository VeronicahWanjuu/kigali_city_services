import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/place_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/place_card.dart';
import '../directory/place_detail_screen.dart';

// I show the user's saved/bookmarked places here.
// I match bookmark IDs against PlaceProvider's full list to get PlaceModel objects.

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarks = context.watch<BookmarkProvider>();
    final places    = context.watch<PlaceProvider>();

    // I filter the full place list down to only the bookmarked ones
    final saved = places.allPlaces
        .where((p) => bookmarks.isBookmarked(p.id))
        .toList();

    return Scaffold(
      backgroundColor: kPrimaryDark,
      body: saved.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.bookmark_border,
              title: 'No bookmarks yet.',
              subtitle: 'Tap the bookmark icon on any place to save it here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: saved.length,
              itemBuilder: (context, i) {
                final place = saved[i];
                return PlaceCard(
                  place: place,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaceDetailScreen(place: place),
                    ),
                  ),
                );
              },
            ),
    );
  }
}