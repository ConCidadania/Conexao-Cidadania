import 'package:app_mobile2/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ctrl = GetIt.I.get<UserController>();
  final Color primaryColor = Color(0xFF00796B); // Verde profissional
  final Color accentColor = Color(0xFFB2DFDB);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perfil do Usuário", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await ctrl.logout();
              Navigator.pushReplacementNamed(context, 'login');
            },
          ),
        ],
      ),
      body: ctrl.currentUser == null
          ? Center(child: Text("Usuário não encontrado"))
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
// Seção de foto de perfil
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: accentColor,
                          backgroundImage:
                              ctrl.currentUser!.profilePictureUrl != null
                                  ? NetworkImage(
                                      ctrl.currentUser!.profilePictureUrl!)
                                  : null,
                          child: ctrl.currentUser!.profilePictureUrl == null
                              ? Icon(Icons.person,
                                  size: 60, color: primaryColor)
                              : null,
                        ),
                        SizedBox(height: 8),
                        TextButton.icon(
                          icon: Icon(Icons.camera_alt),
                          label: Text("Alterar foto"),
                          onPressed: () {
// Implementar upload de foto
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
// Informações do usuário
                  Text(
                    "Informações Pessoais",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
// Nome (não editável)
                  ListTile(
                    leading: Icon(Icons.person, color: primaryColor),
                    title: Text("Nome"),
                    subtitle: Text(ctrl.currentUser!.name),
                  ),
// Email (não editável)
                  ListTile(
                    leading: Icon(Icons.email, color: primaryColor),
                    title: Text("Email"),
                    subtitle: Text(ctrl.currentUser!.email),
                  ),
// Telefone (editável)
                  ListTile(
                    leading: Icon(Icons.phone, color: primaryColor),
                    title: Text("Telefone"),
                    subtitle: Text(ctrl.currentUser!.phoneNumber),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: primaryColor),
                      onPressed: () {
// Implementar edição de telefone
                      },
                    ),
                  ),
// Endereço (editável)
                  ListTile(
                    leading: Icon(Icons.home, color: primaryColor),
                    title: Text("Endereço"),
                    subtitle:
                        Text(ctrl.currentUser!.address ?? "Não informado"),
                    trailing: IconButton(
                      icon: Icon(Icons.edit, color: primaryColor),
                      onPressed: () {
// Implementar edição de endereço
                      },
                    ),
                  ),
                  SizedBox(height: 24),
// Documentos
                  Text(
                    "Documentos",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
// RG/CPF
                  ListTile(
                    leading: Icon(Icons.badge, color: primaryColor),
                    title: Text("RG/CPF"),
                    subtitle: Text(ctrl.currentUser!.rgCpf ?? "Não informado"),
                    trailing: ctrl.currentUser!.rgCpf == null
                        ? IconButton(
                            icon: Icon(Icons.add, color: primaryColor),
                            onPressed: () {
// Implementar adição de RG/CPF
                            },
                          )
                        : null,
                  ),
// CNH
                  ListTile(
                    leading: Icon(Icons.card_membership, color: primaryColor),
                    title: Text("CNH"),
                    subtitle: Text(ctrl.currentUser!.cnh ?? "Não informado"),
                    trailing: ctrl.currentUser!.cnh == null
                        ? IconButton(
                            icon: Icon(Icons.add, color: primaryColor),
                            onPressed: () {
// Implementar adição de CNH
                            },
                          )
                        : null,
                  ),
                ],
              ),
            ),
    );
  }
}
