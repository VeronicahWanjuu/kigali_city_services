import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/place_provider.dart';
import '../utils/constants.dart';


// A scrollable row of filter chips, one per category.
// Each chip shows how many listings are in that category: 'Café 3'.
// I use context.watch in build and context.read in the callback


class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({super.key});


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlaceProvider>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: kCategories.map((cat) {
          final selected = provider.selectedCategory == cat;
          final count = provider.getCategoryCount(cat);
          final label = cat == 'All' ? 'All' : '$cat $count';
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: selected,
              // context.read in the callback is correct here
              onSelected: (_) => context.read<PlaceProvider>().setCategory(cat),
              selectedColor: kAccentGold,
              backgroundColor: kCardDark,
              checkmarkColor: Colors.black,
              labelStyle: TextStyle(
                color: selected ? Colors.black : kTextPrimary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
