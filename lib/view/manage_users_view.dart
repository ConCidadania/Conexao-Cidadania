import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:app_mobile2/controller/user_controller.dart';
import 'package:app_mobile2/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageUsersView extends StatefulWidget {
  const ManageUsersView({super.key});

  @override
  State<ManageUsersView> createState() => _ManageUsersViewState();
}

class _ManageUsersViewState extends State<ManageUsersView> {
  final ctrl = GetIt.I.get<UserController>();
  final Color primaryColor = Color(0xFF00796B);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gerenciar Usuários", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              controller: _searchController,
              leading: const Icon(Icons.search),
              hintText: "Pesquisar por nome ou sobrenome",
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: ctrl.fetchAllUsers(orderByField),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: primaryColor));
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Ocorreu um erro: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Nenhum usuário encontrado."));
                }

                final users = snapshot.data!.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
                
                final filteredUsers = users.where((user) {
                  final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();
                  return fullName.contains(_searchQuery);
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Center(child: Text("Nenhum usuário com o nome fornecido."));
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return ListTile(
                      leading: Icon(Icons.person, color: primaryColor),
                      title: Text("${user.firstName} ${user.lastName}"),
                      subtitle: Text("RG: ${user.rg}"),
                      onTap: () => _showEditUserDialog(context, user),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, AppUser user) {
    final TextEditingController firstNameController = TextEditingController(text: user.firstName);
    final TextEditingController lastNameController = TextEditingController(text: user.lastName);
    final TextEditingController oabController = TextEditingController(text: user.registroOAB);
    bool isLawyer = user.type == UserType.LAWYER.name ? true : false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Editar Usuário"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: firstNameController,
                      decoration: InputDecoration(labelText: 'Nome'),
                    ),
                    TextField(
                      controller: lastNameController,
                      decoration: InputDecoration(labelText: 'Sobrenome'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Advogado(a)"),
                        Switch(
                          value: isLawyer,
                          onChanged: (bool value) {
                            setState(() {
                              isLawyer = value;
                            });
                          },
                          activeColor: primaryColor,
                        ),
                      ],
                    ),
                    if (isLawyer)
                      TextField(
                        controller: oabController,
                        decoration: InputDecoration(labelText: 'Registro OAB'),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar', style: TextStyle(color: Colors.red)),
                ),
                TextButton(
                  onPressed: () {
                    final updatedUser = user.copyWith(
                      firstName: firstNameController.text,
                      lastName: lastNameController.text,
                      type: isLawyer ? UserType.LAWYER.name : UserType.USER.name,
                      registroOAB: isLawyer ? oabController.text : '',
                    );
                    
                    ctrl.editUser(context, user.uid, updatedUser);
                  },
                  child: Text('Atualizar', style: TextStyle(color: primaryColor)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}