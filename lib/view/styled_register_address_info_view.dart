import 'package:con_cidadania/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:con_cidadania/utils/colors.dart';

class RegisterAddressInfoView extends StatefulWidget {
  const RegisterAddressInfoView({super.key});

  @override
  State<RegisterAddressInfoView> createState() =>
      _RegisterAddressInfoViewState();
}

class _RegisterAddressInfoViewState extends State<RegisterAddressInfoView> {
  final ctrl = GetIt.I.get<UserController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
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
  String country = "Brasil"; // Default country
  String postalCode = "";
  bool _isLoading = false;

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
                Icons.home_work_outlined,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                "Informações de Endereço",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                "Seu endereço é importante para a correta identificação nos processos.",
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
                      _buildCEPField(),
                      SizedBox(height: 16.0),
                      _buildStreetField(),
                      SizedBox(height: 16.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: _buildNumberField()),
                          SizedBox(width: 12.0),
                          Expanded(flex: 3, child: _buildComplementField()),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      _buildNeighborhoodField(),
                      SizedBox(height: 16.0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: _buildCityField()),
                          SizedBox(width: 12.0),
                          Expanded(flex: 1, child: _buildStateField()),
                        ],
                      ),
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
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildProgressIndicator({bool isDesktop = false}) {
    Color activeColor = Colors.white;
    Color inactiveColor = Colors.white.withOpacity(0.3);

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
            "Informações de Endereço",
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
              Expanded(child: _buildProgressBarStep(color: inactiveColor)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Etapa 3 de 4",
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
          Icons.location_on,
          size: 64,
          color: AppColors.mainGreen,
        ),
        SizedBox(height: 16),
        Text(
          "Onde você mora?",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
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
        controller: _cepController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(8),
        ],
        decoration: InputDecoration(
          labelText: "CEP",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.location_on, color: AppColors.mainGreen),
          hintText: "00000-000",
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
      ),
    );
  }

  Widget _buildStreetField() {
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
        controller: _streetController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        decoration: InputDecoration(
          labelText: "Endereço",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.location_on, color: AppColors.mainGreen),
          hintText: "Rua, Avenida, etc.",
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
            return "Informe o endereço";
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            street = value;
          });
        },
      ),
    );
  }

  Widget _buildNumberField() {
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
        controller: _numberController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: "Número",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.numbers, color: AppColors.mainGreen),
          hintText: "123",
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
            return "Informe o número";
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            number = value;
          });
        },
      ),
    );
  }

  Widget _buildComplementField() {
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
        controller: _complementController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        decoration: InputDecoration(
          labelText: "Complemento",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.add_location, color: AppColors.mainGreen),
          hintText: "Apto, Bloco, etc. (opcional)",
          hintStyle: TextStyle(color: AppColors.mediumGrey.withOpacity(0.7)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.mainGreen, width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: (value) {
          setState(() {
            complement = value;
          });
        },
      ),
    );
  }

  Widget _buildNeighborhoodField() {
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
        controller: _neighborhoodController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        decoration: InputDecoration(
          labelText: "Bairro",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.location_city, color: AppColors.mainGreen),
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
            return "Informe o bairro";
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            neighborhood = value;
          });
        },
      ),
    );
  }

  Widget _buildCityField() {
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
        controller: _cityController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        decoration: InputDecoration(
          labelText: "Cidade",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.location_city, color: AppColors.mainGreen),
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
            return "Informe a cidade";
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            city = value;
          });
        },
      ),
    );
  }

  Widget _buildStateField() {
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
        controller: _stateController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        maxLength: 2,
        decoration: InputDecoration(
          labelText: "UF",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.map, color: AppColors.mainGreen),
          hintText: "SP",
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
          counterText: "",
        ),
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
                        Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    // ... (código original sem alterações)
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        ctrl.updateAddressInfo(street, number, complement, neighborhood, city,
            state, country, postalCode);
        Navigator.pushNamed(context, 'registerAuth');
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
