import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:con_cidadania/old/controller/user_controller.dart';
import 'package:con_cidadania/old/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:con_cidadania/core/utils/colors.dart';

class ManageUsersView extends StatefulWidget {
  const ManageUsersView({super.key});

  @override
  State<ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<ManageUsersView> {
  final ctrl = GetIt.I.get<UserController>();

  final TextEditingController _searchController = TextEditingController();
  final String orderByField = 'firstName';
  String _searchQuery = '';

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

  String _formatRG(String rg) {
    if (rg.isEmpty) return "Não informado";
    if (rg.length == 9) {
      return "${rg.substring(0, 2)}.${rg.substring(2, 5)}.${rg.substring(5, 8)}-${rg.substring(8)}";
    }
    return rg;
  }

  String _formatUserType(String type) {
    switch (type) {
      case 'LAWYER':
        return 'Advogado(a)';
      case 'ADMIN':
        return 'Administrador(a)';
      case 'USER':
      default:
        return 'Usuário';
    }
  }

  Color _getUserTypeColor(String type) {
    switch (type) {
      case 'LAWYER':
        return AppColors.yellowColor;
      case 'ADMIN':
        return AppColors.redColor;
      case 'USER':
      default:
        return AppColors.mainGreen;
    }
  }

  IconData _getUserTypeIcon(String type) {
    switch (type) {
      case 'LAWYER':
        return Icons.gavel;
      case 'ADMIN':
        return Icons.admin_panel_settings;
      case 'USER':
      default:
        return Icons.person;
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
            child: _buildUsersList(),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        "Gerenciar Usuários",
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
          icon: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
          onPressed: () => setState(() {}),
        ),
        SizedBox(width: 8),
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
            hintText: "Pesquisar por nome ou sobrenome...",
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

  Widget _buildUsersList() {
    return StreamBuilder<QuerySnapshot>(
      stream: ctrl.fetchAllUsers(orderByField),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final users = snapshot.data!.docs
            .map((doc) => AppUser.fromFirestore(doc))
            .toList();

        final filteredUsers = users.where((user) {
          final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
          return fullName.contains(_searchQuery);
        }).toList();

        if (filteredUsers.isEmpty && _searchQuery.isNotEmpty) {
          return _buildNoSearchResultsState();
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return _buildUserCard(user);
          },
        );
      },
    );
  }

  Widget _buildUserCard(AppUser user) {
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
          onTap: () => _showEditUserDialog(context, user),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getUserTypeColor(user.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getUserTypeIcon(user.type),
                    color: _getUserTypeColor(user.type),
                    size: 28,
                  ),
                ),

                SizedBox(width: 16),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      Text(
                        "${user.firstName} ${user.lastName}",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4),

                      // RG
                      Row(
                        children: [
                          Icon(
                            Icons.badge,
                            size: 14,
                            color: AppColors.mediumGrey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "RG: ${_formatRG(user.rg)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4),

                      // User Type Badge
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getUserTypeColor(user.type).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatUserType(user.type),
                          style: TextStyle(
                            fontSize: 12,
                            color: _getUserTypeColor(user.type),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit Icon
                Icon(
                  Icons.edit,
                  size: 20,
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
            "Carregando usuários...",
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
              "Erro ao carregar usuários",
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.mediumGrey,
            ),
            SizedBox(height: 16),
            Text(
              "Nenhum usuário encontrado",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Não há usuários cadastrados no sistema",
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
              "Nenhum usuário encontrado",
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

  void _showEditUserDialog(BuildContext context, AppUser user) {
    final TextEditingController firstNameController =
        TextEditingController(text: user.firstName);
    final TextEditingController lastNameController =
        TextEditingController(text: user.lastName);
    final TextEditingController oabController =
        TextEditingController(text: user.registroOAB);
    bool isLawyer = user.type == UserType.LAWYER.name ? true : false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.mainGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: AppColors.mainGreen,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Editar Usuário",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // First Name Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: TextField(
                        controller: firstNameController,
                        style: TextStyle(color: AppColors.blackColor),
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          labelStyle: TextStyle(color: AppColors.mediumGrey),
                          prefixIcon:
                              Icon(Icons.person, color: AppColors.mainGreen),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Last Name Field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: TextField(
                        controller: lastNameController,
                        style: TextStyle(color: AppColors.blackColor),
                        decoration: InputDecoration(
                          labelText: 'Sobrenome',
                          labelStyle: TextStyle(color: AppColors.mediumGrey),
                          prefixIcon: Icon(Icons.person_outline,
                              color: AppColors.mainGreen),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Lawyer Switch
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.gavel, color: AppColors.mainGreen),
                              SizedBox(width: 12),
                              Text(
                                "Advogado(a)",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.blackColor,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: isLawyer,
                            onChanged: (bool value) {
                              setState(() {
                                isLawyer = value;
                              });
                            },
                            activeColor: AppColors.mainGreen,
                          ),
                        ],
                      ),
                    ),

                    if (isLawyer) ...[
                      SizedBox(height: 16),

                      // OAB Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: TextField(
                          controller: oabController,
                          style: TextStyle(color: AppColors.blackColor),
                          decoration: InputDecoration(
                            labelText: 'Registro OAB',
                            labelStyle: TextStyle(color: AppColors.mediumGrey),
                            prefixIcon:
                                Icon(Icons.badge, color: AppColors.mainGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedUser = user.copyWith(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      type:
                          isLawyer ? UserType.LAWYER.name : UserType.USER.name,
                      registroOAB: isLawyer ? oabController.text : '',
                    );

                    ctrl.editUser(context, user.uid, updatedUser);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Atualizar',
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
      },
    );
  }
}
