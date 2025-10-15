import 'package:con_cidadania/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentPreviewDialog extends StatefulWidget {
  final String storagePath;
  final String documentTitle;
  // A URL já pode ser passada se o card já a conhece (após o upload)
  final String? uploadedFileUrl;

  const DocumentPreviewDialog({
    super.key,
    required this.storagePath,
    required this.documentTitle,
    this.uploadedFileUrl,
  });

  @override
  State<DocumentPreviewDialog> createState() => _DocumentPreviewDialogState();
}

class _DocumentPreviewDialogState extends State<DocumentPreviewDialog> {
  final LawsuitController lawsuitCtrl = GetIt.I.get<LawsuitController>();
  late Future<String?> _downloadUrlFuture;

  @override
  void initState() {
    super.initState();
    // Prioriza a URL já conhecida. Se não, chama o controller para obter a URL.
    if (widget.uploadedFileUrl != null) {
      _downloadUrlFuture = Future.value(widget.uploadedFileUrl);
    } else {
      // Chamada ao método do controller para obter a URL
      _downloadUrlFuture =
          lawsuitCtrl.getDocumentDownloadURL(widget.storagePath);
    }
  }

  // Lógica de download/preview persistente para Web (usando url_launcher)
  void _triggerWebAction(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      // Abre a URL em uma nova aba, forçando o download no navegador.
      // O dowload é disparado devido ao contentDiposition = attachment metadado do arquivo
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Ação iniciada no navegador. Verifique a pasta Downloads.')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Não foi possível iniciar a ação no navegador.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        "Visualizar: ${widget.documentTitle}",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.mainGreen,
        ),
      ),
      content: SizedBox(
        // Altura e largura limitadas para um dialog
        width: MediaQuery.of(context).size.width * 0.2,
        child: FutureBuilder<String?>(
          future: _downloadUrlFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.mainGreen),
                    SizedBox(height: 16),
                    Text("Carregando URL do documento..."),
                  ],
                ),
              );
            }

            if (snapshot.hasError || snapshot.data == null) {
              return Center(
                child: Text(
                  "Erro ao carregar o documento. Por favor, tente novamente.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.redColor),
                ),
              );
            }

            final downloadUrl = snapshot.data!;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pré-visualização (Indicador de Arquivo Carregado)
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.description,
                          size: 48, color: AppColors.mainGreen),
                      SizedBox(height: 8),
                      Text("Arquivo Carregado",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(widget.storagePath,
                          style: TextStyle(
                              fontSize: 12, color: AppColors.mediumGrey)),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Botão para PRÉ-VISUALIZAR em uma nova aba
                /*OutlinedButton.icon(
                  onPressed: () => _triggerWebAction(downloadUrl),
                  icon: Icon(Icons.open_in_new, size: 20, color: AppColors.mainGreen),
                  label: Text("Abrir para Visualizar (Web)"),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.mainGreen),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                SizedBox(height: 12),
                */

                // Botão de Download Persistente (Web)
                ElevatedButton.icon(
                  onPressed: () => _triggerWebAction(downloadUrl),
                  icon: Icon(Icons.download, color: Colors.white),
                  label: Text("Download (Web)"),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            "Fechar",
            style: TextStyle(color: AppColors.mediumGrey),
          ),
        ),
      ],
    );
  }
}
