import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:con_cidadania/core/utils/colors.dart';
import '../../application/state/user_state_notifier.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_date_field.dart';
import '../widgets/branding_panel.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/loading_button.dart';

class RegisterPersonalInfo2View extends StatefulWidget {
  const RegisterPersonalInfo2View({super.key});

  @override
  State<RegisterPersonalInfo2View> createState() => _RegisterPersonalInfo2ViewState();
}

class _RegisterPersonalInfo2ViewState extends State<RegisterPersonalInfo2View> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _rgController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _naturalityController = TextEditingController();

  DateTime? dateOfBirth;
  String rg = "";
  String cpf = "";
  String nationality = "";
  String naturality = "";

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    _rgController.dispose();
    _cpfController.dispose();
    _nationalityController.dispose();
    _naturalityController.dispose();
    super.dispose();
  }

  String _formatName(String name) {
    if (name.isEmpty) return name;
    return name.split(' ').map((word) {
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
            title: "Dados e Documentos",
            subtitle: "Suas informações são essenciais para a validação do seu cadastro.",
            icon: Icons.assignment_ind_outlined,
            additionalContent: ProgressIndicatorWidget(
              currentStep: 2,
              totalSteps: 4,
              title: "Dados Pessoais",
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
        "Cadastro - Etapa 2",
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
                  currentStep: 2,
                  totalSteps: 4,
                  title: "Dados Pessoais",
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
                      _buildDateOfBirthField(),
                      const SizedBox(height: 16.0),
                      _buildRGField(),
                      const SizedBox(height: 16.0),
                      _buildCPFField(),
                      const SizedBox(height: 16.0),
                      _buildNationalityField(),
                      const SizedBox(height: 16.0),
                      _buildNaturalityField(),
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
          Icons.assignment_ind,
          size: 64,
          color: AppColors.mainGreen,
        ),
        const SizedBox(height: 16),
        const Text(
          "Seus documentos",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "Informe seus dados pessoais e documentos",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.mediumGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    return CustomDateField(
      controller: _dateOfBirthController,
      labelText: "Data de Nascimento",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe sua data de nascimento";
        }
        return null;
      },
      onDateSelected: (selectedDate) {
        setState(() {
          dateOfBirth = selectedDate;
        });
      },
    );
  }

  Widget _buildRGField() {
    return CustomTextField(
      controller: _rgController,
      labelText: "RG",
      keyboardType: TextInputType.number,
      maxLength: 10,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      prefixIcon: Icons.credit_card,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe seu RG";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          rg = value;
        });
      },
    );
  }

  Widget _buildCPFField() {
    return CustomTextField(
      controller: _cpfController,
      labelText: "CPF",
      hintText: "000.000.000-00",
      keyboardType: TextInputType.number,
      maxLength: 11,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      prefixIcon: Icons.badge,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe seu CPF";
        } else if (value.length < 11) {
          return "CPF inválido";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          cpf = value;
        });
      },
    );
  }

  Widget _buildNationalityField() {
    return CustomTextField(
      controller: _nationalityController,
      labelText: "Nacionalidade",
      hintText: "Ex: Brasileira",
      prefixIcon: Icons.flag,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe sua nacionalidade";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          nationality = _formatName(value);
        });
      },
    );
  }

  Widget _buildNaturalityField() {
    return CustomTextField(
      controller: _naturalityController,
      labelText: "Naturalidade",
      hintText: "Ex: São Paulo - SP",
      prefixIcon: Icons.location_city,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe sua naturalidade";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          naturality = _formatName(value);
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
        notifier.updatePersonalInfo2(
          dateOfBirth: dateOfBirth!,
          rg: rg,
          cpf: cpf,
          nationality: nationality,
          naturality: naturality,
        );
        Navigator.pushNamed(context, 'registerAddress');
      } catch (e) {
        // Error handling is done in the notifier
      }
    }
  }
}
