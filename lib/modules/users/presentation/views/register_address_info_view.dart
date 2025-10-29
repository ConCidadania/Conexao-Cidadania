import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:con_cidadania/core/utils/colors.dart';
import '../../application/state/user_state_notifier.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/branding_panel.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/loading_button.dart';

class RegisterAddressInfoView extends StatefulWidget {
  const RegisterAddressInfoView({super.key});

  @override
  State<RegisterAddressInfoView> createState() => _RegisterAddressInfoViewState();
}

class _RegisterAddressInfoViewState extends State<RegisterAddressInfoView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _complementController = TextEditingController();
  final TextEditingController _neighborhoodController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  String street = "";
  String number = "";
  String? complement;
  String neighborhood = "";
  String city = "";
  String state = "";
  String country = "Brasil";
  String postalCode = "";

  @override
  void dispose() {
    _cepController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  String _formatCEP(String cep) {
    String digits = cep.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 8) {
      return "${digits.substring(0, 5)}-${digits.substring(5)}";
    }
    return cep;
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
            title: "Informações de Endereço",
            subtitle: "Seu endereço é importante para a correta identificação nos processos.",
            icon: Icons.home_work_outlined,
            additionalContent: ProgressIndicatorWidget(
              currentStep: 3,
              totalSteps: 4,
              title: "Informações de Endereço",
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
        "Cadastro - Etapa 3",
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
                  currentStep: 3,
                  totalSteps: 4,
                  title: "Informações de Endereço",
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
                      _buildCEPField(),
                      const SizedBox(height: 16.0),
                      _buildStreetField(),
                      const SizedBox(height: 16.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildNumberField()),
                          const SizedBox(width: 12.0),
                          Expanded(flex: 3, child: _buildComplementField()),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      _buildNeighborhoodField(),
                      const SizedBox(height: 16.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildCityField()),
                          const SizedBox(width: 12.0),
                          Expanded(flex: 1, child: _buildStateField()),
                        ],
                      ),
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
          Icons.location_on,
          size: 64,
          color: AppColors.mainGreen,
        ),
        const SizedBox(height: 16),
        const Text(
          "Onde você mora?",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          "Informe seu endereço completo",
          style: TextStyle(
            fontSize: 16,
            color: AppColors.mediumGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCEPField() {
    return CustomTextField(
      controller: _cepController,
      labelText: "CEP",
      hintText: "00000-000",
      keyboardType: TextInputType.number,
      maxLength: 8,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      prefixIcon: Icons.location_on,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe o CEP";
        } else if (value.length < 8) {
          return "CEP deve ter 8 dígitos";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          postalCode = _formatCEP(value);
        });
      },
    );
  }

  Widget _buildStreetField() {
    return CustomTextField(
      controller: _streetController,
      labelText: "Endereço",
      hintText: "Rua, Avenida, etc.",
      prefixIcon: Icons.location_on,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe o endereço";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          street = value;
        });
      },
    );
  }

  Widget _buildNumberField() {
    return CustomTextField(
      controller: _numberController,
      labelText: "Número",
      hintText: "123",
      prefixIcon: Icons.numbers,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe o número";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          number = value;
        });
      },
    );
  }

  Widget _buildComplementField() {
    return CustomTextField(
      controller: _complementController,
      labelText: "Complemento",
      hintText: "Apto, Bloco, etc. (opcional)",
      prefixIcon: Icons.add_location,
      onChanged: (value) {
        setState(() {
          complement = value;
        });
      },
    );
  }

  Widget _buildNeighborhoodField() {
    return CustomTextField(
      controller: _neighborhoodController,
      labelText: "Bairro",
      prefixIcon: Icons.location_city,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe o bairro";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          neighborhood = value;
        });
      },
    );
  }

  Widget _buildCityField() {
    return CustomTextField(
      controller: _cityController,
      labelText: "Cidade",
      prefixIcon: Icons.location_city,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe a cidade";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          city = value;
        });
      },
    );
  }

  Widget _buildStateField() {
    return CustomTextField(
      controller: _stateController,
      labelText: "UF",
      hintText: "SP",
      maxLength: 2,
      prefixIcon: Icons.map,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Informe a UF";
        } else if (value.length != 2) {
          return "UF deve ter 2 letras";
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          state = value.toUpperCase();
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
        notifier.updateAddressInfo(
          street: street,
          number: number,
          complement: complement,
          neighborhood: neighborhood,
          city: city,
          state: state,
          country: country,
          postalCode: postalCode,
        );
        Navigator.pushNamed(context, 'registerAuth');
      } catch (e) {
        // Error handling is done in the notifier
      }
    }
  }
}
