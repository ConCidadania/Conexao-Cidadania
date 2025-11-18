// lib/view/views/signature_view.dart
import 'dart:typed_data';
import 'package:get_it/get_it.dart';
import 'dart:ui' as dart_ui; // Renomeado para evitar conflito
import 'dart:ui_web' as ui;
import 'dart:html' as html; // Importação necessária para o IFrame
import 'dart:convert'; // Importação necessária para Base64
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:con_cidadania/utils/colors.dart';
import 'package:con_cidadania/utils/message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

// Enum para controlar o que está sendo exibido na tela
enum _SignatureViewStep {
  previewingPdf, // Mostra o IFrame do PDF
  showingOptions, // Mostra as opções de assinatura (Manual, Certificado)
}

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

  late Future<Uint8List> _pdfBytesFuture;
  Uint8List? _loadedPdfBytes;

  final String _viewId = 'pdf-iframe-${DateTime.now().millisecondsSinceEpoch}';

  // Controla o estado da tela
  _SignatureViewStep _currentStep = _SignatureViewStep.previewingPdf;

  @override
  void initState() {
    super.initState();
    _pdfBytesFuture = _loadPdfBytes();
  }

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
          onPressed: () {
            // Se estiver em um passo interno, "Voltar" leva ao passo anterior
            if (_currentStep != _SignatureViewStep.previewingPdf) {
              setState(() {
                _currentStep = _SignatureViewStep.previewingPdf;
              });
            } else {
              // Se já estiver no passo principal, sai da tela
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          // 1. O CONTEÚDO PRINCIPAL (EXPANDIDO)
          // Alterna entre PDF, Opções ou SignaturePad
          Expanded(child: _buildMainContent()),

          // 2. PRÉ-VISUALIZAÇÃO DA ASSINATURA
          // Só aparece no modo "preview" E se a assinatura já foi capturada
          if (_currentStep == _SignatureViewStep.previewingPdf &&
              _signatureData != null)
            _buildSignaturePreview(),

          // 3. BOTÕES DE AÇÃO INFERIORES
          // Só aparecem no modo "preview"
          if (_currentStep == _SignatureViewStep.previewingPdf)
            _buildBottomActionButtons(),
        ],
      ),
    );
  }

  // Novo método que roteia o conteúdo principal
  Widget _buildMainContent() {
    switch (_currentStep) {
      case _SignatureViewStep.previewingPdf:
        return _buildPdfViewer(); // O IFrame
      case _SignatureViewStep.showingOptions:
        return _buildSignatureOptions(); // As opções (antigo dialog)
    }
  }

  // 1A. O visualizador de PDF (o antigo FutureBuilder)
  Widget _buildPdfViewer() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.mediumGrey.withOpacity(0.5)),
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

          // SUCESSO: Usa HtmlElementView (IFrame)
          final pdfData = snapshot.data!;

          // Converter bytes para data URL
          final String base64Pdf = base64Encode(pdfData);
          final String dataUrl = 'data:application/pdf;base64,$base64Pdf';

          // Registrar a view factory para o IFrame
          // ignore: undefined_prefixed_name
          ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
            final html.IFrameElement element = html.IFrameElement()
              // Define o src para a Data URL (bytes em Base64)
              ..src = dataUrl
              ..style.border = 'none'
              ..style.width = '100%'
              ..style.height = '100%';
            return element;
          });

          // Retorna o widget do IFrame
          return HtmlElementView(viewType: _viewId);
        },
      ),
    );
  }

  // 1B. O widget de opções de assinatura (antigo _showSignatureOptionsDialog)
  Widget _buildSignatureOptions() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Escolha o método de assinatura",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.qr_code_scanner, color: AppColors.mainGreen),
              title: Text("Assinar com Certificado Digital"),
              subtitle: Text("Disponível em breve"),
              onTap: () {
                showMessage(
                  context,
                  "Esta funcionalidade estará disponível em breve.",
                );
              },
            ),
          ),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(Icons.edit, color: AppColors.mainGreen),
              title: Text("Assinar Manualmente na Tela"),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.mediumGrey,
              ),
              onTap: () {
                // Show dialog
                _showSignaturePadDialog();
              },
            ),
          ),
        ],
      ),
    );
  }

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
                final dart_ui.Image image = await _signaturePadKey.currentState!
                    .toImage();
                final ByteData? byteData = await image.toByteData(
                  format: dart_ui.ImageByteFormat.png,
                );
                if (byteData != null) {
                  setState(() {
                    _signatureData = byteData.buffer.asUint8List();
                    _currentStep = _SignatureViewStep.previewingPdf;
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

  // 2. Widget de pré-visualização da assinatura
  Widget _buildSignaturePreview() {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.fromLTRB(16, 0, 16, 16),
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
    );
  }

  // 3. Botões de ação inferiores (modificado o onPressed)
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
              onPressed: () {
                // MODIFICADO: Em vez de chamar dialog, muda o estado
                setState(() {
                  _currentStep = _SignatureViewStep.showingOptions;
                });
              },
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

  // Lógica principal: aplica a assinatura ao PDF e faz o upload (sem alteração)
  Future<void> _handleConfirmSignature() async {
    if (_signatureData == null || _loadedPdfBytes == null) return;

    setState(() {
      _isLoading = true;
    });

    showMessage(context, "Aplicando assinatura ao documento...");

    try {
      final Uint8List originalPdfBytes = _loadedPdfBytes!;
      final PdfDocument document = PdfDocument(inputBytes: originalPdfBytes);
      final PdfBitmap signatureImage = PdfBitmap(_signatureData!);
      final PdfPage page = document.pages[document.pages.count - 1];
      final Size pageSize = page.getClientSize();

      // Posição ajustada (correção da última etapa)
      final double y = pageSize.height - 400; // 400 pixels de baixo
      final double x = (pageSize.width - 200) / 2; // 200 de largura
      page.graphics.drawImage(
        signatureImage,
        Rect.fromLTWH(
          x,
          y,
          200,
          40, // Proporção ajustada
        ),
      );

      final List<int> newPdfBytes = await document.save();
      document.dispose();

      showMessage(context, "Salvando documento assinado...");
      await _lawsuitCtrl.uploadDocument(
        widget.documentName,
        widget.fileName,
        Uint8List.fromList(newPdfBytes),
      );

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
