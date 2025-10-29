import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:con_cidadania/core/utils/colors.dart';
import '../../application/state/user_state_notifier.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/branding_panel.dart';
import '../widgets/loading_button.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String email = "";
  String password = "";
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 768) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          child: BrandingPanel(
            title: "Conexão Cidadania",
            subtitle: "Acessando a justiça social de forma simples e direta.",
            icon: Icons.account_balance,
            additionalContent: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.asset(
                'assets/images/logo.jpg',
                fit: BoxFit.contain,
                height: 250,
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
              child: _buildLoginForm(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Conexão Cidadania",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: _buildLoginForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Consumer<UserStateNotifier>(
      builder: (context, notifier, child) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32.0),
                _buildWelcomeSection(),
                const SizedBox(height: 32.0),
                _buildEmailField(),
                const SizedBox(height: 16.0),
                _buildPasswordField(),
                const SizedBox(height: 24.0),
                _buildLoginButton(notifier),
                const SizedBox(height: 24.0),
                _buildActionButtons(),
                const SizedBox(height: 32.0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      controller: _emailController,
      labelText: "Email",
      keyboardType: TextInputType.emailAddress,
      prefixIcon: Icons.email_outlined,
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
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      controller: _passwordController,
      labelText: "Senha",
      obscureText: _obscurePassword,
      prefixIcon: Icons.lock_outline,
      suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
      onSuffixTap: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe sua senha";
        }
        return null;
      },
      onChanged: (value) {
        password = value;
      },
    );
  }

  Widget _buildLoginButton(UserStateNotifier notifier) {
    return LoadingButton(
      text: "Fazer Login",
      isLoading: notifier.isLoading,
      onPressed: () => _handleLogin(notifier),
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
                side: const BorderSide(color: AppColors.mainGreen, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onPressed: () {
                Navigator.pushNamed(context, 'registerPersonal1');
              },
              child: const Text(
                "Cadastrar",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12.0),
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
              child: const Text(
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

  Future<void> _handleLogin(UserStateNotifier notifier) async {
    if (_formKey.currentState!.validate()) {
      try {
        await notifier.loginUser(email, password);
        _formKey.currentState?.reset();
        _emailController.clear();
        _passwordController.clear();
      } catch (e) {
        // Error handling is done in the notifier
      }
    }
  }
}
