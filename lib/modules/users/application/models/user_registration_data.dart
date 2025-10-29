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

class UserRegistrationData {
  // Step 1: Personal Info 1
  String firstName = '';
  String lastName = '';
  String profession = '';
  Gender? gender;
  CivilStatus? civilStatus;

  // Step 2: Personal Info 2
  DateTime? dateOfBirth;
  String rg = '';
  String cpf = '';
  String nationality = '';
  String naturality = '';

  // Step 3: Address Info
  String street = '';
  String number = '';
  String? complement;
  String neighborhood = '';
  String city = '';
  String state = '';
  String country = 'Brasil';
  String postalCode = '';

  // Step 4: Auth Info
  String email = '';
  String phoneNumber = '';
  String password = '';
  Oab? registroOAB;

  UserRegistrationData();

  // Step update methods
  void updatePersonalInfo1({
    required String firstName,
    required String lastName,
    required String profession,
    Gender? gender,
    CivilStatus? civilStatus,
  }) {
    this.firstName = firstName.trim();
    this.lastName = lastName.trim();
    this.profession = profession.trim();
    this.gender = gender;
    this.civilStatus = civilStatus;
  }

  void updatePersonalInfo2({
    required DateTime dateOfBirth,
    required String rg,
    required String cpf,
    required String nationality,
    required String naturality,
  }) {
    this.dateOfBirth = dateOfBirth;
    this.rg = rg.trim();
    this.cpf = cpf.trim();
    this.nationality = nationality.trim();
    this.naturality = naturality.trim();
  }

  void updateAddressInfo({
    required String street,
    required String number,
    String? complement,
    required String neighborhood,
    required String city,
    required String state,
    required String country,
    required String postalCode,
  }) {
    this.street = street.trim();
    this.number = number.trim();
    this.complement = complement?.trim();
    this.neighborhood = neighborhood.trim();
    this.city = city.trim();
    this.state = state.trim();
    this.country = country.trim();
    this.postalCode = postalCode.trim();
  }

  void updateAuthInfo({
    required String email,
    required String phoneNumber,
    required String password,
    Oab? registroOAB,
  }) {
    this.email = email.trim();
    this.phoneNumber = phoneNumber.trim();
    this.password = password;
    this.registroOAB = registroOAB;
  }

  // Validation methods
  bool isStep1Complete() {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        profession.isNotEmpty &&
        gender != null &&
        civilStatus != null;
  }

  bool isStep2Complete() {
    return dateOfBirth != null &&
        rg.isNotEmpty &&
        cpf.isNotEmpty &&
        nationality.isNotEmpty &&
        naturality.isNotEmpty;
  }

  bool isStep3Complete() {
    return street.isNotEmpty &&
        number.isNotEmpty &&
        neighborhood.isNotEmpty &&
        city.isNotEmpty &&
        state.isNotEmpty &&
        country.isNotEmpty &&
        postalCode.isNotEmpty;
  }

  bool isStep4Complete() {
    return email.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        password.isNotEmpty;
  }

  bool isComplete() {
    return isStep1Complete() &&
        isStep2Complete() &&
        isStep3Complete() &&
        isStep4Complete();
  }

  // Convert to AppUser entity
  AppUser toAppUser({required UserId userId}) {
    if (!isComplete()) {
      throw ValidationFailure('Registration data is incomplete');
    }

    try {
      // Parse value objects
      final emailAddress = EmailAddress.parse(email);
      final phone = PhoneNumber.parse(phoneNumber);
      final personName = PersonName.create(firstName, lastName);
      final cpfValue = Cpf.parse(cpf);
      final rgValue = Rg.parse(rg);
      final postalCodeValue = PostalCode.parse(postalCode);
      final stateCode = StateCode.fromString(state);

      // Create address
      final address = Address.create(
        street: street,
        number: number,
        complement: complement,
        neighborhood: neighborhood,
        city: city,
        state: stateCode,
        country: country,
        postalCode: postalCodeValue,
      );

      // Determine user type based on OAB registration
      final userType = registroOAB != null ? UserType.lawyer : UserType.user;

      // Create AppUser
      return AppUser.create(
        id: userId,
        type: userType,
        email: emailAddress,
        phoneNumber: phone,
        name: personName,
        profession: profession,
        gender: gender,
        civilStatus: civilStatus,
        dateOfBirth: dateOfBirth,
        rg: rgValue,
        cpf: cpfValue,
        nationality: nationality,
        naturality: naturality,
        registroOAB: registroOAB,
        address: address,
      );
    } catch (e) {
      if (e is UserFailure) rethrow;
      throw ValidationFailure('Invalid registration data: ${e.toString()}');
    }
  }

  // Clear all data
  void clear() {
    firstName = '';
    lastName = '';
    profession = '';
    gender = null;
    civilStatus = null;
    dateOfBirth = null;
    rg = '';
    cpf = '';
    nationality = '';
    naturality = '';
    street = '';
    number = '';
    complement = null;
    neighborhood = '';
    city = '';
    state = '';
    country = 'Brasil';
    postalCode = '';
    email = '';
    phoneNumber = '';
    password = '';
    registroOAB = null;
  }

  // Copy with method for partial updates
  UserRegistrationData copyWith({
    String? firstName,
    String? lastName,
    String? profession,
    Gender? gender,
    CivilStatus? civilStatus,
    DateTime? dateOfBirth,
    String? rg,
    String? cpf,
    String? nationality,
    String? naturality,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? email,
    String? phoneNumber,
    String? password,
    Oab? registroOAB,
  }) {
    final copy = UserRegistrationData();
    copy.firstName = firstName ?? this.firstName;
    copy.lastName = lastName ?? this.lastName;
    copy.profession = profession ?? this.profession;
    copy.gender = gender ?? this.gender;
    copy.civilStatus = civilStatus ?? this.civilStatus;
    copy.dateOfBirth = dateOfBirth ?? this.dateOfBirth;
    copy.rg = rg ?? this.rg;
    copy.cpf = cpf ?? this.cpf;
    copy.nationality = nationality ?? this.nationality;
    copy.naturality = naturality ?? this.naturality;
    copy.street = street ?? this.street;
    copy.number = number ?? this.number;
    copy.complement = complement ?? this.complement;
    copy.neighborhood = neighborhood ?? this.neighborhood;
    copy.city = city ?? this.city;
    copy.state = state ?? this.state;
    copy.country = country ?? this.country;
    copy.postalCode = postalCode ?? this.postalCode;
    copy.email = email ?? this.email;
    copy.phoneNumber = phoneNumber ?? this.phoneNumber;
    copy.password = password ?? this.password;
    copy.registroOAB = registroOAB ?? this.registroOAB;
    return copy;
  }
}
