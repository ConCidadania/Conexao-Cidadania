import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:con_cidadania/controller/user_controller.dart';
import 'package:con_cidadania/model/lawsuit_model.dart';
import 'package:con_cidadania/view/widgets/document_upload_card.dart';
import 'package:con_cidadania/view/widgets/document_viewer_panel.dart';
import 'package:con_cidadania/view/widgets/lawsuit_timeline_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:con_cidadania/utils/colors.dart';

class ManageLawsuitView extends StatefulWidget {
  const ManageLawsuitView({super.key});

  @override
  State<ManageLawsuitView> createState() => _ManageLawsuitViewState();
}

class _ManageLawsuitViewState extends State<ManageLawsuitView> {
  final ctrl = GetIt.I.get<LawsuitController>();
  final userCtrl = GetIt.I.get<UserController>();

  // Novas variáveis de estado para o visualizador
  bool _isViewingDocument = false;
  String? _viewingDocumentPath;
  String? _viewingDocumentTitle;
  String? _viewingDocumentUrl; // Opcional, se já tiver a URL

  // Função para ABRIR o visualizador
  void _openDocumentViewer({
    required String storagePath,
    required String documentTitle,
    String? uploadedFileUrl,
  }) {
    print("Viewer Opened for: $documentTitle");
    setState(() {
      _isViewingDocument = true;
      _viewingDocumentPath = storagePath;
      _viewingDocumentTitle = documentTitle;
      _viewingDocumentUrl = uploadedFileUrl;
    });
  }

  // Função para FECHAR o visualizador (será passada como callback)
  void _closeDocumentViewer() {
    setState(() {
      _isViewingDocument = false;
      _viewingDocumentPath = null;
      _viewingDocumentTitle = null;
      _viewingDocumentUrl = null;
    });
  }

