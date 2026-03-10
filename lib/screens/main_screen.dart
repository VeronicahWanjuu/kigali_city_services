import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/place_provider.dart';
import '../providers/location_provider.dart';
import '../providers/bookmark_provider.dart';
import '../utils/constants.dart';
import 'directory/directory_screen.dart';
import 'my_listings/my_listings_screen.dart';
import 'map/map_screen.dart';
import 'settings/settings_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;


  @override
  void initState() {
    super.initState();
    // I use addPostFrameCallback so the widget tree is fully built before I call providers.
    // I start the Firestore stream here  not in PlaceProvider's constructor
    // so I know for certain the user is authenticated before Firestore is accessed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaceProvider>().startListening();
      context.read<LocationProvider>().requestLocation();
      final uid = context.read<AppAuthProvider>().currentUser?.uid;
      if (uid != null) context.read<BookmarkProvider>().loadBookmarks(uid);
    });
  }


  static const _titles = ['Directory', 'My Listings', 'Map View', 'Settings'];


  static const _screens = [
    DirectoryScreen(),
    MyListingsScreen(),
    MapScreen(),
    SettingsScreen(),
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryDark,
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Directory'),
          BottomNavigationBarItem(icon: Icon(Icons.my_library_books), label: 'My Listings'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map View'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
