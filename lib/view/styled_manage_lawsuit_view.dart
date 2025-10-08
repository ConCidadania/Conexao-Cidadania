import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:con_cidadania/model/lawsuit_model.dart';
import 'package:con_cidadania/view/widgets/document_upload_card.dart';
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

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy \'às\' HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // ignore: unused_element
  String _getRelativeDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        return "Hoje";
      } else if (difference.inDays == 1) {
        return "Ontem";
      } else if (difference.inDays < 30) {
        return "${difference.inDays} dias atrás";
      } else if (difference.inDays < 365) {
        int months = (difference.inDays / 30).floor();
        return "$months ${months == 1 ? 'mês' : 'meses'} atrás";
      } else {
        int years = (difference.inDays / 365).floor();
        return "$years ${years == 1 ? 'ano' : 'anos'} atrás";
      }
    } catch (e) {
      return "Data inválida";
    }
  }

  IconData _getLawsuitIcon(String type) {
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

  // ignore: unused_element
  Color _getLawsuitColor(String type) {
    switch (type) {
      case 'REMEDIO_ALTO_CUSTO':
        return AppColors.redColor;
      case 'VAGA_CRECHE_PUBLICA':
        return AppColors.yellowColor;
      case 'CIRURGIA_EMERGENCIAL':
        return AppColors.redColor;
      case 'ALTERACAO_NOME_SOCIAL':
        return AppColors.blueGreen;
      case 'INTERNACAO_ILP':
        return AppColors.tealGreen;
      default:
        return AppColors.mainGreen;
    }
  }

  String _getLawsuitTypeName(String type) {
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
            return _buildLawsuitDetails(currLawsuit);
          }
        },
      ),
    );
  }

  Widget _buildLoadingState() {
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

  Widget _buildUniqueDocUploadCards(String lawsuitType) {
    switch (lawsuitType) {
      case 'VAGA_CRECHE_PUBLICA':
        return Column(
          children: [
            // 1. Upload Protocolo de Inscrição na Creche
            DocumentUploadCard(
              documentName: DocumentType.protocolo_inscricao_creche.name,
              documentTitle: 'Protocolo de Inscrição na Creche',
            ),

            // 2. Upload Documento Pessoal da Criança
            DocumentUploadCard(
              documentName: DocumentType.documento_identidade_crianca.name,
              documentTitle:
                  'Documento Pessoal da Criança (Cetidão de Nascimento, RG)',
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
            ),

            // 2. Upload Cópia do Receituário Médico
            DocumentUploadCard(
              documentName: DocumentType.copia_receituario_medico.name,
              documentTitle: 'Cópia do Receituário Médico (Prescrição Médica)',
            ),

            // 3. Upload Cópia do Expediente Administrativo da Secretaria da Saúde
            DocumentUploadCard(
              documentName:
                  DocumentType.expediente_administrativo_secretaria_saude.name,
              documentTitle:
                  'Cópia do Expediente Administrativo da Secretaria da Saúde',
            ),

            // 4. Upload Três Últimos Holerites
            DocumentUploadCard(
              documentName: DocumentType.tres_ultimos_holerites.name,
              documentTitle: 'Três Últimos Holerites',
            ),
          ],
        );
    }

    // Empty
    return SizedBox.shrink();
  }

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

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            ),
          ),

          // Details Cards
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Date Information Card
                _buildInfoCard(
                  title: "Informações Gerais",
                  icon: Icons.calendar_today,
                  color: AppColors.yellowColor,
                  children: [
                    _buildInfoRow(
                      "Data de Abertura",
                      _formatDate(createdAt),
                      Icons.event,
                    ),
                    SizedBox(height: 10),
                    _buildInfoRow(
                      "Aberto por",
                      ownerName,
                      Icons.account_circle,
                    ),
                    SizedBox(height: 10),
                    _buildInfoRow(
                      "Email",
                      ownerEmail,
                      Icons.email,
                    ),
                    SizedBox(height: 10),
                    _buildInfoRow(
                      "Telefone",
                      ownerPhoneNumber,
                      Icons.phone,
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Documents Card
                _buildInfoCard(
                  title: "Anexar Documentos",
                  icon: Icons.attach_file_rounded,
                  color: AppColors.darkGreen,
                  children: [
                    // 1. Upload de Documento de Identidade
                    DocumentUploadCard(
                      documentName: DocumentType.documento_identidade.name,
                      documentTitle:
                          'Documento de Identidade (RG, CNH, Certidão)',
                    ),

                    // 2. Upload de Comprovante de Endereço
                    DocumentUploadCard(
                      documentName: DocumentType.comprovante_endereco.name,
                      documentTitle: 'Comprovante de Endereço',
                    ),

                    // Cards de upload de documentos contextuais baseados no tipo da ação
                    _buildUniqueDocUploadCards(type),
                  ],
                ),

                SizedBox(height: 16),

                // Status Card
                _buildInfoCard(
                  title: "Status da Ação",
                  icon: Icons.info_outline,
                  color: AppColors.blueGreen,
                  children: [
                    _buildInfoRow(
                      "Status Atual",
                      "Em Andamento",
                      Icons.pending_actions,
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Actions Card
                _buildActionsCard(),

                SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
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
                    icon: Icon(Icons.edit, size: 18),
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
                    icon: Icon(Icons.share, size: 18),
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
              ListTile(
                leading: Icon(Icons.edit, color: AppColors.mainGreen),
                title: Text("Editar Ação"),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonDialog("Editar Ação");
                },
              ),
              ListTile(
                leading: Icon(Icons.share, color: AppColors.blueGreen),
                title: Text("Compartilhar"),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonDialog("Compartilhar");
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: AppColors.redColor),
                title: Text("Excluir Ação"),
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

  void _showComingSoonDialog(String feature) {
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
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Excluir Ação",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.redColor,
            ),
          ),
          content: Text(
            "Tem certeza que deseja excluir esta ação judicial? Esta ação não pode ser desfeita.",
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
                Navigator.of(context).pop();
                _showComingSoonDialog("Excluir Ação");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Excluir",
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
