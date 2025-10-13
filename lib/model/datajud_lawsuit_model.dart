// lib/source/models/processo_datajud_model.dart
class DatajudLawsuit {
  final String? classe;
  final String? area;
  final String? assunto;
  final String? dataAjuizamento;
  final String? orgaoJulgador;
  final List<Movimento> movimentos;

  DatajudLawsuit({
    this.classe,
    this.area,
    this.assunto,
    this.dataAjuizamento,
    this.orgaoJulgador,
    required this.movimentos,
  });

  factory DatajudLawsuit.fromJson(Map<String, dynamic> json) {
    // A estrutura do JSON de resposta deve ser analisada na documentação do Datajud
    // para um parsing preciso. Este é um exemplo.
    var movimentosList = json['movimentos'] as List? ?? [];
    List<Movimento> movimentos =
        movimentosList.map((i) => Movimento.fromJson(i)).toList();

    return DatajudLawsuit(
      classe: json['classe']?['nome'],
      area: json['area'],
      assunto: json['assuntos']?[0]
          ?['nome'], // Exemplo, pegando o primeiro assunto
      dataAjuizamento: json['dataAjuizamento'],
      orgaoJulgador: json['orgaoJulgador']?['nome'],
      movimentos: movimentos,
    );
  }

  // O último movimento geralmente indica o status mais recente.
  String? get ultimoStatus =>
      movimentos.isNotEmpty ? movimentos.first.nome : "Status não disponível";
}

class Movimento {
  final String? data;
  final String? nome;
  final String descricao;

  Movimento({this.data, this.nome, required this.descricao});

  factory Movimento.fromJson(Map<String, dynamic> json) {
    return Movimento(
      data: json['dataHora'],
      nome: json['nome'] ?? 'Dado Indisponível',
      descricao: json['movimentoNacional']?['descricao'] ??
          json['complemento'] ??
          'Movimento não descrito',
    );
  }
}