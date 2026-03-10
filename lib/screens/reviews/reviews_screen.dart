import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/star_display_widget.dart';

// I use this screen to show all reviews for a place and let the user add one.

class ReviewsScreen extends StatefulWidget {
  final PlaceModel place;
  const ReviewsScreen({required this.place, super.key});
  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final _commentCtrl = TextEditingController();
  double _rating = 3.0;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewProvider>().loadReviews(widget.place.id);
    });
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

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
      id: '',
      placeId:  widget.place.id,
      userId:   auth.currentUser?.uid ?? '',
      userName: auth.currentUser?.displayName ?? 'Anonymous',
      rating:   _rating,
      comment:  comment,
      createdAt: DateTime.now(),
    );
    final ok = await reviewProvider.addReview(review);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      _commentCtrl.clear();
      setState(() => _rating = 3.0);
      CustomSnackbar.showSuccess(context, 'Review submitted!');
    } else {
      CustomSnackbar.showError(context, 'Failed to submit. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = context.watch<ReviewProvider>().reviews;

    return LoadingOverlay(
      isLoading: _submitting,
      child: Scaffold(
        backgroundColor: kPrimaryDark,
        appBar: AppBar(title: Text('Reviews — ${widget.place.name}')),
        body: Column(
          children: [
            _buildForm(),
            const Divider(color: kCardDark, thickness: 1),
            Expanded(
              child: reviews.isEmpty
                  ? const EmptyStateWidget(
                      icon: Icons.rate_review_outlined,
                      title: 'No reviews yet.',
                      subtitle: 'Be the first to leave a review!',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      itemCount: reviews.length,
                      itemBuilder: (_, i) => _ReviewTile(review: reviews[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: kCardDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Leave a Review', style: kHeadingMedium),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => _rating = (i + 1).toDouble()),
              child: Icon(
                i < _rating ? Icons.star : Icons.star_border,
                color: kAccentGold, size: 30,
              ),
            )),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            style: kBodyText,
            decoration: const InputDecoration(
              labelText: 'Your comment',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: kAccentGold),
              child: const Text('Submit',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kCardDark,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(review.userName,
                  style: kBodyText.copyWith(fontWeight: FontWeight.bold)),
                StarDisplayWidget(rating: review.rating),
              ],
            ),
            const SizedBox(height: 4),
            Text(review.comment, style: kBodyText),
          ],
        ),
      ),
    );
  }
}