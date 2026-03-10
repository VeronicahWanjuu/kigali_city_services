import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/place_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/place_card.dart';
import '../directory/add_edit_place_screen.dart';
import '../directory/place_detail_screen.dart';


class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final auth     = context.watch<AppAuthProvider>();
    final provider = context.watch<PlaceProvider>();
    final uid      = auth.currentUser?.uid ?? '';
    final myPlaces = provider.getUserPlaces(uid);
    return Scaffold(
      backgroundColor: kPrimaryDark,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccentGold,
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddEditPlaceScreen())),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: myPlaces.isEmpty
        ? EmptyStateWidget(
            icon: Icons.my_library_books_outlined,
            title: 'No listings yet',
            subtitle: 'Tap + to add your first place',
            buttonLabel: 'Add Place',
            onButtonTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddEditPlaceScreen())),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: myPlaces.length,
            itemBuilder: (_, i) {
              final p = myPlaces[i];
              return Dismissible(
                key: Key(p.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  color: kErrorRed,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (_) => showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: kCardDark,
                    title: const Text('Delete Place?', style: kHeadingMedium),
                    content: const Text('This cannot be undone.', style: kBodyText),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel', style: TextStyle(color: kTextSecondary))),
                      TextButton(onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete', style: TextStyle(color: kErrorRed))),
                    ],
                  ),
                ),
                onDismissed: (_) async {
                  final deleted = await context.read<PlaceProvider>()
                      .deletePlace(p.id, p.imageUrl);
                  if (context.mounted) {
                    CustomSnackbar.showSuccess(context, deleted ? 'Deleted' : 'Delete failed');
                  }
                },
                child: PlaceCard(
                  place: p,
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: p))),
                ),
              );
            },
          ),
    );
  }
}
