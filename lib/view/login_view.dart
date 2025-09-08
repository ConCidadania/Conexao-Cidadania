import 'package:con_cidadania/controller/user_controller.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final ctrl = GetIt.I.get<UserController>();
  final Color primaryColor = Color(0xFF00796B);
  final Color accentColor = Color(0xFFB2DFDB);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
/*
 * AppBar
 */
      appBar: AppBar(
        title: Text("Conexão Cidadania", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
/*
 * Body
 */
      body: Padding(
        padding: EdgeInsets.fromLTRB(30, 50, 30, 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
/*
 * App Image
 */
              Container(
                height: 250, // Altura fixa
                margin: EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/images/justice.jpg',
                  fit: BoxFit.fitWidth, // Ajuste inteligente
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
                  } else if (!EmailValidator.validate(email)) {
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
 * Password Input Field
 */
              TextFormField(
                obscureText: true,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelText: "Senha",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Informe sua Senha";
                  }
                  return null;
                },
                onChanged: (value) {
                  password = value;
                },
              ),
              SizedBox(height: 30.0),
/*
 * Login Button
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
                    ctrl.login(context, email, password);
                    _formKey.currentState?.reset();
                  }
                },
                child: Text("Fazer Login"),
              ),
              SizedBox(height: 20.0),
/*
 * Register and Forgot Password Buttons
 */
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: accentColor,
                      minimumSize: Size(100, 50),
                      textStyle: TextStyle(fontSize: 15.0),
                    ),
                    onPressed: () {
                      //_formKey.currentState?.reset();
                      Navigator.pushNamed(context, 'registerPersonal1');
                    },
                    child: Text("Cadastrar Conta"),
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: accentColor,
                      minimumSize: Size(100, 50),
                      textStyle: TextStyle(fontSize: 15.0),
                    ),
                    onPressed: () {
                      _formKey.currentState?.reset();
                      Navigator.pushNamed(context, 'recover');
                    },
                    child: Text("Recuperar Senha"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}