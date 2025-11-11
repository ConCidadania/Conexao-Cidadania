// lib/view/views/signature_view.dart
import 'dart:typed_data';
import 'package:get_it/get_it.dart';
import 'dart:ui' as ui;
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:con_cidadania/utils/colors.dart';
import 'package:con_cidadania/utils/message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart'; // Importação principal
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class SignatureView extends StatefulWidget {
  final String unsignedPdfUrl;
  final String documentName;
  final String fileName;

  const SignatureView({
    Key? key,
    required this.unsignedPdfUrl,
    required this.documentName,
    required this.fileName,
  }) : super(key: key);

  @override
  State<SignatureView> createState() => _SignatureViewState();
}

class _SignatureViewState extends State<SignatureView> {
  final LawsuitController _lawsuitCtrl = GetIt.I.get<LawsuitController>();
  final GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

  Uint8List? _signatureData; // Armazena os bytes da assinatura
  bool _isLoading = false;

  // NOVO: Futuro para armazenar os bytes do PDF
  late Future<Uint8List> _pdfBytesFuture;
  // NOVO: Armazena os bytes após o carregamento para reutilização
  Uint8List? _loadedPdfBytes;

  @override
  void initState() {
    super.initState();
    // NOVO: Inicia o download do PDF assim que a tela é carregada
    _pdfBytesFuture = _loadPdfBytes();
  }

