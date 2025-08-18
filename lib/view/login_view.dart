import 'package:app_mobile2/controller/user_controller.dart';
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
  final Color primaryColor = Color(0xFF00796B); // Verde profissional
  final Color accentColor = Color(0xFFB2DFDB);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
// Verificar se o usuário já está logado
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    setState(() {
      _isLoading = true;
    });
    bool isLoggedIn = await ctrl.checkUserLoggedIn();
    if (isLoggedIn) {
// Se o usuário já estiver logado, navegue para a tela inicial
      Navigator.pushReplacementNamed(context, 'home');
    }
    setState(() {
      _isLoading = false;
    });
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
      body: _isLoading || ctrl.isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : Padding(
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
                          //bool success = await ctrl.login(email, password);
                          // Temporary bypass
                          bool success = true;
                          if (success) {
                            _formKey.currentState?.reset();
                            Navigator.pushReplacementNamed(context, 'home');
                          }
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
                            _formKey.currentState?.reset();
                            Navigator.pushNamed(context, 'register');
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
/*
 * Floating Action Button
 */
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'about');
        },
        child: Icon(
          Icons.question_mark_sharp,
          color: primaryColor,
        ),
      ),
    );
  }
}
