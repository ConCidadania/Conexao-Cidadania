import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:con_cidadania/utils/colors.dart';

class DocumentUploadCard extends StatefulWidget {
  final String documentName;
  final String documentTitle;

  const DocumentUploadCard({
    super.key,
    required this.documentName,
    required this.documentTitle,
  });

  @override
  State<DocumentUploadCard> createState() => _DocumentUploadCardState();
}

class _DocumentUploadCardState extends State<DocumentUploadCard> {
  final LawsuitController lawsuitCtrl = GetIt.I.get<LawsuitController>();
  Uint8List? _selectedFileBytes;
  String? _selectedFileName;
  bool _isUploading = false;
  String? _uploadStatus;

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
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, selecione um arquivo primeiro.")),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadStatus = "Fazendo upload...";
    });

    // Chama o método uploadDocument do controller
    String? fileUrl = await lawsuitCtrl.uploadDocument(
      widget.documentName,
      _selectedFileName!,
      _selectedFileBytes!,
    );

    setState(() {
      _isUploading = false;
      if (fileUrl != null) {
        _uploadStatus = "Upload Concluído!";
        // TODO: Você pode querer armazenar o fileUrl no modelo da Lawsuit aqui
      } else {
        _uploadStatus = "Falha no Upload.";
        _selectedFileBytes = null;
      }
    });

    // Mostrar feedback ao usuário
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(fileUrl != null
            ? "Documento ${widget.documentTitle} enviado com sucesso!"
            : "Erro ao enviar documento. Tente novamente."),
        backgroundColor:
            fileUrl != null ? AppColors.mainGreen : AppColors.redColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título do Documento
            Text(
              widget.documentTitle,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.mainGreen,
              ),
            ),
            SizedBox(height: 10),

            // Exibição do Arquivo Selecionado e Status
            Row(
              children: [
                Icon(
                  _selectedFileBytes == null
                      ? Icons.attach_file
                      : Icons.insert_drive_file,
                  color: AppColors.mediumGrey,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedFileName ??
                        "Nenhum arquivo selecionado (PDF/JPG/PNG)",
                    style: TextStyle(
                      fontStyle: _selectedFileBytes == null
                          ? FontStyle.italic
                          : FontStyle.normal,
                      color: _selectedFileBytes == null
                          ? AppColors.mediumGrey
                          : AppColors.blackColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Botões de Ação
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão Selecionar
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickFile,
                  icon: Icon(Icons.folder_open, size: 18),
                  label: Text("Selecionar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainGreen,
                    foregroundColor: AppColors.lightGrey,
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
                      : Icon(Icons.cloud_upload, size: 18),
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
        ),
      ),
    );
  }
}
