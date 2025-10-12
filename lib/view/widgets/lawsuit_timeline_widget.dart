import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:con_cidadania/controller/datajud_lawsuit_controller.dart';
import 'package:con_cidadania/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LawsuitTimelineWidget extends StatefulWidget {
  final String numeroProcesso;

  const LawsuitTimelineWidget({
    Key? key,
    required this.numeroProcesso,
  }) : super(key: key);

  @override
  State<LawsuitTimelineWidget> createState() => _LawsuitTimelineWidgetState();
}

class _LawsuitTimelineWidgetState extends State<LawsuitTimelineWidget> {
  // Instancia o controller para buscar os dados do histórico
  final DatajudLawsuitController _controller = DatajudLawsuitController();
  late Stream<QuerySnapshot> _timelineStream;

  @override
  void initState() {
    super.initState();
    // Inicializa a stream com os dados do processo
    _timelineStream = _controller.fetchAllTimelineItems(widget.numeroProcesso);
  }

  // Formata a data para um formato legível
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy \'às\' HH:mm').format(date);
    } catch (e) {
      return "Data inválida";
    }
  }

  // Função para forçar a atualização da stream
  void _refreshTimeline() {
    setState(() {
      // Requisita a stream novamente, o que aciona a lógica de atualização no controller
      _timelineStream =
          _controller.fetchAllTimelineItems(widget.numeroProcesso);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Botão para atualizar o histórico manualmente
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: _refreshTimeline,
            icon: Icon(Icons.refresh, size: 18),
            label: Text("Atualizar"),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.mainGreen,
              side: BorderSide(color: AppColors.mainGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        // StreamBuilder para construir a lista de acordo com os dados recebidos
        StreamBuilder<QuerySnapshot>(
          stream: _timelineStream,
          builder: (context, snapshot) {
            // Estado de carregamento
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.mainGreen),
                      SizedBox(height: 10),
                      Text("Buscando histórico...",
                          style: TextStyle(color: AppColors.mediumGrey)),
                    ],
                  ),
                ),
              );
            }

            // Estado de erro
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Erro ao carregar o histórico.",
                  style: TextStyle(color: AppColors.redColor),
                ),
              );
            }

            // Estado sem dados ou com lista vazia
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Nenhum andamento processual encontrado.",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: AppColors.mediumGrey),
                  ),
                ),
              );
            }

            // Constrói a ListView com os dados recebidos
            final timelineItems = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics:
                  NeverScrollableScrollPhysics(), // A view principal já é rolável
              itemCount: timelineItems.length,
              itemBuilder: (context, index) {
                var item = timelineItems[index];
                String name = item['name'] ?? 'Movimentação não descrita';
                String date = item['date'] ?? '';

                // Card estilizado para cada item do histórico
                return _buildTimelineItemCard(
                  title: name,
                  date: _formatDate(date),
                  icon: Icons.gavel,
                  isLastItem: index == timelineItems.length - 1,
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Widget para construir cada card do histórico
  Widget _buildTimelineItemCard({
    required String title,
    required String date,
    required IconData icon,
    bool isLastItem = false,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      margin: EdgeInsets.only(bottom: isLastItem ? 0 : 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.mainGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.mainGreen, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
