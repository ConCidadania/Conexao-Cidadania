import 'package:con_cidadania/utils/time.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:con_cidadania/controller/user_controller.dart';
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:con_cidadania/model/lawsuit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:con_cidadania/utils/colors.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final userCtrl = GetIt.I.get<UserController>();
  final lawsuitCtrl = GetIt.I.get<LawsuitController>();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<LawsuitType, Map<String, dynamic>> lawsuitOptions = {
    LawsuitType.REMEDIO_ALTO_CUSTO: {
      'name': 'Remédio de Alto Custo',
      'icon': Icons.medical_services,
      'color': AppColors.redColor,
    },
    LawsuitType.VAGA_CRECHE_PUBLICA: {
      'name': 'Vaga em Creche Pública',
      'icon': Icons.child_friendly,
      'color': AppColors.yellowColor,
    },
    LawsuitType.CIRURGIA_EMERGENCIAL: {
      'name': 'Cirurgia de Emergência',
      'icon': Icons.local_hospital,
      'color': AppColors.redColor,
    },
    LawsuitType.ALTERACAO_NOME_SOCIAL: {
      'name': 'Alteração de Nome Social',
      'icon': Icons.drive_file_rename_outline,
      'color': AppColors.blueGreen,
    },
    LawsuitType.INTERNACAO_ILP: {
      'name': 'Internação em Instituto de Longa Permanência',
      'icon': Icons.elderly,
      'color': AppColors.tealGreen,
    },
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  String _formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      DateTime now = DateTime.now();
      Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        return "Hoje";
      } else if (difference.inDays == 1) {
        return "Ontem";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} dias atrás";
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(
            child: _buildLawsuitsList(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: FutureBuilder<String>(
        future: userCtrl.getCurrentUserName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text(
              "Carregando...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            );
          } else if (snapshot.hasError) {
            return Text(
              "Bem-vindo!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            );
          } else {
            return Text(
              "Olá, ${snapshot.data}!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            );
          }
        },
      ),
      centerTitle: true,
      backgroundColor: AppColors.mainGreen,
      elevation: 0,
      actions: [
        Container(
          margin: EdgeInsets.only(right: 8),
          child: IconButton(
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.logout, color: Colors.white, size: 20),
            ),
            onPressed: () async {
              _showLogoutDialog();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.mainGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: AppColors.blackColor),
          decoration: InputDecoration(
            hintText: "Pesquisar ações judiciais...",
            hintStyle: TextStyle(color: AppColors.mediumGrey),
            prefixIcon: Icon(Icons.search, color: AppColors.mainGreen),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.mediumGrey),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildLawsuitsList() {
    return FutureBuilder<String>(
      future: userCtrl.getCurrentUserTypeFuture(),
      builder: (context, typeSnapshot) {
        if (typeSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        String userType = typeSnapshot.data ?? "USER";
        Stream<QuerySnapshot> lawsuitStream;

        if (userType == "USER") {
          lawsuitStream = lawsuitCtrl.fetchUserLawsuits("ownerId");
        } else {
          lawsuitStream = lawsuitCtrl.fetchAllLawsuits("ownerFirstName");
        }

        return StreamBuilder<QuerySnapshot>(
          stream: lawsuitStream,
          builder: (context, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            if (streamSnapshot.hasError) {
              return _buildErrorState(streamSnapshot.error.toString());
            }
            if (!streamSnapshot.hasData || streamSnapshot.data!.docs.isEmpty) {
              return _buildEmptyState();
            }

            final lawsuits = streamSnapshot.data!.docs
                .map((doc) => Lawsuit.fromFirestore(doc))
                .toList();

            final List<Lawsuit> filteredLawsuits;
            if (userType == 'USER') {
              // Usuários podem pesquisar pelo nome da ação
              filteredLawsuits = lawsuits.where((lawsuit) {
                return lawsuit.name.toLowerCase().contains(_searchQuery);
              }).toList();
            } else {
              // Advogados podem pesquisar pelo nome do dono da ação
              filteredLawsuits = lawsuits.where((lawsuit) {
                return lawsuit.ownerFirstName
                    .toLowerCase()
                    .contains(_searchQuery);
              }).toList();
            }

            if (filteredLawsuits.isEmpty && _searchQuery.isNotEmpty) {
              return _buildNoSearchResultsState();
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: filteredLawsuits.length,
              itemBuilder: (context, index) {
                final lawsuit = filteredLawsuits[index];
                return _buildLawsuitCard(lawsuit);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildLawsuitCard(Lawsuit lawsuit) {
    LawsuitType? lawsuitType;
    try {
      lawsuitType = LawsuitType.values.firstWhere(
        (type) => type.name == lawsuit.type,
      );
    } catch (e) {
      lawsuitType = null;
    }

    final typeInfo = lawsuitType != null ? lawsuitOptions[lawsuitType] : null;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            lawsuitCtrl.setCurrentLawsuitId(lawsuit.uid);
            Navigator.pushNamed(context, 'manageLawsuit');
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (typeInfo?['color'] ?? AppColors.mainGreen)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    typeInfo?['icon'] ?? Icons.assignment,
                    color: typeInfo?['color'] ?? AppColors.mainGreen,
                    size: 28,
                  ),
                ),

                SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lawsuit.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.mediumGrey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Aberto em: ${_formatDate(lawsuit.createdAt)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.account_circle_outlined,
                            size: 14,
                            color: AppColors.mediumGrey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Aberto por: ${lawsuit.ownerFirstName} ${lawsuit.ownerLastName}",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.mediumGrey,
                ),
              ],
            ),
          ),
        ),
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
            "Carregando ações...",
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
              "Ocorreu um erro",
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
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.mediumGrey,
            ),
            SizedBox(height: 16),
            Text(
              "Nenhuma ação encontrada",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Toque no botão + para criar sua primeira ação judicial",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResultsState() {
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
              "Nenhum resultado encontrado",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Tente pesquisar com outros termos",
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FutureBuilder<String>(
      future: userCtrl.getCurrentUserTypeFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return FloatingActionButton(
            onPressed: () {},
            backgroundColor: AppColors.mainGreen,
            elevation: 8,
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return FloatingActionButton.extended(
            onPressed: () => _showLawsuitTypeDialog(context),
            backgroundColor: AppColors.mainGreen,
            elevation: 8,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              "Nova Ação",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        } else {
          String userType = snapshot.data!;

          if (userType == "ADMIN") {
            return FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, 'manageUsers'),
              backgroundColor: AppColors.blueGreen,
              elevation: 8,
              icon: Icon(Icons.people, color: Colors.white),
              label: Text(
                "Usuários",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          } else {
            return FloatingActionButton.extended(
              onPressed: () => _showLawsuitTypeDialog(context),
              backgroundColor: AppColors.mainGreen,
              elevation: 8,
              icon: Icon(Icons.add, color: Colors.white),
              label: Text(
                "Nova Ação",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
        }
      },
    );
  }

  void _showLawsuitTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Nova Ação Judicial",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: lawsuitOptions.length,
              itemBuilder: (context, index) {
                final lawsuitType = lawsuitOptions.keys.elementAt(index);
                final data = lawsuitOptions[lawsuitType]!;

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      Navigator.of(context).pop();

                      final userUid = userCtrl.getCurrentUserId();
                      final user = userCtrl.getCurrentUser();
                      final newLawsuit = Lawsuit(
                        name: data['name'],
                        type: lawsuitType.name,
                        ownerId: userUid,
                        ownerFirstName: user!.firstName,
                        ownerLastName: user.lastName,
                        ownerPhoneNumber: user.phoneNumber,
                        ownerEmail: user.email,
                        createdAt: formatDate(DateTime.now()),
                      );
                      lawsuitCtrl.addLawsuit(context, newLawsuit);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: data['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              data['icon'],
                              size: 28,
                              color: data['color'],
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            data['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
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
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Sair da conta",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          content: Text(
            "Tem certeza que deseja sair da sua conta?",
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
              onPressed: () async {
                Navigator.of(context).pop();
                userCtrl.logout();
                Navigator.pushReplacementNamed(context, 'login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.redColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Sair",
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
