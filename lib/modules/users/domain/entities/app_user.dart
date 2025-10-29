import '../value_objects/user_id.dart';
import '../value_objects/user_type.dart';
import '../value_objects/email_address.dart';
import '../value_objects/phone_number.dart';
import '../value_objects/person_name.dart';
import '../value_objects/cpf.dart';
import '../value_objects/rg.dart';
import '../value_objects/oab.dart';
import '../value_objects/civil_status.dart';
import '../value_objects/gender.dart';
import '../value_objects/address.dart';
import '../value_objects/postal_code.dart';
import '../value_objects/state_code.dart';
import '../errors/user_failures.dart';

class AppUser {
  final UserId id;
  final UserType type;
  final EmailAddress email;
  final PhoneNumber phoneNumber;
  final PersonName name;
  final String profession;
  final Gender? gender;
  final CivilStatus? civilStatus;
  final DateTime? dateOfBirth;
  final Rg rg;
  final Cpf cpf;
  final String nationality;
  final String naturality;
  final Oab? registroOAB;
  final Address address;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.id,
    required this.type,
    required this.email,
    required this.phoneNumber,
    required this.name,
    required this.profession,
    this.gender,
    this.civilStatus,
    this.dateOfBirth,
    required this.rg,
    required this.cpf,
    required this.nationality,
    required this.naturality,
    this.registroOAB,
    required this.address,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.create({
    required UserId id,
    required UserType type,
    required EmailAddress email,
    required PhoneNumber phoneNumber,
    required PersonName name,
    required String profession,
    Gender? gender,
    CivilStatus? civilStatus,
    DateTime? dateOfBirth,
    required Rg rg,
    required Cpf cpf,
    required String nationality,
    required String naturality,
    Oab? registroOAB,
    required Address address,
  }) {
    // Validate business rules
    if (profession.trim().isEmpty) {
      throw ValidationFailure('Profession cannot be empty');
    }
    if (nationality.trim().isEmpty) {
      throw ValidationFailure('Nationality cannot be empty');
    }
    if (naturality.trim().isEmpty) {
      throw ValidationFailure('Naturality cannot be empty');
    }

    // For lawyers, OAB registration is required
    if (type == UserType.lawyer && registroOAB == null) {
      throw ValidationFailure('OAB registration is required for lawyers');
    }

    final now = DateTime.now();
    return AppUser(
      id: id,
      type: type,
      email: email,
      phoneNumber: phoneNumber,
      name: name,
      profession: profession.trim(),
      gender: gender,
      civilStatus: civilStatus,
      dateOfBirth: dateOfBirth,
      rg: rg,
      cpf: cpf,
      nationality: nationality.trim(),
      naturality: naturality.trim(),
      registroOAB: registroOAB,
      address: address,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory AppUser.createEmpty() {
    return AppUser(
      id: UserId.fromString(''),
      type: UserType.user,
      email: EmailAddress.parse('empty@example.com'),
      phoneNumber: PhoneNumber.parse('11999999999'),
      name: PersonName.create('Empty', 'User'),
      profession: '',
      rg: Rg.parse('123456789'),
      cpf: Cpf.parse('00000000000'),
      nationality: '',
      naturality: '',
      address: Address.create(
        street: '',
        number: '',
        neighborhood: '',
        city: '',
        state: StateCode.sp,
        country: '',
        postalCode: PostalCode.parse('00000000'),
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  AppUser copyWith({
    UserId? id,
    UserType? type,
    EmailAddress? email,
    PhoneNumber? phoneNumber,
    PersonName? name,
    String? profession,
    Gender? gender,
    CivilStatus? civilStatus,
    DateTime? dateOfBirth,
    Rg? rg,
    Cpf? cpf,
    String? nationality,
    String? naturality,
    Oab? registroOAB,
    Address? address,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      type: type ?? this.type,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      profession: profession ?? this.profession,
      gender: gender ?? this.gender,
      civilStatus: civilStatus ?? this.civilStatus,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      rg: rg ?? this.rg,
      cpf: cpf ?? this.cpf,
      nationality: nationality ?? this.nationality,
      naturality: naturality ?? this.naturality,
      registroOAB: registroOAB ?? this.registroOAB,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  AppUser updateWith({
    UserType? type,
    EmailAddress? email,
    PhoneNumber? phoneNumber,
    PersonName? name,
    String? profession,
    Gender? gender,
    CivilStatus? civilStatus,
    DateTime? dateOfBirth,
    Rg? rg,
    Cpf? cpf,
    String? nationality,
    String? naturality,
    Oab? registroOAB,
    Address? address,
  }) {
    return copyWith(
      type: type,
      email: email,
      phoneNumber: phoneNumber,
      name: name,
      profession: profession,
      gender: gender,
      civilStatus: civilStatus,
      dateOfBirth: dateOfBirth,
      rg: rg,
      cpf: cpf,
      nationality: nationality,
      naturality: naturality,
      registroOAB: registroOAB,
      address: address,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'AppUser(id: ${id.value}, name: ${name.fullName}, email: ${email.value})';
}
