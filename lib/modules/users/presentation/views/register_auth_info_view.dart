import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:con_cidadania/core/utils/colors.dart';
import '../../application/state/user_state_notifier.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/branding_panel.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/loading_button.dart';

class RegisterAuthInfoView extends StatefulWidget {
  const RegisterAuthInfoView({super.key});

  @override
  State<RegisterAuthInfoView> createState() => _RegisterAuthInfoViewState();
}

class _RegisterAuthInfoViewState extends State<RegisterAuthInfoView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String email = "";
  String phoneNumber = "";
  String password = "";
  String confirmedPassword = "";
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
          if (constraints.maxWidth > 800) {
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
          flex: 2,
          child: BrandingPanel(
            title: "Segurança da Conta",
            subtitle: "Estamos na última etapa! Crie suas credenciais de acesso para proteger sua conta.",
            icon: Icons.verified_user_outlined,
            additionalContent: ProgressIndicatorWidget(
              currentStep: 4,
              totalSteps: 4,
              title: "Informações de Acesso",
              isDesktop: true,
            ),
          ),
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

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildRegistrationForm(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
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
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

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
                return ProgressIndicatorWidget(
                  currentStep: 4,
                  totalSteps: 4,
                  title: "Informações de Acesso",
                );
              }
              return const SizedBox.shrink();
            }),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24.0),
                      _buildTitleSection(),
                      const SizedBox(height: 32.0),
                      _buildEmailField(),
                      const SizedBox(height: 16.0),
                      _buildPhoneField(),
                      const SizedBox(height: 16.0),
                      _buildPasswordField(),
                      const SizedBox(height: 16.0),
                      _buildConfirmPasswordField(),
                      const SizedBox(height: 24.0),
                      _buildGoogleSignInButton(),
                      const SizedBox(height: 32.0),
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

  Widget _buildTitleSection() {
    return Column(
      children: [
        const Icon(
          Icons.security,
          size: 64,
          color: AppColors.mainGreen,
        ),
        const SizedBox(height: 16),
        const Text(
          "Finalizando!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
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
        setState(() {
          email = value;
        });
      },
    );
  }

  Widget _buildPhoneField() {
    return CustomTextField(
      controller: _phoneController,
      labelText: "Telefone",
      hintText: "(11) 99999-9999",
      keyboardType: TextInputType.phone,
      maxLength: 11,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      prefixIcon: Icons.phone,
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
    );
  }

  Widget _buildPasswordField() {
    int strength = _getPasswordStrength(password);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
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
        if (password.isNotEmpty) ...[
          const SizedBox(height: 8),
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
              const SizedBox(width: 8),
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
    return CustomTextField(
      controller: _confirmPasswordController,
      labelText: "Confirmar Senha",
      obscureText: _obscureConfirmPassword,
      prefixIcon: Icons.lock,
      suffixIcon: _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
      onSuffixTap: () {
        setState(() {
          _obscureConfirmPassword = !_obscureConfirmPassword;
        });
      },
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
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () {
          _showComingSoonDialog();
        },
        icon: const SizedBox(
          width: 24,
          height: 24,
          child: Icon(Icons.g_mobiledata, color: AppColors.redColor, size: 24),
        ),
        label: const Text(
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
    return Consumer<UserStateNotifier>(
      builder: (context, notifier, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
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
                    side: const BorderSide(color: AppColors.mainGreen, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    "Voltar",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: LoadingButton(
                  text: "Finalizar Cadastro",
                  isLoading: notifier.isLoading,
                  icon: Icons.check,
                  onPressed: () => _handleRegister(notifier),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Em Breve",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blackColor,
            ),
          ),
          content: const Text(
            "O login com Google estará disponível em breve!",
            style: TextStyle(
              fontSize: 16,
              color: AppColors.mediumGrey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
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

  Future<void> _handleRegister(UserStateNotifier notifier) async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update auth info in registration data
        notifier.updateAuthInfo(
          email: email,
          phoneNumber: phoneNumber,
          password: password,
        );
        
        // Register user
        await notifier.registerUser(email, password);
        
        _formKey.currentState?.reset();
        _emailController.clear();
        _phoneController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      } catch (e) {
        // Error handling is done in the notifier
      }
    }
  }
}
