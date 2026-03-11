
# 🏙️ Kigali City Services & Places Directory

A mobile application built with **Flutter** and **Firebase** that lets residents and visitors in Kigali discover, add, and review important city places — hospitals, police stations, cafés, parks, restaurants, libraries, utility offices, and tourist attractions.

[![Flutter](https://img.shields.io/badge/Flutter-3.41.1-blue?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%7C%20Auth-orange?logo=firebase)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

> 📹 https://drive.google.com/file/d/12rFl-voxLCjezj6PysIMeDV1Dmdr28se/view?usp=sharing 🔗 [GitHub Repository](https://github.com/VeronicahWanjuu/kigali_city_services)

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔐 **User Authentication** | Email/password sign-up and login via Firebase Auth, with email verification enforced before access is granted |
| 📋 **Place Directory** | Browse all city listings with live search and category filter chips |
| 📍 **Place Detail** | Mini embedded OpenStreetMap, star rating summary, contact info, description, directions (Google Maps), and call button |
| ➕ **Add / Edit / Delete** | Authenticated users can create, edit, and delete their own listings |
| ⭐ **Reviews & Ratings** | Leave star ratings and written reviews; average rating and count update automatically in Firestore |
| 🔖 **Bookmarks** | Save any place with one tap; persists per user in Firestore |
| 🗺️ **Map View** | Full-screen OpenStreetMap with pin markers; tap a marker to open the place detail screen |
| ⚙️ **Settings** | Toggle push notification preference; sign out option |
| 📶 **Offline-Friendly** | Firestore persistence means cached data is available even when connectivity drops |

### Category Filters
`Hospital` · `Police Station` · `Café` · `Restaurant` · `Park` · `Library` · `Utility Office` · `Tourist Attraction`

---

## 🗄️ Firestore Database Structure

Four top-level collections:

| Collection / Path | Key Fields |
|---|---|
| `users/{uid}` | `uid`, `email`, `displayName`, `createdAt`, `notificationsEnabled` |
| `places/{placeId}` | `name`, `category`, `address`, `contactNumber`, `description`, `latitude`, `longitude`, `createdBy`, `creatorName`, `createdAt`, `updatedAt`, `averageRating`, `reviewCount`, `imageUrl` |
| `places/{placeId}/reviews/{reviewId}` | `userId`, `userName`, `rating` (double), `comment`, `createdAt` |
| `bookmarks/{uid}/places/{placeId}` | `placeId`, `savedAt` |

---

## 🏗️ State Management

The app uses the **Provider** package, organised in three clean layers:
```
UI Layer       → Screens & widgets (context.watch / context.read)
Provider Layer → AppAuthProvider, PlaceProvider, LocationProvider,
                 ReviewProvider, BookmarkProvider (extend ChangeNotifier)
Service Layer  → AuthService, PlaceService, ReviewService, BookmarkService
                 (pure Dart, no Flutter imports, talk directly to Firebase)
```

> ⚠️ `PlaceProvider` does **not** start its Firestore stream in the constructor. It is started from `MainScreen.initState()` using `addPostFrameCallback()`, after Firebase Auth confirms the user is logged in — preventing `PERMISSION_DENIED` errors.

---

## 📁 File Structure
```
kigali_city_services/
├── lib/
│   ├── main.dart
│   ├── firebase_options.dart        ← local only, never committed
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── place_model.dart
│   │   └── review_model.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   ├── place_service.dart
│   │   ├── review_service.dart
│   │   └── bookmark_service.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── place_provider.dart
│   │   ├── location_provider.dart
│   │   ├── review_provider.dart
│   │   └── bookmark_provider.dart
│   ├── screens/
│   │   ├── splash_screen.dart
│   │   ├── main_screen.dart
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── email_verification_screen.dart
│   │   ├── directory/
│   │   │   ├── directory_screen.dart
│   │   │   ├── place_detail_screen.dart
│   │   │   └── add_edit_place_screen.dart
│   │   ├── my_listings/
│   │   │   └── my_listings_screen.dart
│   │   ├── bookmarks/
│   │   │   └── bookmarks_screen.dart
│   │   ├── reviews/
│   │   │   └── reviews_screen.dart
│   │   ├── map/
│   │   │   └── map_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   └── widgets/
│       ├── place_card.dart
│       ├── category_filter_chips.dart
│       ├── star_display_widget.dart
│       ├── loading_overlay.dart
│       ├── empty_state_widget.dart
│       ├── shimmer_loading.dart
│       └── custom_snackbar.dart
│   └── utils/
│       ├── app_theme.dart
│       ├── constants.dart
│       └── distance_utils.dart
├── android/
│   └── app/
│       └── google-services.json     ← local only, never committed
└── test/
    └── widget_test.dart
```

---

## 🚀 How to Run

### Prerequisites

- Flutter **3.41.1** or later installed and on your `PATH`
- Android Studio or VS Code with the Flutter extension
- A physical Android device (USB debugging enabled) **OR** an Android emulator (API 23+)
- `firebase_options.dart` and `google-services.json` *(contact the developer — excluded from repo for security)*

### Steps

**1. Clone the repo**
```bash
git clone https://github.com/VeronicahWanjuu/kigali_city_services.git
cd kigali_city_services
```

**2. Add the Firebase config files**
```
Place lib/firebase_options.dart
Place android/app/google-services.json
```
Upon request since they are not in github 
**3. Install dependencies**
```bash
flutter pub get
```

**4. Connect your device or start an emulator**
- **Physical device:** Enable Developer Options → USB Debugging → plug in via USB
- **Emulator:** Open Android Studio → Device Manager → start any API 23+ AVD

**5. Run the app**
```bash
flutter run
```
```bash
# Run on a specific device
flutter run -d <device-id>

# List connected devices
flutter devices
```

**6. Hot reload / restart**
```
r   → hot reload
R   → hot restart
```

---

## 📦 Key Dependencies

| Package | Purpose |
|---|---|
| `firebase_core`, `firebase_auth` | Firebase initialisation and email/password auth |
| `cloud_firestore` | Real-time NoSQL database for all app data |
| `provider` | State management (ChangeNotifier pattern) |
| `flutter_map` + `latlong2` | Free OpenStreetMap tiles — no API key needed |
| `geolocator` | User's current location for distance calculation |
| `url_launcher` | Opens Google Maps for navigation and dial-pad for calls |
| `flutter_rating_bar` | Star rating input widget |
| `shimmer` | Loading skeleton animations |
| `intl` | Date formatting |

---

## 🔒 Security Note

`firebase_options.dart` and `android/app/google-services.json` are listed in `.gitignore` and are **not** committed to the repository.

> During development, `firebase_options.dart` was accidentally committed and pushed to GitHub. The incident was detected, all exposed keys were **rotated immediately**, and the files were removed from Git tracking.

---

*Built by **Veronicah Wambui Wanjuu***
