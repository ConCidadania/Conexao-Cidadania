// Simple test to demonstrate CPF validation works
// This would be replaced with proper unit tests using a testing framework

import '../cpf.dart';

void main() {
  // Test valid CPF
  try {
    final cpf = Cpf.parse('11144477735');
    print('Valid CPF: ${cpf.value} -> ${cpf.formatted}');
  } catch (e) {
    print('Invalid CPF: $e');
  }

  // Test invalid CPF (all same digits)
  try {
    final cpf = Cpf.parse('11111111111');
    print('Valid CPF: ${cpf.value}');
  } catch (e) {
    print('Invalid CPF (expected): $e');
  }

  // Test invalid CPF (wrong check digits)
  try {
    final cpf = Cpf.parse('11144477734');
    print('Valid CPF: ${cpf.value}');
  } catch (e) {
    print('Invalid CPF (expected): $e');
  }
}
