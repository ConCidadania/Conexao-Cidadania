// Em uma tela como 'lib/telas/detalhes_acao_screen.dart' (exemplo)
import 'package:con_cidadania/model/processo_datajud_model.dart'; // Presumindo a existência deste import
import 'package:con_cidadania/services/datajud_service.dart'; // Presumindo a existência deste import
import 'package:flutter/material.dart';

class DetalhesAcaoScreen extends StatefulWidget {
  final String numeroProcesso; // Recebido da tela anterior

  const DetalhesAcaoScreen({Key? key, required this.numeroProcesso})
      : super(key: key);

  @override
  _DetalhesAcaoScreenState createState() => _DetalhesAcaoScreenState();
}

class _DetalhesAcaoScreenState extends State<DetalhesAcaoScreen> {
  late Future<ProcessoDatajud?> _processoFuture;
  final DatajudService _datajudService = DatajudService();

  @override
  void initState() {
    super.initState();
    // Inicia a busca na API assim que a tela é construída
    _processoFuture = _datajudService.consultarProcesso(widget.numeroProcesso);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Acompanhamento Processual"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Processo Nº:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(widget.numeroProcesso, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  // Refaz a chamada à API ao pressionar o botão
                  _processoFuture =
                      _datajudService.consultarProcesso(widget.numeroProcesso);
                });
              },
              icon: Icon(Icons.refresh),
              label: Text("Atualizar Status"),
            ),
            SizedBox(height: 16),
            Text(
              "Status no Tribunal de Justiça:",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Theme.of(context).primaryColor),
            ),
            Divider(),
            // Expanded garante que o FutureBuilder ocupe o espaço restante,
            // permitindo que a ListView interna seja rolável.
            Expanded(
              child: FutureBuilder<ProcessoDatajud?>(
                future: _processoFuture,
                builder: (context, snapshot) {
                  // Enquanto os dados estão carregando
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  // Se ocorreu um erro na chamada
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Erro ao buscar informações do processo. Tente novamente mais tarde.",
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // Se a API não retornou dados
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Center(
                      child: Text(
                        "Nenhuma informação encontrada para este processo no Datajud.",
                        style: TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // Se os dados foram carregados com sucesso
                  final processo = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card com a última movimentação
                      Card(
                        elevation: 2,
                        child: ListTile(
                          leading: Icon(Icons.gavel,
                              color: Theme.of(context).primaryColor),
                          title: Text("Última Movimentação"),
                          subtitle: Text(
                            processo.ultimoStatus ?? "Dado Indisponível",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Título da lista de histórico
                      Text("Histórico de Movimentações:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Divider(),
                      // Validação para caso não hajam movimentações
                      if (processo.movimentos.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Nenhuma movimentação registrada.",
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                        )
                      else
                        // Lista de todas as movimentações
                        Expanded(
                          child: ListView.builder(
                            itemCount: processo.movimentos.length,
                            itemBuilder: (context, index) {
                              final movimento = processo.movimentos[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 5.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).primaryColorLight,
                                    child: Text(
                                      // Contador em ordem decrescente para mostrar o mais recente primeiro
                                      "${processo.movimentos.length - index}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .primaryColorDark),
                                    ),
                                  ),
                                  title: Text(
                                      movimento.nome ?? "Dado Indisponível"),
                                  subtitle: Text(
                                      movimento.data ?? "Data não informada"),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
