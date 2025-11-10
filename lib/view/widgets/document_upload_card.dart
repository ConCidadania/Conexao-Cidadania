import 'dart:typed_data';
import 'package:con_cidadania/controller/user_controller.dart';
import 'package:con_cidadania/view/widgets/document_preview_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:con_cidadania/utils/colors.dart';

class DocumentUploadCard extends StatefulWidget {
  final String documentName;
  final String documentTitle;
  final String lawsuitStatus;
  final bool showActions;
  final Function({
    required String storagePath,
    required String documentTitle,
    String? uploadedFileUrl,
  })
  onPreviewRequested; // Adicione este callback

  const DocumentUploadCard({
    super.key,
    required this.documentName,
    required this.documentTitle,
    required this.lawsuitStatus,
    required this.onPreviewRequested,
    required this.showActions,
  });

  @override
  State<DocumentUploadCard> createState() => _DocumentUploadCardState();
}

class _DocumentUploadCardState extends State<DocumentUploadCard> {
  final UserController userCtrl = GetIt.I.get<UserController>();
  final LawsuitController lawsuitCtrl = GetIt.I.get<LawsuitController>();
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  bool _isUploading = false;
  String? _uploadStatus;
  // Variável para armazenar a URL de download após o upload
  String? _uploadedFileUrl;

  @override
  void initState() {
    super.initState();
    // Carrega a url de download se existir
    _tryLoadFile();
  }

  void _onPreviewRequested() {
    print("Requested Preview for: ${widget.documentTitle}");
    widget.onPreviewRequested(
      storagePath: widget.documentName,
      documentTitle: widget.documentTitle,
      uploadedFileUrl: _uploadedFileUrl,
    );
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );

    if (result != null) {
      setState(() {
        _selectedFileBytes = result.files.first.bytes;
        _selectedFileName = result.files.first.name;
        _uploadStatus = null; // Limpa o status ao selecionar novo arquivo
        // Limpa a URL, pois um novo arquivo será enviado
        _uploadedFileUrl = null;
      });
    }
  }

  Future<void> _tryLoadFile() async {
    setState(() {
      _isUploading = true;
      _uploadStatus = "Carregando ...";
      _uploadedFileUrl = null;
    });

    // Recupera a url de download se existir
    // TODO: Comment out the USER / LAWYER check and use just "getCurrentLawsuitId"
    //final String storePath =
    //    'files/users/${userCtrl.getCurrentUserType() == 'USER' ? userCtrl.getCurrentUserId() : await lawsuitCtrl.getCurrentLawsuitOwnerId()}/lawsuits/${lawsuitCtrl.currentLawsuitId}/docs/${widget.documentName}';
    final String storePath =
        'files/users/${await lawsuitCtrl.getCurrentLawsuitOwnerId()}/lawsuits/${lawsuitCtrl.currentLawsuitId}/docs/${widget.documentName}';
    final String? downloadUrl = await lawsuitCtrl.getDocumentDownloadURL(
      storePath,
    );

    setState(() {
      _isUploading = false;
      if (downloadUrl != null) {
        _selectedFileName = widget.documentName;
        _uploadStatus = "Carregamento Concluído para: $_selectedFileName";
        // Salva a URL retornada após o sucesso
        _uploadedFileUrl = downloadUrl;
      } else {
        _uploadStatus = null;
        _uploadedFileUrl = null;
      }
    });
  }

  Future<void> _uploadFile() async {
    if (_selectedFileBytes == null) return;

    setState(() {
      _isUploading = true;
      _uploadStatus = "Enviando $_selectedFileName...";
      _uploadedFileUrl = null;
    });

    // Chama o método do controller para upload
    final String? downloadUrl = await lawsuitCtrl.uploadDocument(
      widget.documentName,
      _selectedFileName!,
      _selectedFileBytes!,
    );

    setState(() {
      _isUploading = false;
      if (downloadUrl != null) {
        _uploadStatus = "Upload Concluído para: $_selectedFileName";
        // Salva a URL retornada após o sucesso
        _uploadedFileUrl = downloadUrl;
      } else {
        _uploadStatus = "Erro no Upload. Tente novamente.";
        _uploadedFileUrl = null;
      }
    });
  }

  // Método para exibir a pré-visualização e download
  // ignore: unused_element
  void _showPreviewDialog() {
    if (_uploadedFileUrl != null) {
      showDialog(
        context: context,
        builder: (context) => DocumentPreviewDialog(
          documentTitle: widget.documentTitle,
          storagePath:
              widget.documentName, // O path para buscar ou o nome do arquivo
          uploadedFileUrl: _uploadedFileUrl, // Passa a URL já conhecida
        ),
      );
    }
  }

  Widget _buildActionButtons() {
    if (widget.showActions) {
      return Column(
        children: [
          // Ações (Botões) - Seleção e Upload
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 10.0,
            runSpacing: 8.0,
            children: [
              TextButton.icon(
                onPressed: widget.lawsuitStatus != 'Encerrada'
                    ? _pickFile
                    : null,
                icon: Icon(
                  Icons.folder_open,
                  size: 18,
                  color: AppColors.mainGreen,
                ),
                label: Text(
                  _selectedFileBytes != null
                      ? "Trocar Arquivo"
                      : "Selecionar Arquivo",
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mainGreen,
                ),
              ),

              // Botão Upload
              ElevatedButton.icon(
                onPressed: _selectedFileBytes != null && !_isUploading
                    ? _uploadFile
                    : null,
                icon: _isUploading
                    ? SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.cloud_upload, size: 18, color: Colors.white),
                label: Text(_isUploading ? "Enviando..." : "Upload"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),

          // Status de Upload
          if (_uploadStatus != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _uploadStatus!,
                style: TextStyle(
                  color: _uploadStatus!.contains("Concluído")
                      ? AppColors.mainGreen
                      : AppColors.redColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se o card pode ser clicado para preview
    final bool isPreviewAvailable = _uploadedFileUrl != null && !_isUploading;

    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Envolver o Card em InkWell para capturar o onTap
      child: InkWell(
        // O onTap só funciona se o arquivo estiver anexado (uploaded)
        onTap: isPreviewAvailable ? _onPreviewRequested : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Ícone de status de arquivo
                  Icon(
                    _uploadedFileUrl != null
                        ? Icons
                              .check_circle // Arquivo anexado
                        : _selectedFileBytes != null
                        ? Icons
                              .insert_drive_file // Arquivo selecionado
                        : Icons.upload_file, // Padrão
                    size: 24,
                    color: _uploadedFileUrl != null
                        ? AppColors.darkGreen
                        : AppColors.mainGreen,
                  ),
                  SizedBox(width: 8),
                  // Título do documento
                  Expanded(
                    child: Text(
                      widget.documentTitle,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ),

                  // Ícone de visualização
                  if (isPreviewAvailable)
                    Icon(Icons.visibility, color: AppColors.mediumGrey),
                ],
              ),
              Divider(height: 20, color: AppColors.lightGrey),

              // Exibe o nome do arquivo atual ou um placeholder
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _selectedFileName ?? "Nenhum arquivo selecionado.",
                  style: TextStyle(
                    color: AppColors.mediumGrey,
                    fontStyle: _selectedFileName == null
                        ? FontStyle.italic
                        : null,
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
