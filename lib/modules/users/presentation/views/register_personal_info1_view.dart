import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:con_cidadania/core/utils/colors.dart';
import '../../application/state/user_state_notifier.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/branding_panel.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/loading_button.dart';

class RegisterPersonalInfo1View extends StatefulWidget {
  const RegisterPersonalInfo1View({super.key});

  @override
  State<RegisterPersonalInfo1View> createState() => _RegisterPersonalInfo1ViewState();
}

class _RegisterPersonalInfo1ViewState extends State<RegisterPersonalInfo1View> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  String firstName = "";
  String lastName = "";
  String profession = "";
  String? gender;
  String? civilStatus;

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
            title: "Criando sua Conta",
            subtitle: "Preencha suas informações para garantir o acesso seguro à plataforma.",
            icon: Icons.person_add_alt_1,
            additionalContent: ProgressIndicatorWidget(
              currentStep: 1,
              totalSteps: 4,
              title: "Informações Pessoais",
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
                  currentStep: 1,
                  totalSteps: 4,
                  title: "Informações Pessoais",
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
                      _buildFirstNameField(),
                      const SizedBox(height: 16.0),
                      _buildLastNameField(),
                      const SizedBox(height: 16.0),
                      _buildProfessionField(),
                      const SizedBox(height: 16.0),
                      _buildGenderField(),
                      const SizedBox(height: 16.0),
                      _buildCivilStatusField(),
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
          Icons.person_add,
          size: 64,
          color: AppColors.mainGreen,
        ),
        const SizedBox(height: 16),
        const Text(
          "Vamos nos conhecer!",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
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
    return CustomTextField(
      controller: _firstNameController,
      labelText: "Nome",
      prefixIcon: Icons.person,
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
    );
  }

  Widget _buildLastNameField() {
    return CustomTextField(
      controller: _lastNameController,
      labelText: "Sobrenome",
      prefixIcon: Icons.person_outline,
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
    );
  }

  Widget _buildProfessionField() {
    return CustomTextField(
      controller: _professionController,
      labelText: "Profissão",
      hintText: "Ex: Engenheiro, Professor, etc.",
      prefixIcon: Icons.work,
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
    );
  }

  Widget _buildGenderField() {
    return CustomDropdownField<String>(
      value: gender,
      labelText: "Gênero",
      prefixIcon: Icons.wc,
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
    );
  }

  Widget _buildCivilStatusField() {
    return CustomDropdownField<String>(
      value: civilStatus,
      labelText: "Estado Civil",
      prefixIcon: Icons.favorite,
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
                  text: "Continuar",
                  isLoading: notifier.isLoading,
                  icon: Icons.arrow_forward,
                  onPressed: () => _handleNext(notifier),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleNext(UserStateNotifier notifier) {
    if (_formKey.currentState!.validate()) {
      try {
        notifier.updatePersonalInfo1(
          firstName: firstName,
          lastName: lastName,
          profession: profession,
          gender: gender,
          civilStatus: civilStatus,
        );
        //Navigator.pushNamed(context, 'registerPersonal2');
        notifier.navigationService.navigateTo('registerPersonal2');
      } catch (e) {
        // Error handling is done in the notifier
        print(e);
      }
    }
  }
}
