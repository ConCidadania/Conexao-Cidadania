import 'package:con_cidadania/controller/user_controller.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:con_cidadania/utils/colors.dart';

class RecoverPasswordView extends StatefulWidget {
  const RecoverPasswordView({super.key});

  @override
  State<RecoverPasswordView> createState() => _RecoverPasswordViewState();
}

class _RecoverPasswordViewState extends State<RecoverPasswordView> {
  final ctrl = GetIt.I.get<UserController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  String email = "";
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Ponto de quebra: 768 pixels
          if (constraints.maxWidth > 768) {
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
        // Painel Esquerdo: Informativo/Branding
        Expanded(
          child: _buildBrandingPanel(),
        ),
        // Painel Direito: Formulário de recuperação
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
              child: _buildRecoverPasswordContent(), // Conteúdo reutilizado
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
        title: Text(
          "Recuperar Senha",
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
            child: _buildRecoverPasswordContent(), // Conteúdo reutilizado
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
              Icon(
                Icons.lock_open,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                "Recupere seu Acesso",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                "Basta seguir as instruções enviadas para o seu e-mail para criar uma nova senha.",
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

  // Conteúdo principal (formulário e mensagem de sucesso) extraído para reutilização
  Widget _buildRecoverPasswordContent() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 450),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 32.0),
            _buildHeaderSection(),
            SizedBox(height: 32.0),
            if (!_emailSent) ...[
              _buildEmailForm(),
            ] else ...[
              _buildSuccessMessage(),
            ],
            SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  // Os widgets de conteúdo abaixo permanecem praticamente inalterados, pois já são modulares.

  Widget _buildHeaderSection() {
    // ... (código original sem alterações)
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.mainGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Icon(
            _emailSent ? Icons.mark_email_read : Icons.lock_reset,
            size: 60,
            color: AppColors.mainGreen,
          ),
        ),
        SizedBox(height: 24),
        Text(
          _emailSent ? "Email Enviado!" : "Esqueceu sua senha?",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12),
        Text(
          _emailSent
              ? "Verifique sua caixa de entrada e siga as instruções para redefinir sua senha."
              : "Não se preocupe! Digite seu email e enviaremos instruções para redefinir sua senha.",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.mediumGrey,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailForm() {
    // ... (código original sem alterações)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
            style: TextStyle(fontSize: 16, color: AppColors.blackColor),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "Email",
              labelStyle: TextStyle(color: AppColors.mediumGrey),
              prefixIcon:
                  Icon(Icons.email_outlined, color: AppColors.mainGreen),
              hintText: "Digite seu email cadastrado",
              hintStyle:
                  TextStyle(color: AppColors.mediumGrey.withOpacity(0.7)),
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

        SizedBox(height: 24.0),

        // Send Email Button
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
            onPressed: _isLoading ? null : _handleSendEmail,
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
                      Icon(
                        Icons.send,
                        size: 20,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Enviar Instruções",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        SizedBox(height: 24.0),

        // Back to Login Button
        SizedBox(
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.mainGreen,
              side: BorderSide(color: AppColors.mainGreen, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, size: 18),
                SizedBox(width: 8),
                Text(
                  "Voltar ao Login",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessMessage() {
    // ... (código original sem alterações)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Card
        Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.yellowColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 40,
                  color: AppColors.yellowColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Email enviado com sucesso!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Enviamos as instruções para:",
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.mediumGrey,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mainGreen,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Instructions Card
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.blueGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: AppColors.blueGreen.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.blueGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Próximos passos:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              _buildInstructionItem("1. Verifique sua caixa de entrada"),
              _buildInstructionItem(
                  "2. Procure por um email da Conexão Cidadania"),
              _buildInstructionItem(
                  "3. Clique no link para redefinir sua senha"),
              _buildInstructionItem("4. Crie uma nova senha segura"),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.mainGreen,
                  side: BorderSide(color: AppColors.mainGreen, width: 1.5),
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _emailSent = false;
                    _emailController.clear();
                    email = "";
                  });
                },
                child: Text(
                  "Enviar Novamente",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mainGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  "Voltar ao Login",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInstructionItem(String text) {
    // ... (código original sem alterações)
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: EdgeInsets.only(top: 8, right: 8),
            decoration: BoxDecoration(
              color: AppColors.blueGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mediumGrey,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSendEmail() async {
    // ... (código original sem alterações)
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        ctrl.resetPassword(context, email);
        setState(() {
          _emailSent = true;
        });
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
