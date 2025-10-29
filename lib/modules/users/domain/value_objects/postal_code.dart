class PostalCode {
  final String value;

  const PostalCode._(this.value);

  factory PostalCode.parse(String input) {
    // Remove all non-digit characters
    final digits = input.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digits.length != 8) {
      throw InvalidPostalCodeFailure('Postal code must have exactly 8 digits');
    }

    // Format as NNNNN-NNN
    final formatted = '${digits.substring(0, 5)}-${digits.substring(5, 8)}';
    return PostalCode._(formatted);
  }

  String get digits => value.replaceAll('-', '');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostalCode && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidPostalCodeFailure implements Exception {
  final String message;
  InvalidPostalCodeFailure(this.message);
}
