/// User model for Firebase Authentication and Firestore user document.
///
/// This model is used for:
/// - Storing user profile data in Firestore
/// - Google Sign-In user data
/// - Guest mode (user is null in this case)
class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoURL;
  final String language;
  final DateTime createdAt;
  final DateTime lastLogin;
  final String? defaultAddressId;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoURL,
    this.language = 'en',
    required this.createdAt,
    required this.lastLogin,
    this.defaultAddressId,
  });

  /// Converts the user model to a Firestore document map.
  /// The 'uid' field is used as the document ID in Firestore.
  Map<String, dynamic> toMap() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        if (photoURL != null) 'photoURL': photoURL,
        'language': language,
        'createdAt': createdAt.toIso8601String(),
        'lastLogin': lastLogin.toIso8601String(),
        if (defaultAddressId != null) 'defaultAddressId': defaultAddressId,
      };

  /// Creates a UserModel from a Firestore document map.
  /// The 'uid' is the document ID, passed separately.
  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
        uid: (map['uid'] ?? '').toString(),
        displayName: (map['displayName'] ?? 'User').toString(),
        email: (map['email'] ?? '').toString(),
        photoURL: map['photoURL']?.toString(),
        language: (map['language'] ?? 'en').toString(),
        createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
        lastLogin: DateTime.tryParse(map['lastLogin'] ?? '') ?? DateTime.now(),
        defaultAddressId: map['defaultAddressId']?.toString(),
      );

  /// Creates a copy with updated fields.
  UserModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? photoURL,
    String? language,
    DateTime? createdAt,
    DateTime? lastLogin,
    String? defaultAddressId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      language: language ?? this.language,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, displayName: $displayName, email: $email)';
  }
}