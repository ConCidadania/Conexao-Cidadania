import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/value_objects/user_id.dart';
import '../../domain/value_objects/user_type.dart';
import '../../domain/value_objects/email_address.dart';
import '../../domain/value_objects/phone_number.dart';
import '../../domain/value_objects/person_name.dart';
import '../../domain/value_objects/cpf.dart';
import '../../domain/value_objects/rg.dart';
import '../../domain/value_objects/oab.dart';
import '../../domain/value_objects/civil_status.dart';
import '../../domain/value_objects/gender.dart';
import '../../domain/value_objects/address.dart';
import '../../domain/value_objects/postal_code.dart';
import '../../domain/value_objects/state_code.dart';
import '../../domain/errors/user_failures.dart';

class AppUserMapper {
  static Map<String, dynamic> toFirestore(AppUser user) {
    return {
      'uid': user.id.value,
      'type': user.type.code,
      'email': user.email.value,
      'phoneNumber': user.phoneNumber.value,
      'firstName': user.name.firstName,
      'lastName': user.name.lastName,
      'profession': user.profession,
      'gender': user.gender?.displayName,
      'civilStatus': user.civilStatus?.displayName,
      'dateOfBirth': user.dateOfBirth?.toIso8601String(),
      'rg': user.rg.value,
      'cpf': user.cpf.value,
      'nationality': user.nationality,
      'naturality': user.naturality,
      'registroOAB': user.registroOAB?.value,
      'street': user.address.street,
      'number': user.address.number,
      'complement': user.address.complement,
      'neighborhood': user.address.neighborhood,
      'city': user.address.city,
      'state': user.address.state.code,
      'country': user.address.country,
      'postalCode': user.address.postalCode.value,
      'createdAt': Timestamp.fromDate(user.createdAt),
      'updatedAt': Timestamp.fromDate(user.updatedAt),
    };
  }

  static AppUser fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      
      return AppUser(
        id: UserId.fromString(data['uid'] ?? doc.id),
        type: UserType.fromString(data['type'] ?? 'USER'),
        email: EmailAddress.parse(data['email'] ?? ''),
        phoneNumber: PhoneNumber.parse(data['phoneNumber'] ?? ''),
        name: PersonName.create(
          data['firstName'] ?? '',
          data['lastName'] ?? '',
        ),
        profession: data['profession'] ?? '',
        gender: data['gender'] != null ? Gender.fromString(data['gender']) : null,
        civilStatus: data['civilStatus'] != null ? CivilStatus.fromString(data['civilStatus']) : null,
        dateOfBirth: data['dateOfBirth'] != null 
            ? DateTime.parse(data['dateOfBirth']) 
            : null,
        rg: Rg.parse(data['rg'] ?? ''),
        cpf: Cpf.parse(data['cpf'] ?? ''),
        nationality: data['nationality'] ?? '',
        naturality: data['naturality'] ?? '',
        registroOAB: data['registroOAB'] != null 
            ? Oab.parse(data['registroOAB']) 
            : null,
        address: Address.create(
          street: data['street'] ?? '',
          number: data['number'] ?? '',
          complement: data['complement'],
          neighborhood: data['neighborhood'] ?? '',
          city: data['city'] ?? '',
          state: StateCode.fromString(data['state'] ?? 'SP'),
          country: data['country'] ?? '',
          postalCode: PostalCode.parse(data['postalCode'] ?? '00000000'),
        ),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    } catch (e) {
      throw RepositoryFailure('Failed to map user from Firestore: ${e.toString()}');
    }
  }

  static AppUser fromMap(Map<String, dynamic> data) {
    try {
      return AppUser(
        id: UserId.fromString(data['uid'] ?? ''),
        type: UserType.fromString(data['type'] ?? 'USER'),
        email: EmailAddress.parse(data['email'] ?? ''),
        phoneNumber: PhoneNumber.parse(data['phoneNumber'] ?? ''),
        name: PersonName.create(
          data['firstName'] ?? '',
          data['lastName'] ?? '',
        ),
        profession: data['profession'] ?? '',
        gender: data['gender'] != null ? Gender.fromString(data['gender']) : null,
        civilStatus: data['civilStatus'] != null ? CivilStatus.fromString(data['civilStatus']) : null,
        dateOfBirth: data['dateOfBirth'] != null 
            ? DateTime.parse(data['dateOfBirth']) 
            : null,
        rg: Rg.parse(data['rg'] ?? ''),
        cpf: Cpf.parse(data['cpf'] ?? ''),
        nationality: data['nationality'] ?? '',
        naturality: data['naturality'] ?? '',
        registroOAB: data['registroOAB'] != null 
            ? Oab.parse(data['registroOAB']) 
            : null,
        address: Address.create(
          street: data['street'] ?? '',
          number: data['number'] ?? '',
          complement: data['complement'],
          neighborhood: data['neighborhood'] ?? '',
          city: data['city'] ?? '',
          state: StateCode.fromString(data['state'] ?? 'SP'),
          country: data['country'] ?? '',
          postalCode: PostalCode.parse(data['postalCode'] ?? '00000000'),
        ),
        createdAt: data['createdAt'] is DateTime 
            ? data['createdAt'] 
            : DateTime.now(),
        updatedAt: data['updatedAt'] is DateTime 
            ? data['updatedAt'] 
            : DateTime.now(),
      );
    } catch (e) {
      throw RepositoryFailure('Failed to map user from map: ${e.toString()}');
    }
  }
}
