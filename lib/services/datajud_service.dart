import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:con_cidadania/model/datajud_lawsuit_model.dart';

class DatajudService {
  //final String _baseUrl = "https://api-publica.datajud.cnj.jus.br/api_publica_tjsp/_search";
  final String _baseUrl =
      "https://api-publica.datajud.cnj.jus.br/api_publica_trf1/_search";
  final String apiKey =
      'cDZHYzlZa0JadVREZDJCendQbXY6SkJlTzNjLV9TRENyQk1RdnFKZGRQdw==';

  Future<DatajudLawsuit?> consultarProcesso(String numeroProcesso) async {
    try {
      final http.Response response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'ApiKey $apiKey',
          'Content-Type': 'application/json'
        },
        body: json.encode({
          "query": {
            "match": {"numeroProcesso": numeroProcesso}
          }
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        // A resposta da API pode ser uma lista de resultados.
        // Adapte o parsing conforme a estrutura exata da resposta.
        if (responseBody['hits']['hits'].isNotEmpty) {
          final dadosProcesso = responseBody['hits']['hits'][0]['_source'];
          return DatajudLawsuit.fromJson(dadosProcesso);
        }
        return null;
      } else {
        // Tratar erros de resposta da API (ex: 404, 500)
        print("Erro ao consultar Datajud: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      // Tratar erros de conexão ou outros imprevistos
      print("Exceção ao consultar Datajud: $e");
      return null;
    }
  }
}
