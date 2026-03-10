import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/place_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookmark_provider.dart';
import '../../providers/review_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/star_display_widget.dart';
import 'add_edit_place_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final PlaceModel place;
  const PlaceDetailScreen({required this.place, super.key});
  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviews(widget.place.id);
    });
  }

  // I store canLaunchUrl result before touching context
  // so there is no async gap warning
  Future<void> _openDirections() async {
    final lat = widget.place.latitude;
    final lng = widget.place.longitude;
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    final canLaunch = await canLaunchUrl(url);
    if (!mounted) return;
    if (canLaunch) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      CustomSnackbar.showError(context, 'Could not open maps.');
    }
  }

  Future<void> _callPlace() async {
    final url = Uri.parse('tel:${widget.place.contactNumber}');
    final canLaunch = await canLaunchUrl(url);
    if (!mounted) return;
    if (canLaunch) {
      await launchUrl(url);
    } else {
      CustomSnackbar.showError(context, 'Cannot make call.');
    }
  }

  // I extracted this into a named method on State so the mounted check
  // correctly guards State.context — the linter requires this
  Future<void> _toggleBookmark(
      AppAuthProvider auth, PlaceModel place, bool wasBookmarked) async {
    final uid          = auth.currentUser?.uid ?? '';
    final bookmarkProv = context.read<BookmarkProvider>();
    await bookmarkProv.toggleBookmark(uid, place.id);
    if (!mounted) return;
    CustomSnackbar.showSuccess(
      context, wasBookmarked ? 'Removed bookmark' : 'Bookmarked!');
  }

  @override
  Widget build(BuildContext context) {
    final place        = widget.place;
    final auth         = context.watch<AppAuthProvider>();
    final bookmarks    = context.watch<BookmarkProvider>();
    final reviews      = context.watch<ReviewProvider>();
    final isOwner      = auth.currentUser?.uid == place.createdBy;
    final isBookmarked = bookmarks.isBookmarked(place.id);

    return Scaffold(
      backgroundColor: kPrimaryDark,
      appBar: AppBar(
        title: Text(place.name),
        actions: [
          // bookmark icon turns gold when saved
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? kAccentGold : kTextPrimary,
            ),
            onPressed: () => _toggleBookmark(auth, place, isBookmarked),
          ),
          // I only show the edit button to the person who created this listing
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit, color: kAccentGold),
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => AddEditPlaceScreen(place: place))),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // map with a gold pin
            SizedBox(
              height: 220,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(place.latitude, place.longitude),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.kigali.kigali_directory',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(place.latitude, place.longitude),
                      width: 40, height: 40,
                      child: const Icon(Icons.location_pin, color: kAccentGold, size: 40),
                    ),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kAccentGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(place.category,
                      style: const TextStyle(color: kAccentGold, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  Text(place.name, style: kHeadingLarge),
                  const SizedBox(height: 8),
                  Row(children: [
                    StarDisplayWidget(rating: place.averageRating, size: 18),
                    const SizedBox(width: 6),
                    Text('${place.averageRating} (${place.reviewCount} reviews)',
                      style: kCaptionText),
                  ]),
                  const SizedBox(height: 16),
                  _infoRow(Icons.location_on, place.address),
                  const SizedBox(height: 8),
                  _infoRow(Icons.phone, place.contactNumber),
                  const SizedBox(height: 16),
                  Text(place.description, style: kBodyText),
                  const SizedBox(height: 8),
                  Text('Added by ${place.creatorName}', style: kCaptionText),
                  const SizedBox(height: 24),
                  Row(children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openDirections,
                        icon: const Icon(Icons.directions),
                        label: const Text('Directions'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _callPlace,
                        icon: const Icon(Icons.phone, color: kAccentGold),
                        label: const Text('Call', style: TextStyle(color: kAccentGold)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kAccentGold),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 32),
                  const Text('Reviews', style: kHeadingMedium),
                  const SizedBox(height: 12),
                  _AddReviewWidget(placeId: place.id),
                  const SizedBox(height: 16),
                  ...reviews.reviews.map((r) => _ReviewCard(review: r)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
    children: [
      Icon(icon, color: kAccentGold, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: kBodyText)),
    ],
  );
}

// I put the review form in its own stateful widget to keep _PlaceDetailScreenState smaller
class _AddReviewWidget extends StatefulWidget {
  final String placeId;
  const _AddReviewWidget({required this.placeId});
  @override
  State<_AddReviewWidget> createState() => _AddReviewWidgetState();
}

class _AddReviewWidgetState extends State<_AddReviewWidget> {
  final _commentCtrl = TextEditingController();
  double _rating = 3.0;
  bool _submitting = false;

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final comment = _commentCtrl.text.trim();
    if (comment.isEmpty) {
      CustomSnackbar.showError(context, 'Please write a comment.');
      return;
    }
    setState(() => _submitting = true);
    // I store these before the await so I don't use context across an async gap
    final auth           = context.read<AppAuthProvider>();
    final reviewProvider = context.read<ReviewProvider>();
    final review = Review(
      id: '', placeId: widget.placeId,
      userId:   auth.currentUser?.uid ?? '',
      userName: auth.currentUser?.displayName ?? '',
      rating: _rating, comment: comment, createdAt: DateTime.now(),
    );
    final success = await reviewProvider.addReview(review);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      _commentCtrl.clear();
      setState(() => _rating = 3.0);
      CustomSnackbar.showSuccess(context, 'Review added!');
    } else {
      CustomSnackbar.showError(context, 'Failed to add review.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: kCardDark, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Leave a Review', style: kBodyText),
        const SizedBox(height: 8),
        Row(children: List.generate(5, (i) => GestureDetector(
          onTap: () => setState(() => _rating = (i + 1).toDouble()),
          child: Icon(i < _rating ? Icons.star : Icons.star_border,
            color: kAccentGold, size: 28),
        ))),
        const SizedBox(height: 8),
        TextField(controller: _commentCtrl, maxLines: 2,
          decoration: const InputDecoration(hintText: 'Write your review...'),
          style: kBodyText),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: Text(_submitting ? 'Submitting...' : 'Submit Review'),
          )),
      ]),
    );
  }
}

// individual review card
class _ReviewCard extends StatelessWidget {
  final Review review;
  const _ReviewCard({required this.review});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: kCardDark, borderRadius: BorderRadius.circular(10)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(review.userName, style: kBodyText.copyWith(fontWeight: FontWeight.bold)),
        StarDisplayWidget(rating: review.rating, size: 14),
      ]),
      const SizedBox(height: 4),
      Text(review.comment, style: kBodyText),
    ]),
  );
}