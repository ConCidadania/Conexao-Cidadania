// lib/view/views/document_generation_view.dart
import 'dart:typed_data';
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:con_cidadania/controller/user_controller.dart';
import 'package:con_cidadania/model/lawsuit_model.dart';
//import 'package:con_cidadania/model/user_model.dart';
import 'package:con_cidadania/services/pdf_generator_service.dart';
import 'package:con_cidadania/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:printing/printing.dart'; // Importa o visualizador de PDF

// Enum para definir o tipo de documento a ser gerado
enum DocumentTemplateType { procuracao, peticao }

class DocumentGenerationView extends StatefulWidget {
  final DocumentTemplateType documentType;

  const DocumentGenerationView({Key? key, required this.documentType})
      : super(key: key);

  @override
  _DocumentGenerationViewState createState() => _DocumentGenerationViewState();
}

class _DocumentGenerationViewState extends State<DocumentGenerationView> {
  final LawsuitController _lawsuitCtrl = GetIt.I.get<LawsuitController>();
  final UserController _userCtrl = GetIt.I.get<UserController>();
  final PdfGeneratorService _pdfService = PdfGeneratorService();

  late Future<Uint8List> _pdfDataFuture;

  @override
  void initState() {
    super.initState();
    _pdfDataFuture = _generateDocument();
  }

  Future<Uint8List> _generateDocument() async {
    try {
      // 1. Obter a Ação (Lawsuit) atual
      final lawsuitSnapshot = await _lawsuitCtrl.getCurrentLawsuit();
      final lawsuit = Lawsuit.fromFirestore(lawsuitSnapshot);

      // 2. Obter o Dono (AppUser) da ação
      final user = await _userCtrl.getOwnerData(lawsuit.ownerId);
      if (user == null) {
        throw Exception("Não foi possível encontrar os dados do proprietário.");
      }

      // 3. Gerar o PDF com base no tipo
      if (widget.documentType == DocumentTemplateType.procuracao) {
        return _pdfService.generateProcuracao(lawsuit, user);
      } else {
        return _pdfService.generatePeticao(lawsuit, user);
      }
    } catch (e) {
      throw Exception("Erro ao gerar PDF: $e");
    }
  }

  String _getTitle() {
    return widget.documentType == DocumentTemplateType.procuracao
        ? "Procuração"
        : "Petição Inicial";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text(
          _getTitle(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.mainGreen,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: FutureBuilder<Uint8List>(
          future: _pdfDataFuture,
          builder: (context, snapshot) {
            // Estado de Carregamento
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.mainGreen),
                  SizedBox(height: 20),
                  Text("Gerando documento, por favor aguarde...",
                      style:
                          TextStyle(fontSize: 16, color: AppColors.mediumGrey)),
                ],
              );
            }

            // Estado de Erro
            if (snapshot.hasError || !snapshot.hasData) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      color: AppColors.redColor, size: 60),
                  SizedBox(height: 20),
                  Text("Erro ao Gerar Documento",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(snapshot.error.toString(),
                      style:
                          TextStyle(fontSize: 14, color: AppColors.mediumGrey)),
                ],
              );
            }

            // Estado de Sucesso
            final pdfData = snapshot.data!;
            return Column(
              children: [
                // Botão de Download (O PdfPreview também tem o seu)
                Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  color: Colors.white,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.download, color: Colors.white),
                    label: Text("Download do Documento"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      // O 'printing' facilita o download no Web
                      await Printing.sharePdf(
                        bytes: pdfData,
                        filename: '${_getTitle().replaceAll(' ', '_')}.pdf',
                      );
                    },
                  ),
                ),
                // Visualizador de PDF
                Expanded(
                  child: PdfPreview(
                    build: (format) => pdfData,
                    allowPrinting: false,
                    allowSharing: false,
                    canChangePageFormat: false,
                    canChangeOrientation: false,
                    canDebug: false,
                    // Desativa o botão de download padrão se preferir usar apenas o seu
                    // showDownloading: false,
                    pdfFileName: '${_getTitle().replaceAll(' ', '_')}.pdf',
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
