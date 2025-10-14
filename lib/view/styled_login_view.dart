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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String email = "";
  String password = "";
  bool _isLoading = false;
  bool _obscurePassword = true;

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
      // O AppBar é removido para dar mais espaço e controle no layout desktop
      // e é recriado dentro do layout mobile para consistência.
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Define um ponto de quebra. Se a largura for maior que 768, usa o layout de desktop.
          if (constraints.maxWidth > 768) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
      // DEBUG Login (mantido)
      floatingActionButton: AppDebugLoginBypass(context),
    );
  }

  // Layout para telas largas (Desktop)
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Painel Esquerdo: Branding
        Expanded(
          child: _buildBrandingPanel(),
        ),
        // Painel Direito: Formulário de Login
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
              child: _buildLoginForm(), // Reutiliza o formulário
            ),
          ),
        ),
      ],
    );
  }

  // Layout para telas estreitas (Mobile)
  Widget _buildMobileLayout() {
    return Scaffold(
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
            child: _buildLoginForm(), // Reutiliza o formulário
          ),
        ),
      ),
    );
  }

  // Novo Widget: Painel de branding para a versão desktop
  Widget _buildBrandingPanel() {
    return Container(
      color: AppColors.mainGreen,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Conexão Cidadania",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/images/justice.jpg',
                  fit: BoxFit.contain,
                  height: 250,
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Acessando a justiça social de forma simples e direta.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // O formulário original, agora extraído para um widget reutilizável
  Widget _buildLoginForm() {
    // Adicionado ConstrainedBox para evitar que o formulário se estique demais em telas largas
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 450),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 32.0),
            // A imagem é removida daqui e colocada no branding panel
            // e no mobile layout, se desejado. Neste caso, foi removida do mobile
            // para priorizar o conteúdo.

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

            // Campos de Email e Senha (sem alteração na lógica interna)
            _buildEmailField(),
            SizedBox(height: 16.0),
            _buildPasswordField(),
            SizedBox(height: 24.0),

            // Botão de Login
            _buildLoginButton(),
            SizedBox(height: 24.0),

            // Botões de Cadastrar e Esqueci a Senha
            _buildActionButtons(),
            SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares para os campos e botões para manter o código limpo
  Widget _buildEmailField() {
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
          email = value;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mainGreen,
                side: BorderSide(color: AppColors.mainGreen, width: 1.5),
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
    );
  }

  // A função de login permanece inalterada
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
