class PhoneNumber {
  final String value;

  const PhoneNumber._(this.value);

  factory PhoneNumber.parse(String input) {
    // Remove all non-digit characters
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.isEmpty) {
      throw InvalidPhoneFailure('Phone number cannot be empty');
    }

    // Brazilian phone number validation (10 or 11 digits)
    if (digits.length < 10 || digits.length > 11) {
      throw InvalidPhoneFailure('Phone number must have 10 or 11 digits');
    }

    // Format as E.164 for Brazil (+55)
    final formatted = '+55$digits';
    return PhoneNumber._(formatted);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneNumber && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidPhoneFailure implements Exception {
  final String message;
  InvalidPhoneFailure(this.message);
}
