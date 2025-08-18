import 'package:app_mobile2/controller/user_controller.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RecoverPasswordView extends StatefulWidget {
  const RecoverPasswordView({super.key});
  @override
  State<RecoverPasswordView> createState() => _RecoverPasswordView();
}

class _RecoverPasswordView extends State<RecoverPasswordView> {
  final ctrl = GetIt.I.get<UserController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color primaryColor = Color(0xFF00796B); // Verde profissional
  final Color accentColor = Color(0xFFB2DFDB);
  String email = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
/*
 * AppBar
 */
      appBar: AppBar(
        title: Text("Recuperar Senha", style: TextStyle(color: accentColor)),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
/*
 * Body
 */
      body: ctrl.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Padding(
              padding: EdgeInsets.fromLTRB(30, 50, 30, 30),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 30.0),
/*
 * Error Message (if any)
 */
                    if (ctrl.errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          ctrl.errorMessage!,
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
/*
 * Email Input Field
 */
                    TextFormField(
                      style: TextStyle(fontSize: 20),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Informe seu Email";
                        } else if (!EmailValidator.validate(value)) {
                          return "Formato de Email inválido";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    SizedBox(height: 20.0),
/*
 * Recover Password Button
 */
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: accentColor,
                        minimumSize: Size(400, 50),
                        textStyle: TextStyle(fontSize: 16.0),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          bool success = await ctrl.resetPassword(email);
                          if (success) {
                            _formKey.currentState?.reset();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "Um email de recuperação foi enviado para $email"),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: Text("Recuperar Senha"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