  // NOVO: Método para baixar os bytes do PDF
  Future<Uint8List> _loadPdfBytes() async {
    try {
      final http.Response response = await http.get(
        Uri.parse(widget.unsignedPdfUrl),
      );
      if (response.statusCode == 200) {
        _loadedPdfBytes = response.bodyBytes; // Salva os bytes
        return _loadedPdfBytes!;
      } else {
        throw Exception(
          "Falha ao carregar o PDF. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Erro de rede ao buscar PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text(
          "Assinar Procuração",
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
      body: Column(
        children: [
          // 1. MODIFICADO: Visualizador de PDF agora usa FutureBuilder
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.mediumGrey.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              // Usa FutureBuilder para esperar os bytes do PDF
              child: FutureBuilder<Uint8List>(
                future: _pdfBytesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: AppColors.mainGreen),
                          SizedBox(height: 16),
                          Text("Carregando documento..."),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Erro ao carregar o PDF: ${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.redColor),
                        ),
                      ),
                    );
                  }

                  // SUCESSO: Usa SfPdfViewer.memory com os bytes carregados
                  return SfPdfViewer.memory(
                    snapshot.data!,
                    canShowPasswordDialog: false,
                    canShowScrollHead: false,
                  );
                },
              ),
            ),
          ),

          // 2. Pré-visualização da Assinatura (sem alteração)
          if (_signatureData != null)
            Container(
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.mainGreen),
              ),
              child: Column(
                children: [
                  Text(
                    "Assinatura capturada:",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Image.memory(_signatureData!, height: 70),
                ],
              ),
            ),

          // 3. Botões de Ação (sem alteração)
          _buildBottomActionButtons(),
        ],
      ),
    );
  }

  // Botões na parte inferior da tela (sem alteração)
  Widget _buildBottomActionButtons() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botão "Assinar Procuração"
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _showSignatureOptionsDialog,
              icon: Icon(Icons.draw, color: AppColors.mainGreen),
              label: Text(
                _signatureData == null ? "Assinar" : "Assinar Novamente",
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mainGreen,
                side: BorderSide(color: AppColors.mainGreen, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          // Botão "Confirmar Assinatura"
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              // Desabilitado se não houver assinatura, PDF ou se estiver carregando
              onPressed:
                  (_signatureData == null ||
                      _isLoading ||
                      _loadedPdfBytes == null)
                  ? null
                  : _handleConfirmSignature,
              icon: Icon(Icons.check, color: Colors.white),
              label: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text("Confirmar Assinatura"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shadowColor: AppColors.mainGreen.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dialog com as opções de assinatura (sem alteração)
  void _showSignatureOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Escolha o método de assinatura"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.qr_code_scanner,
                  color: AppColors.mainGreen,
                ),
                title: Text("Assinar com Certificado Digital"),
                subtitle: Text("Disponível em breve"),
                onTap: () {
                  Navigator.of(context).pop();
                  showMessage(
                    context,
                    "Esta funcionalidade estará disponível em breve.",
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.mainGreen),
                title: Text("Assinar Manualmente na Tela"),
                onTap: () {
                  Navigator.of(context).pop(); // Fecha o dialog de opções
                  _showSignaturePadDialog(); // Abre o signature pad
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Dialog com o SignaturePad (sem alteração)
  void _showSignaturePadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text("Assine no espaço abaixo"),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8, // 80% da largura
            height: 200, // Altura fixa para o pad
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.mediumGrey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SfSignaturePad(
              key: _signaturePadKey,
              backgroundColor: Colors.white,
              minimumStrokeWidth: 200,
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                _signaturePadKey.currentState?.clear();
              },
              child: Text(
                "Limpar",
                style: TextStyle(color: AppColors.redColor),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Converte a assinatura em imagem
                final ui.Image image = await _signaturePadKey.currentState!
                    .toImage();
                final ByteData? byteData = await image.toByteData(
                  format: ui.ImageByteFormat.png,
                );
                if (byteData != null) {
                  setState(() {
                    _signatureData = byteData.buffer.asUint8List();
                  });
                  Navigator.of(context).pop(); // Fecha o pad
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGreen,
              ),
              child: Text(
                "Salvar Assinatura",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Lógica principal: aplica a assinatura ao PDF e faz o upload
  Future<void> _handleConfirmSignature() async {
    // MODIFICADO: Verifica se os bytes da assinatura E do PDF estão prontos
    if (_signatureData == null || _loadedPdfBytes == null) return;

    setState(() {
      _isLoading = true;
    });

    showMessage(context, "Aplicando assinatura ao documento...");

    try {
      // 1. MODIFICADO: Não precisa mais baixar. Usa os bytes já carregados
      final Uint8List originalPdfBytes = _loadedPdfBytes!;

      // 2. Carregar o documento PDF
      final PdfDocument document = PdfDocument(inputBytes: originalPdfBytes);

      // 3. Carregar a imagem da assinatura
      final PdfBitmap signatureImage = PdfBitmap(_signatureData!);

      // 4. Obter a última página (onde a assinatura geralmente fica)
      final PdfPage page = document.pages[document.pages.count - 1];
      final Size pageSize = page.getClientSize();

      // 5. Desenhar a assinatura na página
      final double y = pageSize.height - 400; // 400 pixels de baixo
      final double x = (pageSize.width - 200) / 2; // 200 de largura
      page.graphics.drawImage(
        signatureImage,
        Rect.fromLTWH(
          x,
          y,
          200,
          40, // Aumenta a altura para a assinatura não ficar achatada
        ),
      );

      // 6. Salvar o novo documento PDF
      final List<int> newPdfBytes = await document.save();
      document.dispose();

      // 7. Fazer upload do novo PDF (sobrescrevendo o antigo)
      showMessage(context, "Salvando documento assinado...");
      await _lawsuitCtrl.uploadDocument(
        widget.documentName,
        widget.fileName,
        Uint8List.fromList(newPdfBytes),
      );

      // 8. Atualizar o status da ação no Firestore
      _lawsuitCtrl.updateLawsuitProcuracaoAssinada(true);

      showMessage(context, "Procuração assinada e salva com sucesso!");
      Navigator.of(context).pop(true); // Retorna true para a view anterior
    } catch (e) {
      debugPrint("Erro ao assinar e salvar PDF: $e");
      showMessage(context, "Erro ao salvar o documento: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
