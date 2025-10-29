// Example of how to use the new DDD users module
// This demonstrates the separation of concerns and clean architecture

import '../domain/entities/app_user.dart';
import '../domain/value_objects/user_id.dart';
import '../domain/value_objects/user_type.dart';
import '../domain/value_objects/email_address.dart';
import '../domain/value_objects/phone_number.dart';
import '../domain/value_objects/person_name.dart';
import '../domain/value_objects/cpf.dart';
import '../domain/value_objects/rg.dart';
import '../domain/value_objects/gender.dart';
import '../domain/value_objects/civil_status.dart';
import '../domain/value_objects/address.dart';
import '../domain/value_objects/postal_code.dart';
import '../domain/value_objects/state_code.dart';

void main() {
  // Example: Creating a user with strict validation
  try {
    final user = AppUser.create(
      id: UserId.fromString('user123'),
      type: UserType.user,
      email: EmailAddress.parse('user@example.com'),
      phoneNumber: PhoneNumber.parse('11999999999'),
      name: PersonName.create('João', 'Silva'),
      profession: 'Desenvolvedor',
      gender: Gender.male,
      civilStatus: CivilStatus.single,
      dateOfBirth: DateTime(1990, 5, 15),
      rg: Rg.parse('123456789'),
      cpf: Cpf.parse('11144477735'), // Valid CPF
      nationality: 'Brasileira',
      naturality: 'São Paulo',
      address: Address.create(
        street: 'Rua das Flores',
        number: '123',
        complement: 'Apto 45',
        neighborhood: 'Centro',
        city: 'São Paulo',
        state: StateCode.sp,
        country: 'Brasil',
        postalCode: PostalCode.parse('01234567'),
      ),
    );

    print('User created successfully:');
    print('Name: ${user.name.fullName}');
    print('Email: ${user.email.value}');
    print('CPF: ${user.cpf.formatted}');
    print('Address: ${user.address.fullAddress}');
  } catch (e) {
    print('Error creating user: $e');
  }

  // Example: Value object validation
  print('\n--- Value Object Validation Examples ---');
  
  // Valid email
  try {
    final email = EmailAddress.parse('test@example.com');
    print('Valid email: ${email.value}');
  } catch (e) {
    print('Invalid email: $e');
  }

  // Invalid email
  try {
    final email = EmailAddress.parse('invalid-email');
    print('Valid email: ${email.value}');
  } catch (e) {
    print('Invalid email (expected): $e');
  }

  // Valid CPF
  try {
    final cpf = Cpf.parse('11144477735');
    print('Valid CPF: ${cpf.formatted}');
  } catch (e) {
    print('Invalid CPF: $e');
  }

  // Invalid CPF
  try {
    final cpf = Cpf.parse('11111111111');
    print('Valid CPF: ${cpf.value}');
  } catch (e) {
    print('Invalid CPF (expected): $e');
  }
}
