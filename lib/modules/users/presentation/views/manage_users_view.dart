import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:con_cidadania/core/utils/colors.dart';
import '../../application/state/user_state_notifier.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/value_objects/user_type.dart';
import '../../domain/value_objects/person_name.dart';
import '../../domain/value_objects/oab.dart';
import '../widgets/search_field.dart';
import '../widgets/user_type_badge.dart';

class ManageUsersView extends StatefulWidget {
  const ManageUsersView({super.key});

  @override
  State<ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<ManageUsersView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    
    // Initialize users list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserStateNotifier>().fetchAllUsers();
    });
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
      title: const Text(
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
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.refresh, color: Colors.white, size: 20),
          ),
          onPressed: () {
            context.read<UserStateNotifier>().fetchAllUsers();
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.mainGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SearchField(
        controller: _searchController,
        hintText: "Pesquisar por nome ou sobrenome...",
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        onClear: () {
          setState(() {
            _searchQuery = '';
          });
        },
      ),
    );
  }

  Widget _buildUsersList() {
    return Consumer<UserStateNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading && notifier.allUsers.isEmpty) {
          return _buildLoadingState();
        }

        if (notifier.errorMessage != null) {
          return _buildErrorState(notifier.errorMessage!);
        }

        if (notifier.allUsers.isEmpty) {
          return _buildEmptyState();
        }

        final filteredUsers = notifier.allUsers.where((user) {
          final fullName = '${user.name.firstName} ${user.name.lastName}'.toLowerCase();
          return fullName.contains(_searchQuery);
        }).toList();

        if (filteredUsers.isEmpty && _searchQuery.isNotEmpty) {
          return _buildNoSearchResultsState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            return _buildUserCard(user, notifier);
          },
        );
      },
    );
  }

  Widget _buildUserCard(AppUser user, UserStateNotifier notifier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showEditUserDialog(context, user, notifier),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blackColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.badge,
                            size: 14,
                            color: AppColors.mediumGrey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "RG: ${_formatRG(user.rg.value)}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      UserTypeBadge(userType: user.type),
                    ],
                  ),
                ),
                const Icon(
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

  Color _getUserTypeColor(UserType type) {
    switch (type) {
      case UserType.lawyer:
        return AppColors.yellowColor;
      case UserType.admin:
        return AppColors.redColor;
      case UserType.user:
        return AppColors.mainGreen;
    }
  }

  IconData _getUserTypeIcon(UserType type) {
    switch (type) {
      case UserType.lawyer:
        return Icons.gavel;
      case UserType.admin:
        return Icons.admin_panel_settings;
      case UserType.user:
        return Icons.person;
    }
  }

  Widget _buildLoadingState() {
    return const Center(
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
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.redColor,
            ),
            const SizedBox(height: 16),
            const Text(
              "Erro ao carregar usuários",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.mediumGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<UserStateNotifier>().fetchAllUsers();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
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
    return const Center(
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
    return const Center(
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

  void _showEditUserDialog(BuildContext context, AppUser user, UserStateNotifier notifier) {
    final TextEditingController firstNameController =
        TextEditingController(text: user.name.firstName);
    final TextEditingController lastNameController =
        TextEditingController(text: user.name.lastName);
    final TextEditingController oabController =
        TextEditingController(text: user.registroOAB?.value ?? '');
    bool isLawyer = user.type == UserType.lawyer;

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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.mainGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.mainGreen,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
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
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: TextField(
                        controller: firstNameController,
                        style: const TextStyle(color: AppColors.blackColor),
                        decoration: InputDecoration(
                          labelText: 'Nome',
                          labelStyle: const TextStyle(color: AppColors.mediumGrey),
                          prefixIcon: const Icon(Icons.person, color: AppColors.mainGreen),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: TextField(
                        controller: lastNameController,
                        style: const TextStyle(color: AppColors.blackColor),
                        decoration: InputDecoration(
                          labelText: 'Sobrenome',
                          labelStyle: const TextStyle(color: AppColors.mediumGrey),
                          prefixIcon: const Icon(Icons.person_outline,
                              color: AppColors.mainGreen),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
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
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: TextField(
                          controller: oabController,
                          style: const TextStyle(color: AppColors.blackColor),
                          decoration: InputDecoration(
                            labelText: 'Registro OAB',
                            labelStyle: const TextStyle(color: AppColors.mediumGrey),
                            prefixIcon: const Icon(Icons.badge, color: AppColors.mainGreen),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
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
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: AppColors.mediumGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final updatedUser = user.updateWith(
                      type: isLawyer ? UserType.lawyer : UserType.user,
                      name: PersonName.create(
                        firstNameController.text,
                        lastNameController.text,
                      ),
                      registroOAB: isLawyer && oabController.text.isNotEmpty
                          ? Oab.parse(oabController.text)
                          : null,
                    );

                    notifier.editUserById(user.id.value, updatedUser);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mainGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
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
