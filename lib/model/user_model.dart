import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePictureUrl;
  final String? address;
  final String? rgCpf;
  final String? cnh;
  final String? rgCpfDocumentUrl;
  final String? cnhDocumentUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl,
    this.address,
    this.rgCpf,
    this.cnh,
    this.rgCpfDocumentUrl,
    this.cnhDocumentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return User(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? data['phone_number'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ??
          data['profile_picture_url'] ??
          data['profile_image_url'],
      address: data['address'],
      rgCpf: data['rgCpf'] ?? data['rg_cpf'],
      cnh: data['cnh'],
      rgCpfDocumentUrl: data['rgCpfDocumentUrl'] ??
          data['rg_cpf_document_url'] ??
          data['rg_url'],
      cnhDocumentUrl:
          data['cnhDocumentUrl'] ?? data['cnh_document_url'] ?? data['cnh_url'],
      createdAt: data['createdAt'] ?? data['created_at'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? data['updated_at'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'phone_number': phoneNumber, // Compatibilidade dupla
      'profilePictureUrl': profilePictureUrl,
      'profile_picture_url': profilePictureUrl, // Compatibilidade dupla
      'profile_image_url': profilePictureUrl, // Compatibilidade dupla
      'address': address,
      'rgCpf': rgCpf,
      'rg_cpf': rgCpf, // Compatibilidade dupla
      'cnh': cnh,
      'rgCpfDocumentUrl': rgCpfDocumentUrl,
      'rg_cpf_document_url': rgCpfDocumentUrl, // Compatibilidade dupla
      'rg_url': rgCpfDocumentUrl, // Compatibilidade dupla
      'cnhDocumentUrl': cnhDocumentUrl,
      'cnh_document_url': cnhDocumentUrl, // Compatibilidade dupla
      'cnh_url': cnhDocumentUrl, // Compatibilidade dupla
      'createdAt': createdAt,
      'created_at': createdAt, // Compatibilidade dupla
      'updatedAt': updatedAt,
      'updated_at': updatedAt, // Compatibilidade dupla
    };
  }

  User copyWith({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    String? address,
    String? rgCpf,
    String? cnh,
    String? rgCpfDocumentUrl,
    String? cnhDocumentUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      address: address ?? this.address,
      rgCpf: rgCpf ?? this.rgCpf,
      cnh: cnh ?? this.cnh,
      rgCpfDocumentUrl: rgCpfDocumentUrl ?? this.rgCpfDocumentUrl,
      cnhDocumentUrl: cnhDocumentUrl ?? this.cnhDocumentUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'User(uid: $uid, name: $name, email: $email)';
  }
}
