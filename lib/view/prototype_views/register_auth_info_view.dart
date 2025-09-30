import 'package:con_cidadania/controller/user_controller.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';

class RegisterAuthInfoView extends StatefulWidget {
  const RegisterAuthInfoView({super.key});

  @override
  State<RegisterAuthInfoView> createState() => _RegisterAuthInfoViewState();
}

class _RegisterAuthInfoViewState extends State<RegisterAuthInfoView> {
  final ctrl = GetIt.I.get<UserController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color primaryColor = Color(0xFF00796B);
  final Color accentColor = Color(0xFFB2DFDB);
  String email = "";
  String phoneNumber = "";
  String password = "";
  String confirmedPassword = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro de Usuário", style: TextStyle(color: accentColor)),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(30, 50, 30, 30),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30.0),
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
                    if (value == null || value.isEmpty) {
                      return "Informe seu Email";
                    } else if (!EmailValidator.validate(value)) {
                      return "Formato de Email inválido";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Phone Number Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  maxLength: 11,
                  decoration: InputDecoration(
                    labelText: "Telefone",
                    counterText: '',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe seu Telefone";
                    } else if (value.length < 10) {
                      return "Formato de número de telefone inválido";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      phoneNumber = value;
                    });
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
                    if (value == null || value.isEmpty) {
                      return "Defina sua Senha";
                    } else if (value.length < 6) {
                      return "A senha deve ter pelo menos 6 caracteres";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      password = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Confirm Password Input Field
                 */
                TextFormField(
                  obscureText: true,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Confirmar Senha",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Confirme sua Senha";
                    } else if (value != password) {
                      return "As senhas não coincidem";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      confirmedPassword = value;
                    });
                  },
                ),
                SizedBox(height: 30.0),
                /*
                 * Continue with Google Button
                 */
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement Google sign-in logic
                    print("Continue with Google button pressed");
                  },
                  icon: Image.asset(
                    'assets/images/google_logo.png',
                    height: 24.0,
                  ),
                  label: Text("Continuar com o Google"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(color: Colors.grey),
                    ),
                    textStyle: TextStyle(fontSize: 16.0),
                  ),
                ),
                SizedBox(height: 30.0),
                /*
                 * Register Button
                 */
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: accentColor,
                    minimumSize: Size(double.infinity, 50),
                    textStyle: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      ctrl.registerUser(context, email, password, phoneNumber);
                      _formKey.currentState?.reset();
                    }
                  },
                  child: Text("Finalizar Cadastro"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}