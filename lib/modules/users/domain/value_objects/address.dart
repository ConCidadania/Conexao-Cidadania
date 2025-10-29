import 'postal_code.dart';
import 'state_code.dart';

class Address {
  final String street;
  final String number;
  final String? complement;
  final String neighborhood;
  final String city;
  final StateCode state;
  final String country;
  final PostalCode postalCode;

  const Address({
    required this.street,
    required this.number,
    this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
  });

  factory Address.create({
    required String street,
    required String number,
    String? complement,
    required String neighborhood,
    required String city,
    required StateCode state,
    required String country,
    required PostalCode postalCode,
  }) {
    if (street.trim().isEmpty) {
      throw InvalidAddressFailure('Street cannot be empty');
    }
    if (number.trim().isEmpty) {
      throw InvalidAddressFailure('Number cannot be empty');
    }
    if (neighborhood.trim().isEmpty) {
      throw InvalidAddressFailure('Neighborhood cannot be empty');
    }
    if (city.trim().isEmpty) {
      throw InvalidAddressFailure('City cannot be empty');
    }
    if (country.trim().isEmpty) {
      throw InvalidAddressFailure('Country cannot be empty');
    }

    return Address(
      street: street.trim(),
      number: number.trim(),
      complement: complement?.trim(),
      neighborhood: neighborhood.trim(),
      city: city.trim(),
      state: state,
      country: country.trim(),
      postalCode: postalCode,
    );
  }

  String get fullAddress => [
        '$street, $number',
        if (complement != null) complement,
        neighborhood,
        '$city - ${state.code}',
        postalCode.value,
        country,
      ].join(', ');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          street == other.street &&
          number == other.number &&
          complement == other.complement &&
          neighborhood == other.neighborhood &&
          city == other.city &&
          state == other.state &&
          country == other.country &&
          postalCode == other.postalCode;

  @override
  int get hashCode =>
      street.hashCode ^
      number.hashCode ^
      complement.hashCode ^
      neighborhood.hashCode ^
      city.hashCode ^
      state.hashCode ^
      country.hashCode ^
      postalCode.hashCode;

  @override
  String toString() => fullAddress;
}

class InvalidAddressFailure implements Exception {
  final String message;
  InvalidAddressFailure(this.message);
}
