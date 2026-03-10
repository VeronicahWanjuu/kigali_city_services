import 'package:flutter/material.dart';


// I put all the colours here so I can change them in one place
// instead of hunting through every single file.


const Color kPrimaryDark    = Color(0xFF0D1B2A);  // deep navy, the main background
const Color kCardDark       = Color(0xFF1A2D42);  // slightly lighter navy for cards
const Color kAccentGold     = Color(0xFFF5A623);  // gold used for buttons, stars, active items
const Color kTextPrimary    = Colors.white;
const Color kTextSecondary  = Color(0xFF8899AA);  // muted grey-blue for captions
const Color kErrorRed       = Color(0xFFE53935);


// These are the 8 place categories the app supports, plus 'All' for the filter.
// The dropdown skips 'All' since it's only used for filtering, not creating a place.
const List<String> kCategories = [
  'All',
  'Hospital',
  'Police Station',
  'Library',
  'Utility Office',
  'Restaurant',
  'Café',
  'Park',
  'Tourist Attraction',
];


// I reuse these text styles everywhere so the typography stays consistent
const TextStyle kHeadingLarge  = TextStyle(color: kTextPrimary, fontSize: 22, fontWeight: FontWeight.bold);
const TextStyle kHeadingMedium = TextStyle(color: kTextPrimary, fontSize: 18, fontWeight: FontWeight.bold);
const TextStyle kBodyText      = TextStyle(color: kTextPrimary, fontSize: 14);
const TextStyle kCaptionText   = TextStyle(color: kTextSecondary, fontSize: 12);
