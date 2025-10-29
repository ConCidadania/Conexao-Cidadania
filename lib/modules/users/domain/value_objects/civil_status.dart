enum CivilStatus {
  single('Solteiro(a)'),
  married('Casado(a)'),
  divorced('Divorciado(a)'),
  widowed('Viúvo(a)'),
  separated('Separado(a)'),
  stableUnion('União Estável');

  const CivilStatus(this.displayName);
  final String displayName;

  static CivilStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'solteiro':
      case 'solteira':
      case 'single':
        return CivilStatus.single;
      case 'casado':
      case 'casada':
      case 'married':
        return CivilStatus.married;
      case 'divorciado':
      case 'divorciada':
      case 'divorced':
        return CivilStatus.divorced;
      case 'viúvo':
      case 'viúva':
      case 'widowed':
        return CivilStatus.widowed;
      case 'separado':
      case 'separada':
      case 'separated':
        return CivilStatus.separated;
      case 'união estável':
      case 'uniao estavel':
      case 'stable union':
        return CivilStatus.stableUnion;
      default:
        throw InvalidCivilStatusFailure('Invalid civil status: $value');
    }
  }
}

class InvalidCivilStatusFailure implements Exception {
  final String message;
  InvalidCivilStatusFailure(this.message);
}
