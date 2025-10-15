import 'package:con_cidadania/controller/user_controller.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:con_cidadania/utils/colors.dart';

class RegisterAuthInfoView extends StatefulWidget {
  const RegisterAuthInfoView({super.key});

  @override
  State<RegisterAuthInfoView> createState() => _RegisterAuthInfoViewState();
}

class _RegisterAuthInfoViewState extends State<RegisterAuthInfoView> {
  final ctrl = GetIt.I.get<UserController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String email = "";
  String phoneNumber = "";
  String password = "";
  String confirmedPassword = "";
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _getPasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;
    return strength;
  }

  Color _getPasswordStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppColors.redColor;
      case 2:
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return AppColors.yellowColor;
      default:
        return AppColors.mediumGrey;
    }
  }

  String _getPasswordStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return "Muito fraca";
      case 2:
        return "Fraca";
      case 3:
        return "Média";
      case 4:
        return "Forte";
      case 5:
        return "Muito forte";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Ponto de quebra: 800 pixels
          if (constraints.maxWidth > 800) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  // Layout para telas largas (Desktop)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildBrandingPanel(),
        ),
        Expanded(
          flex: 3,
          child: Center(
            child: _buildRegistrationForm(),
          ),
        ),
      ],
    );
  }

  // Layout para telas estreitas (Mobile)
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildRegistrationForm(),
    );
  }

  // Novo Widget: Painel informativo para a versão desktop
  Widget _buildBrandingPanel() {
    return Container(
      color: AppColors.mainGreen,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified_user_outlined,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                "Segurança da Conta",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                "Estamos na última etapa! Crie suas credenciais de acesso para proteger sua conta.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              _buildProgressIndicator(isDesktop: true),
            ],
          ),
        ),
      ),
    );
  }

  // O formulário original, agora extraído para um widget reutilizável
  Widget _buildRegistrationForm() {
    return Container(
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
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth <= 800) {
                return _buildProgressIndicator();
              }
              return SizedBox.shrink();
            }),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.0),
                      _buildTitleSection(),
                      SizedBox(height: 32.0),
                      _buildEmailField(),
                      SizedBox(height: 16.0),
                      _buildPhoneField(),
                      SizedBox(height: 16.0),
                      _buildPasswordField(),
                      SizedBox(height: 16.0),
                      _buildConfirmPasswordField(),
                      SizedBox(height: 24.0),
                      _buildGoogleSignInButton(),
                      SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // Os métodos auxiliares abaixo permanecem praticamente inalterados.

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        "Cadastro - Etapa 4",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.mainGreen,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildProgressIndicator({bool isDesktop = false}) {
    Color activeColor = Colors.white;

    return Container(
      padding: isDesktop ? EdgeInsets.zero : EdgeInsets.all(16),
      decoration: isDesktop
          ? null
          : BoxDecoration(
              color: AppColors.mainGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
      child: Column(
        children: [
          Text(
            "Informações de Acesso",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildProgressBarStep(color: activeColor)),
              SizedBox(width: 8),
              Expanded(child: _buildProgressBarStep(color: activeColor)),
              SizedBox(width: 8),
              Expanded(child: _buildProgressBarStep(color: activeColor)),
              SizedBox(width: 8),
              Expanded(child: _buildProgressBarStep(color: activeColor)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Etapa 4 de 4 - Quase lá!",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBarStep({required Color color}) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitleSection() {
    // ... (código original sem alterações)
    return Column(
      children: [
        Icon(
          Icons.security,
          size: 64,
          color: AppColors.mainGreen,
        ),
        SizedBox(height: 16),
        Text(
          "Finalizando!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          "Crie suas credenciais de acesso",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.mediumGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    // ... (código original sem alterações)
    return Container(
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
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: "Email",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.email_outlined, color: AppColors.mainGreen),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.mainGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.redColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
          setState(() {
            email = value;
          });
        },
      ),
    );
  }

  Widget _buildPhoneField() {
    // ... (código original sem alterações)
    return Container(
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
        controller: _phoneController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        keyboardType: TextInputType.phone,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ],
        decoration: InputDecoration(
          labelText: "Telefone",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.phone, color: AppColors.mainGreen),
          hintText: "(11) 99999-9999",
          hintStyle: TextStyle(color: AppColors.mediumGrey.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.mainGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.redColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Informe seu telefone";
          } else if (value.length < 10) {
            return "Número de telefone inválido";
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            phoneNumber = value;
          });
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    int strength = _getPasswordStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            style: TextStyle(fontSize: 16, color: AppColors.blackColor),
            decoration: InputDecoration(
              labelText: "Senha",
              labelStyle: TextStyle(color: AppColors.mediumGrey),
              prefixIcon: Icon(Icons.lock_outline, color: AppColors.mainGreen),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                borderSide: BorderSide(color: AppColors.mainGreen, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: AppColors.redColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Defina sua senha";
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
        ),
        if (password.isNotEmpty) ...[
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: strength / 5,
                  backgroundColor: AppColors.mediumGrey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getPasswordStrengthColor(strength),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                _getPasswordStrengthText(strength),
                style: TextStyle(
                  fontSize: 12,
                  color: _getPasswordStrengthColor(strength),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmPasswordField() {
    // ... (código original sem alterações)
    return Container(
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
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        decoration: InputDecoration(
          labelText: "Confirmar Senha",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.lock, color: AppColors.mainGreen),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: AppColors.mediumGrey,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.mainGreen, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.redColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Confirme sua senha";
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
    );
  }

  Widget _buildGoogleSignInButton() {
    // ... (código original sem alterações)
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          _showComingSoonDialog();
        },
        icon: SizedBox(
          width: 24,
          height: 24,
          child: Icon(Icons.g_mobiledata, color: AppColors.redColor, size: 24),
        ),
        label: Text(
          "Continuar com o Google",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
              color: AppColors.mediumGrey.withOpacity(0.5), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    // ... (código original sem alterações)
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mainGreen,
                side: BorderSide(color: AppColors.mainGreen, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: Text(
                "Voltar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGreen,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shadowColor: AppColors.mainGreen.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Finalizar Cadastro",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.check, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog() {
    // ... (código original sem alterações)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Em Breve",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          content: Text(
            "O login com Google estará disponível em breve!",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mediumGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "OK",
                style: TextStyle(
                  color: AppColors.mainGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRegister() async {
    // ... (código original sem alterações)
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        ctrl.registerUser(context, email, password, phoneNumber);
        _formKey.currentState?.reset();
        _emailController.clear();
        _phoneController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
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
