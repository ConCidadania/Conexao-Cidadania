import 'package:con_cidadania/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class AppDebugLoginBypass extends StatelessWidget {
  AppDebugLoginBypass(BuildContext context, {super.key});

  final Color primaryColor = Color(0xFF00796B);
  final Color accentColor = Color(0xFFB2DFDB);

  final userCtrl = GetIt.I.get<UserController>();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        addDebugUserSelectDialog(context);
      },
      backgroundColor: primaryColor,
      child: Icon(
        Icons.build_circle,
        color: accentColor,
      ),
    );
  }

  void addDebugUserSelectDialog(dynamic context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Selecione um usuário:"),
            actions: [
              TextButton(
                onPressed: () {
                  userCtrl.login(context, 'admin@email.com', 'admin123');
                },
                child: Text(
                  "ADMIN",
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              TextButton(
                onPressed: () {
                  userCtrl.login(context, 'user@email.com', 'user123');
                },
                child: Text(
                  "USER",
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              TextButton(
                onPressed: () {
                  userCtrl.login(context, 'lawyer@email.com', 'lawyer123');
                },
                child: Text(
                  "LAWYER",
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "Cancelar",
                  style: TextStyle(fontSize: 18.0),
                ),
              )
            ],
          );
        });
  }
}
