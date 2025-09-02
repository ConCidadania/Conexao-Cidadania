import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType { user, admin, lawyer }

class AppUser {
  String uid;
  UserType type;
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
      type: data['type'] ?? UserType.user,
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
      type: UserType.user,
      email: '',
      phoneNumber: '',
      firstName: '',
      lastName: '',
      profession: '',
      rg: '',
      cpf: '',
      nationality: '',
      naturality: '',
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

}