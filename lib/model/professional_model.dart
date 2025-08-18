import 'package:cloud_firestore/cloud_firestore.dart';

class Professional {
  final String id;
  final String name;
  final String specialty;
  final String description;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final double rating;

  Professional({
    required this.id,
    required this.name,
    required this.specialty,
    required this.description,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    this.rating = 0.0,
  });

  factory Professional.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Professional(
      id: doc.id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      description: data['description'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? data['profile_image_url'],
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'specialty': specialty,
      'description': description,
      'email': email,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'profile_image_url': profileImageUrl,
      'rating': rating,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Professional && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Professional(id: $id, name: $name, specialty: $specialty)';
  }
}
