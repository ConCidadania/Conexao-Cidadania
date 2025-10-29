class Cpf {
  final String value;

  const Cpf._(this.value);

  factory Cpf.parse(String input) {
    // Remove all non-digit characters
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length != 11) {
      throw InvalidCpfFailure('CPF must have exactly 11 digits');
    }

    // Check for invalid patterns (all same digits)
    if (RegExp(r'^(\d)\1{10}$').hasMatch(digits)) {
      throw InvalidCpfFailure('Invalid CPF pattern');
    }

    // Validate check digits
    if (!_isValidCpf(digits)) {
      throw InvalidCpfFailure('Invalid CPF check digits');
    }

    return Cpf._(digits);
  }

  static bool _isValidCpf(String cpf) {
    // Calculate first check digit
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int firstCheck = (sum * 10) % 11;
    if (firstCheck == 10) firstCheck = 0;

    // Calculate second check digit
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int secondCheck = (sum * 10) % 11;
    if (secondCheck == 10) secondCheck = 0;

    return firstCheck == int.parse(cpf[9]) && secondCheck == int.parse(cpf[10]);
  }

  String get formatted => '${value.substring(0, 3)}.${value.substring(3, 6)}.${value.substring(6, 9)}-${value.substring(9, 11)}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cpf && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidCpfFailure implements Exception {
  final String message;
  InvalidCpfFailure(this.message);
}
