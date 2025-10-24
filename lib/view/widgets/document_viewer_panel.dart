import 'package:con_cidadania/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:url_launcher/url_launcher.dart';

// Importações específicas para Flutter Web
import 'dart:ui' as ui;
import 'dart:html' as html;

class DocumentViewerPanel extends StatefulWidget {
  final String storagePath;
  final String documentTitle;
  final String? uploadedFileUrl;
  final VoidCallback onClose; // Callback para notificar o fechamento

  const DocumentViewerPanel({
    super.key,
    required this.storagePath,
    required this.documentTitle,
    required this.onClose,
    this.uploadedFileUrl,
  });

  @override
  State<DocumentViewerPanel> createState() => _DocumentViewerPanelState();
}

class _DocumentViewerPanelState extends State<DocumentViewerPanel> {
  final LawsuitController lawsuitCtrl = GetIt.I.get<LawsuitController>();
  late Future<String?> _downloadUrlFuture;
  final String _viewId =
      'document-iframe-${DateTime.now().millisecondsSinceEpoch}'; // ID único

  @override
  void initState() {
    super.initState();
    if (widget.uploadedFileUrl != null) {
      _downloadUrlFuture = Future.value(widget.uploadedFileUrl);
    } else {
      _downloadUrlFuture =
          lawsuitCtrl.getDocumentDownloadURL(widget.storagePath);
    }
  }

  // Lógica de download (similar ao dialog)
  void _triggerDownload(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Força o download
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível iniciar o download.')),
        );
      }
    }
  }

  // Registra e cria o IFrameElement para visualização
  void _registerIFrame(String url) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      _viewId,
      (int viewId) {
        final html.IFrameElement element = html.IFrameElement()
          ..src = url
          ..style.border = 'none' // Remove a borda padrão do iframe
          ..style.width = '100%'
          ..style.height = '100%';
        return element;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.zero, // Remove margens padrão do Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho com Título e Botão Fechar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Visualizando: ${widget.documentTitle}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mainGreen,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.mediumGrey),
                  tooltip: "Fechar Visualizador",
                  onPressed: widget.onClose, // Chama o callback para fechar
                ),
              ],
            ),
            Divider(height: 20, thickness: 1),

            // Corpo com o Preview e Botões
            Expanded(
              child: FutureBuilder<String?>(
                future: _downloadUrlFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.mainGreen),
                          SizedBox(height: 16),
                          Text("Carregando documento..."),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              color: AppColors.redColor, size: 40),
                          SizedBox(height: 16),
                          Text(
                            "Erro ao carregar o documento.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.redColor),
                          ),
                        ],
                      ),
                    );
                  }

                  final downloadUrl = snapshot.data!;
                  _registerIFrame(downloadUrl); // Registra o IFrame com a URL

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Área de Pré-visualização com IFrame
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: AppColors.mediumGrey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          // Usa HtmlElementView para renderizar o IFrame
                          child: HtmlElementView(viewType: _viewId),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Botão de Download
                      ElevatedButton.icon(
                        onPressed: () => _triggerDownload(downloadUrl),
                        icon: Icon(Icons.download, color: Colors.white),
                        label: Text("Abrir no Navegador"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mainGreen,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
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
