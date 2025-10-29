import 'package:con_cidadania/old/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:con_cidadania/core/utils/colors.dart';

class RegisterPersonalInfo1View extends StatefulWidget {
  const RegisterPersonalInfo1View({super.key});

  @override
  State<RegisterPersonalInfo1View> createState() =>
      _RegisterPersonalInfo1ViewState();
}

class _RegisterPersonalInfo1ViewState extends State<RegisterPersonalInfo1View> {
  final ctrl = GetIt.I.get<UserController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  String firstName = "";
  String lastName = "";
  String profession = "";
  String? gender;
  String? civilStatus;
  bool _isLoading = false;

  final List<String> genders = ['Masculino', 'Feminino', 'Outro'];
  final List<String> civilStatuses = [
    'Solteiro(a)',
    'Casado(a)',
    'Divorciado(a)',
    'Viúvo(a)',
    'Separado(a)'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  String _formatName(String name) {
    if (name.isEmpty) return name;
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatProfession(String profession) {
    if (profession.isEmpty) return profession;
    return profession.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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
        // Painel Esquerdo: Branding e Progresso
        Expanded(
          flex: 2, // Ocupa menos espaço que o formulário
          child: _buildBrandingPanel(),
        ),
        // Painel Direito: Formulário de Cadastro
        Expanded(
          flex: 3, // Ocupa mais espaço
          child: Center(
            child: _buildRegistrationForm(), // Reutiliza o formulário
          ),
        ),
      ],
    );
  }

  // Layout para telas estreitas (Mobile)
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildRegistrationForm(), // Reutiliza o formulário
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
                Icons.person_add_alt_1,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                "Criando sua Conta",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                "Preencha suas informações para garantir o acesso seguro à plataforma.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // Indicador de progresso adaptado para o painel
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
            // No mobile, o indicador fica aqui. No desktop, ele está no painel esquerdo.
            // O LayoutBuilder nos ajuda a decidir se devemos mostrar este widget.
            LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth <= 800) {
                return _buildProgressIndicator();
              }
              return SizedBox.shrink(); // Não mostra nada no desktop
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
                      _buildFirstNameField(),
                      SizedBox(height: 16.0),
                      _buildLastNameField(),
                      SizedBox(height: 16.0),
                      _buildProfessionField(),
                      SizedBox(height: 16.0),
                      _buildGenderField(),
                      SizedBox(height: 16.0),
                      _buildCivilStatusField(),
                      SizedBox(height: 32.0),
                    ],
                  ),
                ),
              ),
            ),

            // Navegação inferior
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  // Os métodos auxiliares abaixo permanecem praticamente inalterados.
  // Apenas o _buildProgressIndicator recebe um parâmetro para estilização.

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        "Cadastro - Etapa 1",
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
    Color activeColor = isDesktop ? Colors.white : Colors.white;
    Color inactiveColor = isDesktop
        ? Colors.white.withOpacity(0.3)
        : Colors.white.withOpacity(0.3);
    Color textColor = isDesktop ? Colors.white : Colors.white;

    return Container(
      padding: isDesktop ? EdgeInsets.zero : EdgeInsets.all(16),
      decoration: isDesktop
          ? null // Sem decoração extra no desktop
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
            "Informações Pessoais",
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildProgressBarStep(
                      isActive: true, color: activeColor)),
              SizedBox(width: 8),
              Expanded(
                  child: _buildProgressBarStep(
                      isActive: false, color: inactiveColor)),
              SizedBox(width: 8),
              Expanded(
                  child: _buildProgressBarStep(
                      isActive: false, color: inactiveColor)),
              SizedBox(width: 8),
              Expanded(
                  child: _buildProgressBarStep(
                      isActive: false, color: inactiveColor)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Etapa 1 de 4",
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBarStep({required bool isActive, required Color color}) {
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
          Icons.person_add,
          size: 64,
          color: AppColors.mainGreen,
        ),
        SizedBox(height: 16),
        Text(
          "Vamos nos conhecer!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          "Conte-nos um pouco sobre você",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.mediumGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFirstNameField() {
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
        controller: _firstNameController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: "Nome",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.person, color: AppColors.mainGreen),
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
            return "Informe seu nome";
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            firstName = _formatName(value);
          });
        },
      ),
    );
  }

  Widget _buildLastNameField() {
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
        controller: _lastNameController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: "Sobrenome",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.person_outline, color: AppColors.mainGreen),
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
            return "Informe seu sobrenome";
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            lastName = _formatName(value);
          });
        },
      ),
    );
  }

  Widget _buildProfessionField() {
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
        controller: _professionController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: "Profissão",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.work, color: AppColors.mainGreen),
          hintText: "Ex: Engenheiro, Professor, etc.",
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
            return "Informe sua profissão";
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            profession = _formatProfession(value);
          });
        },
      ),
    );
  }

  Widget _buildGenderField() {
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
      child: DropdownButtonFormField<String>(
        value: gender,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        decoration: InputDecoration(
          labelText: "Gênero",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.wc, color: AppColors.mainGreen),
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
        items: genders.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return "Selecione seu gênero";
          }
          return null;
        },
        onChanged: (String? newValue) {
          setState(() {
            gender = newValue;
          });
        },
      ),
    );
  }

  Widget _buildCivilStatusField() {
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
      child: DropdownButtonFormField<String>(
        value: civilStatus,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        decoration: InputDecoration(
          labelText: "Estado Civil",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.favorite, color: AppColors.mainGreen),
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
        items: civilStatuses.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return "Selecione seu estado civil";
          }
          return null;
        },
        onChanged: (String? newValue) {
          setState(() {
            civilStatus = newValue;
          });
        },
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
              onPressed: _isLoading ? null : _handleNext,
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
                          "Continuar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    // ... (código original sem alterações)
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        ctrl.updatePersonalInfo1(
            firstName, lastName, profession, gender, civilStatus);
        Navigator.pushNamed(context, 'registerPersonal2');
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
