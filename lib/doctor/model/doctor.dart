class Doctor {
  final String uid;
  final String category;
  final String city;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String profileImageUrl;
  final String qualification;
  final String phoneNumber;
  final String yearsOfExperience;
  final String offDay;
  final String openingTime;
  final String closeTime;
  final double latitude;
  final double longitude;
  final double averageRating;
  final int totalReviews;

  Doctor({
    required this.uid,
    required this.category,
    required this.city,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.profileImageUrl,
    required this.qualification,
    required this.phoneNumber,
    required this.yearsOfExperience,
    required this.latitude,
    required this.longitude,
    required this.averageRating,
    required this.totalReviews,
    required this.offDay,
    required this.openingTime,
    required this.closeTime,
  });

  factory Doctor.fromMap(Map<dynamic, dynamic> map, String uid) {
    return Doctor(
      uid: uid,
      category: map['category'] ?? '', // Default to empty string if null
      city: map['city'] ?? '',
      email: map['email'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      gender: map['gender'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      qualification: map['qualification'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      yearsOfExperience: map['yearsOfExperience'] ?? '',
      offDay: map['offDay'] ?? '',
      openingTime: map['openingTime'] ?? '',
      closeTime: map['closeTime'] ?? '',
      latitude: map['latitude'] ?? 0.0, // Default to 0.0 if null
      longitude: map['longitude'] ?? 0.0,
      averageRating:
          double.tryParse(map['averageRating']?.toString() ?? '0.0') ?? 0.0,
      totalReviews: int.tryParse(map['totalReviews']?.toString() ?? '0') ?? 0,
    );
  }
}
