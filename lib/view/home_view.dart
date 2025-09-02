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
              return Text("Carregando...",
                  style: TextStyle(color: Colors.white));
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
    );
  }
}
