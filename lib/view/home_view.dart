import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:app_mobile2/controller/user_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ctrl = GetIt.I.get<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: ctrl.getCurrentUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Carregando...", style: TextStyle(color: Colors.white));
            } else if (snapshot.hasError) {
              return Text("Bem Vindo Usuário!", style: TextStyle(color: Colors.white));
            } else {
              return Text(
                "Bem Vindo ${snapshot.data.toString()}!",
                style: TextStyle(color: Colors.white),
              );
            }
          },
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF00796B),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              ctrl.logout();
              Navigator.pushReplacementNamed(context, 'login');
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          "Em Construção",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00796B),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FutureBuilder<String>(
      future: ctrl.getCurrentUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return FloatingActionButton(
            onPressed: () {},
            backgroundColor: Color(0xFF00796B),
            child: CircularProgressIndicator(color: Colors.white),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          // Default para o tipo de usuário 'USER' em caso de erro
          return FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, 'home');
            },
            backgroundColor: Color(0xFF00796B),
            child: Icon(Icons.assignment_rounded, color: Color(0xFFB2DFDB)),
          );
        } else {
          String userType = snapshot.data!;
          IconData icon;
          String route;

          if (userType == "ADMIN") {
            icon = Icons.assignment_ind_rounded;
            route = 'manageUsers';
          } else {
            icon = Icons.assignment_rounded;
            route = 'home';
          }

          return FloatingActionButton(
            onPressed: () {
             Navigator.pushNamed(context, route);
            },
            backgroundColor: Color(0xFF00796B),
            child: Icon(icon, color: Color(0xFFB2DFDB)),
          );
        }
      },
    );
  }
}