  // Funções de formatação e obtenção de dados permanecem as mesmas
  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy \'às\' HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  IconData _getLawsuitIcon(String type) {
    // ... (código original sem alterações)
    switch (type) {
      case 'REMEDIO_ALTO_CUSTO':
        return Icons.medical_services;
      case 'VAGA_CRECHE_PUBLICA':
        return Icons.child_friendly;
      case 'CIRURGIA_EMERGENCIAL':
        return Icons.local_hospital;
      case 'ALTERACAO_NOME_SOCIAL':
        return Icons.drive_file_rename_outline;
      case 'INTERNACAO_ILP':
        return Icons.elderly;
      default:
        return Icons.assignment;
    }
  }

  String _getLawsuitTypeName(String type) {
    // ... (código original sem alterações)
    switch (type) {
      case 'REMEDIO_ALTO_CUSTO':
        return 'Remédio de Alto Custo';
      case 'VAGA_CRECHE_PUBLICA':
        return 'Vaga em Creche Pública';
      case 'CIRURGIA_EMERGENCIAL':
        return 'Cirurgia de Emergência';
      case 'ALTERACAO_NOME_SOCIAL':
        return 'Alteração de Nome Social';
      case 'INTERNACAO_ILP':
        return 'Internação em Instituto de Longa Permanência';
      default:
        return 'Ação Judicial';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text(
          "Detalhes da Ação",
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
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _showOptionsMenu(),
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: ctrl.getCurrentLawsuit(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || !snapshot.data.exists) {
            return _buildNotFoundState();
          } else {
            DocumentSnapshot currLawsuit = snapshot.data as DocumentSnapshot;
            // O corpo agora usa um LayoutBuilder para decidir qual layout mostrar
            return LayoutBuilder(builder: (context, constraints) {
              // Ponto de quebra: se a tela for maior que 900px, usa o layout desktop
              if (constraints.maxWidth > 900) {
                return _buildDesktopLayout(currLawsuit);
              } else {
                return _buildMobileLayout(currLawsuit);
              }
            });
          }
        },
      ),
    );
  }

  // Layout para Mobile (estrutura original)
  // Widget _buildMobileLayout(DocumentSnapshot currLawsuit) {
  //   return SingleChildScrollView(
  //     child: _buildLawsuitDetails(currLawsuit),
  //   );
  // }

  Widget _buildMobileLayout(DocumentSnapshot currLawsuit) {
    // Se estiver visualizando, mostra SÓ o painel de visualização
    if (_isViewingDocument) {
      return Padding(
        padding: const EdgeInsets.all(16.0), // Adiciona padding ao redor
        child: DocumentViewerPanel(
          key: ValueKey(_viewingDocumentPath),
          storagePath: _viewingDocumentPath!,
          documentTitle: _viewingDocumentTitle!,
          uploadedFileUrl: _viewingDocumentUrl,
          onClose: _closeDocumentViewer,
        ),
      );
    } else {
      // Caso contrário, mostra o layout normal
      return SingleChildScrollView(
        child: _buildLawsuitDetails(currLawsuit),
      );
    }
  }

  // Novo Layout para Desktop (dois painéis)
  // Widget _buildDesktopLayout(DocumentSnapshot currLawsuit) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       // Painel Esquerdo
  //       Expanded(
  //         flex: 3, // Ocupa 3/5 da tela
  //         child: SingleChildScrollView(
  //           padding: EdgeInsets.all(16),
  //           child: _buildLeftPanelContent(currLawsuit),
  //         ),
  //       ),
  //       // Painel Direito
  //       Expanded(
  //         flex: 2, // Ocupa 2/5 da tela
  //         child: SingleChildScrollView(
  //           padding: EdgeInsets.fromLTRB(0, 16, 16, 16),
  //           child: _buildRightPanelContent(currLawsuit),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildDesktopLayout(DocumentSnapshot currLawsuit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Painel Esquerdo (permanece o mesmo, a menos que _isViewingDocument seja true)
        Expanded(
          flex: _isViewingDocument
              ? 2
              : 3, // Ajusta o flex se estiver visualizando
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            // Mostra o conteúdo normal OU o visualizador se o painel esquerdo for escolhido
            child: _buildLeftPanelContent(currLawsuit),
          ),
        ),
        // Painel Direito (substituído pelo visualizador quando ativo)
        Expanded(
          flex: _isViewingDocument ? 3 : 2, // Ajusta o flex
          child: Padding(
            // Usa Padding em vez de SingleChildScrollView para o viewer
            padding: EdgeInsets.fromLTRB(0, 16, 16, 16),
            child: _isViewingDocument
                ? DocumentViewerPanel(
                    key: ValueKey(
                        _viewingDocumentPath), // Chave para reconstruir
                    storagePath: _viewingDocumentPath!,
                    documentTitle: _viewingDocumentTitle!,
                    uploadedFileUrl: _viewingDocumentUrl,
                    onClose: _closeDocumentViewer, // Passa a função de fechar
                  )
                // Se não estiver visualizando, mostra o conteúdo normal
                : SingleChildScrollView(
                    child: _buildRightPanelContent(currLawsuit),
                  ),
          ),
        ),
      ],
    );
  }

  // Conteúdo do painel esquerdo para o layout desktop
  Widget _buildLeftPanelContent(DocumentSnapshot currLawsuit) {
    String createdAt = currLawsuit['createdAt'] ?? '';
    String ownerFirstName = currLawsuit['ownerFirstName'] ?? '';
    String ownerLastName = currLawsuit['ownerLastName'] ?? '';
    String ownerName = '$ownerFirstName $ownerLastName';
    String ownerEmail = currLawsuit['ownerEmail'] ?? 'Email não disponínel';
    String ownerPhoneNumber =
        currLawsuit['ownerPhoneNumber'] ?? 'Telefone não disponínel';
    String type = currLawsuit['type'] ?? '';
    String status = currLawsuit['status'] ?? 'Status Indisponível';

    return Column(
      children: [
        // Card "Informações Gerais"
        _buildInfoCard(
          title: "Informações Gerais",
          icon: Icons.calendar_today,
          color: AppColors.yellowColor,
          children: [
            _buildInfoRow(
                "Data de Abertura", _formatDate(createdAt), Icons.event),
            SizedBox(height: 10),
            _buildInfoRow("Aberto por", ownerName, Icons.account_circle),
            SizedBox(height: 10),
            _buildInfoRow("Email", ownerEmail, Icons.email),
            SizedBox(height: 10),
            _buildInfoRow("Telefone", ownerPhoneNumber, Icons.phone),
          ],
        ),
        SizedBox(height: 16),
        // Card "Anexar Documentos"
        _buildInfoCard(
          title: "Anexar Documentos",
          icon: Icons.attach_file_rounded,
          color: AppColors.darkGreen,
          children: [
            DocumentUploadCard(
              documentName: DocumentType.documento_identidade.name,
              documentTitle: 'Documento de Identidade (RG, CNH, Certidão)',
              lawsuitStatus: status,
              onPreviewRequested: _openDocumentViewer,
            ),
            DocumentUploadCard(
              documentName: DocumentType.comprovante_endereco.name,
              documentTitle: 'Comprovante de Endereço',
              lawsuitStatus: status,
              onPreviewRequested: _openDocumentViewer,
            ),
            DocumentUploadCard(
              documentName: DocumentType.procuracao_assinada.name,
              documentTitle: 'Procuração (Preenchida e Assinada)',
              lawsuitStatus: status,
              onPreviewRequested: _openDocumentViewer,
            ),
            _buildUniqueDocUploadCards(type, status),
          ],
        ),
        SizedBox(height: 16),
        // Card "Ações Disponíveis"
        _buildActionsCard(),
      ],
    );
  }

  // Conteúdo do painel direito para o layout desktop
  Widget _buildRightPanelContent(DocumentSnapshot currLawsuit) {
    String name = currLawsuit['name'] ?? 'Nome não disponível';
    String type = currLawsuit['type'] ?? '';
    String judicialProcessNumber = currLawsuit['judicialProcessNumber'] ?? '';
    String status = currLawsuit['status'] ?? 'Status Indisponível';

    return Column(
      children: [
        // Header Card
        _buildHeaderCard(name, type),
        SizedBox(height: 16),
        // Card "Status da Ação"
        _buildInfoCard(
          title: "Status da Ação",
          icon: Icons.info_outline,
          color: AppColors.blueGreen,
          children: [
            _buildInfoRow("Status Atual", status, Icons.pending_actions),
          ],
        ),
        SizedBox(height: 16),
        // Card "Andamento Processual"
        _buildInfoCard(
          title: "Andamento Processual",
          icon: Icons.timeline,
          color: AppColors.blueGreen,
          children: [
            if (judicialProcessNumber.isNotEmpty)
              LawsuitTimelineWidget(numeroProcesso: judicialProcessNumber)
            else
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.mediumGrey, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "O número do processo judicial ainda não foi atribuído a esta ação.",
                      style:
                          TextStyle(fontSize: 14, color: AppColors.mediumGrey),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  // O conteúdo principal agora é chamado pelo layout mobile
  Widget _buildLawsuitDetails(DocumentSnapshot currLawsuit) {
    String name = currLawsuit['name'] ?? 'Nome não disponível';
    String createdAt = currLawsuit['createdAt'] ?? '';
    String type = currLawsuit['type'] ?? '';
    String ownerFirstName = currLawsuit['ownerFirstName'] ?? '';
    String ownerLastName = currLawsuit['ownerLastName'] ?? '';
    String ownerName = '$ownerFirstName $ownerLastName';
    String ownerEmail = currLawsuit['ownerEmail'] ?? 'Email não disponínel';
    String ownerPhoneNumber =
        currLawsuit['ownerPhoneNumber'] ?? 'Telefone não disponínel';
    String judicialProcessNumber = currLawsuit['judicialProcessNumber'] ?? '';
    String status = currLawsuit['status'] ?? 'Status Indisponível';

    return Column(
      children: [
        // O Header agora é um método separado para ser reutilizado
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildHeaderCard(name, type),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildInfoCard(
                title: "Informações Gerais",
                icon: Icons.calendar_today,
                color: AppColors.yellowColor,
                children: [
                  _buildInfoRow(
                      "Data de Abertura", _formatDate(createdAt), Icons.event),
                  SizedBox(height: 10),
                  _buildInfoRow("Aberto por", ownerName, Icons.account_circle),
                  SizedBox(height: 10),
                  _buildInfoRow("Email", ownerEmail, Icons.email),
                  SizedBox(height: 10),
                  _buildInfoRow("Telefone", ownerPhoneNumber, Icons.phone),
                ],
              ),
              SizedBox(height: 16),
              _buildInfoCard(
                title: "Anexar Documentos",
                icon: Icons.attach_file_rounded,
                color: AppColors.darkGreen,
                children: [
                  DocumentUploadCard(
                    documentName: DocumentType.documento_identidade.name,
                    documentTitle:
                        'Documento de Identidade (RG, CNH, Certidão)',
                    lawsuitStatus: status,
                    onPreviewRequested: _openDocumentViewer,
                  ),
                  DocumentUploadCard(
                    documentName: DocumentType.comprovante_endereco.name,
                    documentTitle: 'Comprovante de Endereço',
                    lawsuitStatus: status,
                    onPreviewRequested: _openDocumentViewer,
                  ),
                  DocumentUploadCard(
                    documentName: DocumentType.procuracao_assinada.name,
                    documentTitle: 'Procuração (Preenchida e Assinada)',
                    lawsuitStatus: status,
                    onPreviewRequested: _openDocumentViewer,
                  ),
                  _buildUniqueDocUploadCards(type, status),
                ],
              ),
              SizedBox(height: 16),
              _buildInfoCard(
                title: "Status da Ação",
                icon: Icons.info_outline,
                color: AppColors.blueGreen,
                children: [
                  _buildInfoRow("Status Atual", status, Icons.pending_actions),
                ],
              ),
              SizedBox(height: 16),
              _buildInfoCard(
                title: "Andamento Processual",
                icon: Icons.timeline,
                color: AppColors.blueGreen,
                children: [
                  if (judicialProcessNumber.isNotEmpty)
                    LawsuitTimelineWidget(numeroProcesso: judicialProcessNumber)
                  else
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppColors.mediumGrey, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "O número do processo judicial ainda não foi atribuído a esta ação.",
                            style: TextStyle(
                                fontSize: 14, color: AppColors.mediumGrey),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 16),
              _buildActionsCard(),
              SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  // O Header Card foi extraído para um método próprio para ser reutilizado
  Widget _buildHeaderCard(String name, String type) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // Header Card
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.mainGreen,
              AppColors.darkGreen,
            ],
          ),
        ),
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getLawsuitIcon(type),
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            // Title
            Text(
              name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            // Type
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getLawsuitTypeName(type),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Os demais widgets e métodos permanecem inalterados
  Widget _buildLoadingState() {
    // ... (código original sem alterações)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.mainGreen,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            "Carregando detalhes...",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    // ... (código original sem alterações)
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.redColor,
            ),
            SizedBox(height: 16),
            Text(
              "Erro ao carregar",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => setState(() {}),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Tentar novamente",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    // ... (código original sem alterações)
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.mediumGrey,
            ),
            SizedBox(height: 16),
            Text(
              "Ação não encontrada",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "A ação judicial que você está procurando não foi encontrada",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Voltar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUniqueDocUploadCards(String lawsuitType, String lawsuitStatus) {
    // ... (código original sem alterações)
    switch (lawsuitType) {
      case 'VAGA_CRECHE_PUBLICA':
        return Column(
          children: [
            // 1. Upload Protocolo de Inscrição na Creche
            DocumentUploadCard(
              documentName: DocumentType.protocolo_inscricao_creche.name,
              documentTitle: 'Protocolo de Inscrição na Creche',
              lawsuitStatus: lawsuitStatus,
              onPreviewRequested: _openDocumentViewer,
            ),

            // 2. Upload Documento Pessoal da Criança
            DocumentUploadCard(
              documentName: DocumentType.documento_identidade_crianca.name,
              documentTitle:
                  'Documento Pessoal da Criança (Cetidão de Nascimento, RG)',
              lawsuitStatus: lawsuitStatus,
              onPreviewRequested: _openDocumentViewer,
            ),
          ],
        );
      case 'REMEDIO_ALTO_CUSTO':
        return Column(
          children: [
            // 1. Upload Cópia do Prontuário Médico
            DocumentUploadCard(
              documentName: DocumentType.copia_prontuario_medico.name,
              documentTitle: 'Cópia do Prontuário Médico (Exames e Relatórios)',
              lawsuitStatus: lawsuitStatus,
              onPreviewRequested: _openDocumentViewer,
            ),

            // 2. Upload Cópia do Receituário Médico
            DocumentUploadCard(
              documentName: DocumentType.copia_receituario_medico.name,
              documentTitle: 'Cópia do Receituário Médico (Prescrição Médica)',
              lawsuitStatus: lawsuitStatus,
              onPreviewRequested: _openDocumentViewer,
            ),

            // 3. Upload Cópia do Expediente Administrativo da Secretaria da Saúde
            DocumentUploadCard(
              documentName:
                  DocumentType.expediente_administrativo_secretaria_saude.name,
              documentTitle:
                  'Cópia do Expediente Administrativo da Secretaria da Saúde',
              lawsuitStatus: lawsuitStatus,
              onPreviewRequested: _openDocumentViewer,
            ),

            // 4. Upload Três Últimos Holerites
            DocumentUploadCard(
              documentName: DocumentType.tres_ultimos_holerites.name,
              documentTitle: 'Três Últimos Holerites',
              lawsuitStatus: lawsuitStatus,
              onPreviewRequested: _openDocumentViewer,
            ),
          ],
        );
    }

    // Empty
    return SizedBox.shrink();
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    // ... (código original sem alterações)
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    // ... (código original sem alterações)
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.mediumGrey,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionsCard() {
    // ... (código original sem alterações)
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.mainGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: AppColors.mainGreen,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  "Ações Disponíveis",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showComingSoonDialog("Editar Ação");
                    },
                    icon: Icon(
                      Icons.edit,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text("Editar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainGreen,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showComingSoonDialog("Compartilhar");
                    },
                    icon: Icon(
                      Icons.share,
                      size: 18,
                      color: AppColors.mainGreen,
                    ),
                    label: Text("Compartilhar"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.mainGreen,
                      side: BorderSide(color: AppColors.mainGreen),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsMenu() {
    // ... (código original sem alterações)
    final String userType = userCtrl.getCurrentUserType();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.mediumGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Opções",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
              SizedBox(height: 16),

              // Condicional para exibir opções apenas para LAWYER ou ADMIN
              if (userType == 'LAWYER' || userType == 'ADMIN') ...[
                ListTile(
                  leading: Icon(Icons.edit, color: AppColors.mainGreen),
                  title: Text("Registrar Número de Processo"),
                  onTap: () {
                    Navigator.pop(context);
                    _showRegisterProcessNumberDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.file_copy, color: AppColors.blueGreen),
                  title: Text("Emitir Procuração"),
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoonDialog("Emitir Procuração");
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.edit_document, color: AppColors.blueGreen),
                  title: Text("Preencher Petição"),
                  onTap: () {
                    Navigator.pop(context);
                    _showComingSoonDialog("Preencher Petição");
                  },
                ),
              ],

              // Opções visíveis para todos os usuários
              ListTile(
                leading: Icon(Icons.cancel, color: AppColors.redColor),
                title: Text("Encerrar Ação"),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation();
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showRegisterProcessNumberDialog() {
    // ... (código original sem alterações)
    final TextEditingController _processNumberController =
        TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Registrar Número do Processo",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _processNumberController,
              decoration: InputDecoration(
                labelText: "Número do Processo Judicial",
                hintText: "0000000-00.0000.0.00.0000",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.mainGreen),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Por favor, insira o número do processo.";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancelar",
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Valida o formulário
                if (_formKey.currentState!.validate()) {
                  final numeroProcesso = _processNumberController.text;

                  // Chama o controller para atualizar o número do processo
                  ctrl.updateLawsuitJudicialProcessNumber(numeroProcesso);
                  // Atualiza também o status da ação
                  ctrl.updateLawsuitStatus("Em Andamento");

                  // Fecha o dialog
                  Navigator.of(context).pop();

                  // Atualiza a tela para refletir a mudança
                  setState(() {});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Salvar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showComingSoonDialog(String feature) {
    // ... (código original sem alterações)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Em Breve",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          content: Text(
            "A funcionalidade '$feature' estará disponível em breve!",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mediumGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: TextStyle(
                  color: AppColors.mainGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    // ... (código original sem alterações)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Encerrar Ação",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.redColor,
            ),
          ),
          content: Text(
            "Tem certeza que deseja encerrar esta ação judicial? Esta ação não pode ser desfeita.",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mediumGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancelar",
                style: TextStyle(
                  color: AppColors.mediumGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ctrl.updateLawsuitStatus("Encerrada");
                Navigator.of(context).pop();
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Encerrar",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
