import 'package:con_cidadania/controller/user_controller.dart';
import 'package:con_cidadania/view/widgets/app_debug_login_bypass.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:con_cidadania/utils/colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});
  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final ctrl = GetIt.I.get<UserController>();

  // Updated color scheme from user's logo
  // final Color AppColors.mainGreen = Color(0xFF44BF4D);      // RGB(68,191,77)
  // final Color AppColors.darkGreen = Color(0xFF238F3E);      // RGB(35,143,62)
  // final Color AppColors.tealGreen = Color(0xFF036C65);      // RGB(3,108,101)
  // final Color AppColors.blueGreen = Color(0xFF22858E);      // RGB(34,133,142)
  // final Color AppColors.redColor = Color(0xFFEE0000);       // RGB(238,0,0)
  // final Color AppColors.yellowColor = Color(0xFF90E500);    // RGB(144,229,0)
  // final Color AppColors.blackColor = Color(0xFF000000);     // RGB(0,0,0)
  // final Color AppColors.mediumGrey = Color(0xFF757575);
  // final Color AppColors.lightGrey = Color(0xFFF5F5F5);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String email = "";
  String password = "";
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        title: Text("Conexão Cidadania",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            )),
        centerTitle: true,
        backgroundColor: AppColors.mainGreen,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.mainGreen.withOpacity(0.1),
              AppColors.lightGrey,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 32.0),

                  // App Logo/Image Section
                  Container(
                    height: 200,
                    margin: EdgeInsets.only(bottom: 32.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.asset(
                        'assets/images/justice.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  // Welcome Text
                  Text(
                    "Bem-vindo de volta!",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blackColor,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  Text(
                    "Faça login para continuar",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.mediumGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 32.0),

                  // Email Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      style:
                          TextStyle(fontSize: 16, color: AppColors.blackColor),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: TextStyle(color: AppColors.mediumGrey),
                        prefixIcon: Icon(Icons.email_outlined,
                            color: AppColors.mainGreen),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              BorderSide(color: AppColors.mainGreen, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              BorderSide(color: AppColors.redColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Informe seu email";
                        } else if (!EmailValidator.validate(value)) {
                          return "Formato de email inválido";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                  ),

                  SizedBox(height: 16.0),

                  // Password Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style:
                          TextStyle(fontSize: 16, color: AppColors.blackColor),
                      decoration: InputDecoration(
                        labelText: "Senha",
                        labelStyle: TextStyle(color: AppColors.mediumGrey),
                        prefixIcon: Icon(Icons.lock_outline,
                            color: AppColors.mainGreen),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.mediumGrey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              BorderSide(color: AppColors.mainGreen, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide:
                              BorderSide(color: AppColors.redColor, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Informe sua senha";
                        }
                        return null;
                      },
                      onChanged: (value) {
                        password = value;
                      },
                    ),
                  ),

                  SizedBox(height: 24.0),

                  // Login Button
                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mainGreen,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.mainGreen.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              "Fazer Login",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 24.0),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.mainGreen,
                              side: BorderSide(
                                  color: AppColors.mainGreen, width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, 'registerPersonal1');
                            },
                            child: Text(
                              "Cadastrar",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.mainGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, 'recover');
                            },
                            child: Text(
                              "Esqueci a senha",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32.0),
                ],
              ),
            ),
          ),
        ),
      ),
      // DEBUG Login
      floatingActionButton: AppDebugLoginBypass(context),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        ctrl.login(context, email, password);
        _formKey.currentState?.reset();
        _emailController.clear();
        _passwordController.clear();
      } catch (e) {
        // Error handling is likely done in the controller
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
}
