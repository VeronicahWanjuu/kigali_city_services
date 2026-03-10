import 'package:cloud_firestore/cloud_firestore.dart';


// PlaceModel is one document from the 'places' collection in Firestore.
// I store all the fields a place needs: name, category, address,
// contact number, description, coordinates, who created it, and ratings.


class PlaceModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contactNumber;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy;      
  final String creatorName;     
  final DateTime createdAt;
  final DateTime updatedAt;
  final double averageRating;   
  final int reviewCount;
  final String? imageUrl;     


  PlaceModel({
    required this.id, required this.name, required this.category,
    required this.address, required this.contactNumber,
    required this.description, required this.latitude,
    required this.longitude, required this.createdBy,
    required this.creatorName, required this.createdAt,
    required this.updatedAt,
    this.averageRating = 0.0, this.reviewCount = 0, this.imageUrl,
  });


  // Firestore sends numbers as 'num' so I have to call .toDouble() or Dart complains
  factory PlaceModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PlaceModel(
      id: doc.id,
      name: d['name'] ?? '',
      category: d['category'] ?? '',
      address: d['address'] ?? '',
      contactNumber: d['contactNumber'] ?? '',
      description: d['description'] ?? '',
      latitude: (d['latitude'] ?? 0.0).toDouble(),
      longitude: (d['longitude'] ?? 0.0).toDouble(),
      createdBy: d['createdBy'] ?? '',
      creatorName: d['creatorName'] ?? '',
      createdAt: d['createdAt'] != null
          ? (d['createdAt'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: d['updatedAt'] != null
          ? (d['updatedAt'] as Timestamp).toDate() : DateTime.now(),
      averageRating: (d['averageRating'] ?? 0.0).toDouble(),
      reviewCount: (d['reviewCount'] ?? 0) as int,
      imageUrl: d['imageUrl'] as String?,
    );
  }


  Map<String, dynamic> toMap() => {
    'name': name, 'category': category, 'address': address,
    'contactNumber': contactNumber, 'description': description,
    'latitude': latitude, 'longitude': longitude,
    'createdBy': createdBy, 'creatorName': creatorName,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'averageRating': averageRating, 'reviewCount': reviewCount,
    'imageUrl': imageUrl,
  };


  PlaceModel copyWith({
    String? id, String? name, String? category, String? address,
    String? contactNumber, String? description,
    double? latitude, double? longitude,
    String? createdBy, String? creatorName,
    DateTime? createdAt, DateTime? updatedAt,
    double? averageRating, int? reviewCount, String? imageUrl,
  }) => PlaceModel(
    id: id ?? this.id, name: name ?? this.name,
    category: category ?? this.category, address: address ?? this.address,
    contactNumber: contactNumber ?? this.contactNumber,
    description: description ?? this.description,
    latitude: latitude ?? this.latitude, longitude: longitude ?? this.longitude,
    createdBy: createdBy ?? this.createdBy, creatorName: creatorName ?? this.creatorName,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    averageRating: averageRating ?? this.averageRating,
    reviewCount: reviewCount ?? this.reviewCount,
    imageUrl: imageUrl ?? this.imageUrl,
  );
}
