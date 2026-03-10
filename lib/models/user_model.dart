import 'package:cloud_firestore/cloud_firestore.dart';


// I use this model to hold all the info about whoever is logged in.
// I pull the data from the users/{uid} document right after login.
// I always convert the Firestore Timestamp to a Dart DateTime here


class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final DateTime createdAt;
  final bool notificationsEnabled;


  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.createdAt,
    required this.notificationsEnabled,
  });


  // this takes a Firestore snapshot and turns it into a UserModel I can actually use
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: d['uid'] ?? '',
      email: d['email'] ?? '',
      displayName: d['displayName'] ?? '',
      createdAt: d['createdAt'] != null
          ? (d['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      notificationsEnabled: d['notificationsEnabled'] ?? false,
    );
  }


 
  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'createdAt': Timestamp.fromDate(createdAt),
    'notificationsEnabled': notificationsEnabled,
  };



  UserModel copyWith({
    String? uid, String? email, String? displayName,
    DateTime? createdAt, bool? notificationsEnabled,
  }) => UserModel(
    uid: uid ?? this.uid,
    email: email ?? this.email,
    displayName: displayName ?? this.displayName,
    createdAt: createdAt ?? this.createdAt,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
  );
}
