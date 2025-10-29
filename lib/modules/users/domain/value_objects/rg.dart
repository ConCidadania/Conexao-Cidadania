class Rg {
  final String value;

  const Rg._(this.value);

  factory Rg.parse(String input) {
    // Remove common separators but keep X for RG
    final cleaned = input.replaceAll(RegExp(r'[^\dX]'), '').toUpperCase();
    
    if (cleaned.isEmpty) {
      throw InvalidRgFailure('RG cannot be empty');
    }

    // Brazilian RG validation: 5-14 characters, can end with X
    if (cleaned.length < 5 || cleaned.length > 14) {
      throw InvalidRgFailure('RG must have between 5 and 14 characters');
    }

    // Check if it's all digits or ends with X
    if (!RegExp(r'^\d+$').hasMatch(cleaned) && !RegExp(r'^\d+X$').hasMatch(cleaned)) {
      throw InvalidRgFailure('RG must contain only digits or end with X');
    }

    return Rg._(cleaned);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rg && runtimeType == other.runtimeType && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

class InvalidRgFailure implements Exception {
  final String message;
  InvalidRgFailure(this.message);
}
