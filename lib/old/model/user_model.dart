// ignore_for_file: constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { USER, ADMIN, LAWYER }

class AppUser {
  String uid;
  String type;
  String email;
  String phoneNumber;
  String firstName;
  String lastName;
  String profession;
  String? gender;
  String? civilStatus;
  String? dateOfBirth;
  String rg;
  String cpf;
  String nationality;
  String naturality;
  String registroOAB;

  // Address
  String street;
  String number;
  String? complement;
  String neighborhood;
  String city;
  String state;
  String country;
  String postalCode;

  final Timestamp createdAt;
  final Timestamp updatedAt;

  AppUser({
    required this.uid,
    required this.type,
    required this.email,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.profession,
    this.gender,
    this.civilStatus,
    this.dateOfBirth,
    required this.rg,
    required this.cpf,
    required this.nationality,
    required this.naturality,
    required this.registroOAB,
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      type: data['type'] ?? UserType.USER.name,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      profession: data['profession'] ?? '',
      gender: data['gender'] ?? '',
      civilStatus: data['civilStatus'] ?? '',
      dateOfBirth: data['dateOfBirth'] ?? '',
      rg: data['rg'] ?? '',
      cpf: data['cpf'] ?? '',
      nationality: data['nationality'] ?? '',
      naturality: data['naturality'] ?? '',
      registroOAB: data['registroOAB'] ?? '',
      street: data['street'] ?? '',
      number: data['number'] ?? '',
      complement: data['complement'] ?? '',
      neighborhood: data['neighborhood'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      postalCode: data['postalCode'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      updatedAt: data['updatedAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'type': type,
      'email': email,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'profession': profession,
      'gender': gender,
      'civilStatus': civilStatus,
      'dateOfBirth': dateOfBirth,
      'rg': rg,
      'cpf': cpf,
      'nationality': nationality,
      'naturality': naturality,
      'registroOAB': registroOAB,
      'street': street,
      'number': number,
      'complement': complement,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static AppUser createEmpty() {
    return AppUser(
      uid: '',
      type: UserType.USER.name,
      email: '',
      phoneNumber: '',
      firstName: '',
      lastName: '',
      profession: '',
      rg: '',
      cpf: '',
      nationality: '',
      naturality: '',
      registroOAB: '',
      street: '',
      number: '',
      neighborhood: '',
      city: '',
      state: '',
      country: '',
      postalCode: '',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
  }

  AppUser copyWith({
    String? uid,
    String? type,
    String? email,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? profession,
    String? gender,
    String? civilStatus,
    String? dateOfBirth,
    String? rg,
    String? cpf,
    String? nationality,
    String? naturality,
    String? registroOAB,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      type: type ?? this.type,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profession: profession ?? this.profession,
      gender: gender ?? this.gender,
      civilStatus: civilStatus ?? this.civilStatus,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      rg: rg ?? this.rg,
      cpf: cpf ?? this.cpf,
      nationality: nationality ?? this.nationality,
      naturality: naturality ?? this.naturality,
      registroOAB: registroOAB ?? this.registroOAB,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

}