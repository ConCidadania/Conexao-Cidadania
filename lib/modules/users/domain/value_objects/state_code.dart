enum StateCode {
  ac('AC', 'Acre'),
  al('AL', 'Alagoas'),
  ap('AP', 'Amapá'),
  am('AM', 'Amazonas'),
  ba('BA', 'Bahia'),
  ce('CE', 'Ceará'),
  df('DF', 'Distrito Federal'),
  es('ES', 'Espírito Santo'),
  go('GO', 'Goiás'),
  ma('MA', 'Maranhão'),
  mt('MT', 'Mato Grosso'),
  ms('MS', 'Mato Grosso do Sul'),
  mg('MG', 'Minas Gerais'),
  pa('PA', 'Pará'),
  pb('PB', 'Paraíba'),
  pr('PR', 'Paraná'),
  pe('PE', 'Pernambuco'),
  pi('PI', 'Piauí'),
  rj('RJ', 'Rio de Janeiro'),
  rn('RN', 'Rio Grande do Norte'),
  rs('RS', 'Rio Grande do Sul'),
  ro('RO', 'Rondônia'),
  rr('RR', 'Roraima'),
  sc('SC', 'Santa Catarina'),
  sp('SP', 'São Paulo'),
  se('SE', 'Sergipe'),
  to('TO', 'Tocantins');

  const StateCode(this.code, this.name);
  final String code;
  final String name;

  static StateCode fromString(String value) {
    final upperValue = value.toUpperCase();
    
    for (final state in StateCode.values) {
      if (state.code == upperValue || state.name.toUpperCase() == upperValue) {
        return state;
      }
    }
    
    throw InvalidStateCodeFailure('Invalid state code: $value');
  }
}

class InvalidStateCodeFailure implements Exception {
  final String message;
  InvalidStateCodeFailure(this.message);
}
