import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/place_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/category_filter_chips.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/place_card.dart';
import '../../widgets/shimmer_loading.dart';
import 'place_detail_screen.dart';
import 'add_edit_place_screen.dart';


class DirectoryScreen extends StatelessWidget {
  const DirectoryScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaceProvider>();
    return Scaffold(
      backgroundColor: kPrimaryDark,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccentGold,
        onPressed: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddEditPlaceScreen())),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Column(
        children: [
          // search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (q) => context.read<PlaceProvider>().setSearchQuery(q),
              style: kBodyText,
              decoration: InputDecoration(
                hintText: 'Search places...',
                prefixIcon: const Icon(Icons.search, color: kTextSecondary),
                suffixIcon: provider.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: kTextSecondary),
                      onPressed: () => context.read<PlaceProvider>().clearFilters(),
                    )
                  : null,
              ),
            ),
          ),
          // category chips row
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: CategoryFilterChips(),
          ),
          // the actual list
          Expanded(child: _buildList(context, provider)),
        ],
      ),
    );
  }


  Widget _buildList(BuildContext context, PlaceProvider provider) {
    if (provider.state == PlaceState.loading) return const ShimmerLoading();
    if (provider.state == PlaceState.error) {
      return EmptyStateWidget(
        icon: Icons.error_outline, title: 'Error loading places',
        subtitle: provider.errorMessage,
      );
    }
    if (provider.filteredPlaces.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off,
        title: provider.searchQuery.isNotEmpty ? 'No results found' : 'No places yet',
        subtitle: 'Be the first to add a place!',
        buttonLabel: 'Add Place',
        onButtonTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const AddEditPlaceScreen())),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: provider.filteredPlaces.length,
      itemBuilder: (_, i) {
        final p = provider.filteredPlaces[i];
        return PlaceCard(
          place: p,
          onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => PlaceDetailScreen(place: p))),
        );
      },
    );
  }
}
