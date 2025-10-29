import 'package:con_cidadania/old/controller/user_controller.dart';
import 'package:con_cidadania/core/utils/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:con_cidadania/core/utils/colors.dart';

class RegisterPersonalInfo2View extends StatefulWidget {
  const RegisterPersonalInfo2View({super.key});

  @override
  State<RegisterPersonalInfo2View> createState() =>
      _RegisterPersonalInfo2ViewState();
}

class _RegisterPersonalInfo2ViewState extends State<RegisterPersonalInfo2View> {
  final ctrl = GetIt.I.get<UserController>();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Form controllers
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
  bool _isLoading = false;

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    _rgController.dispose();
    _cpfController.dispose();
    _nationalityController.dispose();
    _naturalityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.mainGreen,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.blackColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateOfBirth = picked;
        _dateOfBirthController.text =
            DateFormat('dd/MM/yyyy').format(dateOfBirth!);
      });
    }
  }

  String? _validateCpf(String? value) {
    if (value == null || value.isEmpty) {
      return "Informe seu CPF";
    }
    String cleanedCpf = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanedCpf.length != 11) {
      return "CPF inválido";
    }
    return null;
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
                Icons.assignment_ind_outlined,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                "Dados e Documentos",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                "Suas informações são essenciais para a validação do seu cadastro.",
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
                      _buildDateOfBirthField(),
                      SizedBox(height: 16.0),
                      _buildRGField(),
                      SizedBox(height: 16.0),
                      _buildCPFField(),
                      SizedBox(height: 16.0),
                      _buildNationalityField(),
                      SizedBox(height: 16.0),
                      _buildNaturalityField(),
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
            "Dados Pessoais",
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
              Expanded(child: _buildProgressBarStep(color: inactiveColor)),
              SizedBox(width: 8),
              Expanded(child: _buildProgressBarStep(color: inactiveColor)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            "Etapa 2 de 4",
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
          Icons.assignment_ind,
          size: 64,
          color: AppColors.mainGreen,
        ),
        SizedBox(height: 16),
        Text(
          "Seus documentos",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.blackColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
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
        controller: _dateOfBirthController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Data de Nascimento",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.calendar_today, color: AppColors.mainGreen),
          suffixIcon: Icon(Icons.arrow_drop_down, color: AppColors.mediumGrey),
          hintText: "DD/MM/AAAA",
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
            return "Informe sua data de nascimento";
          }
          return null;
        },
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget _buildRGField() {
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
        controller: _rgController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        maxLength: 10,
        decoration: InputDecoration(
          labelText: "RG",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.credit_card, color: AppColors.mainGreen),
          counterText: '',
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
            return "Informe seu RG";
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            rg = value;
          });
        },
      ),
    );
  }

  Widget _buildCPFField() {
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
        controller: _cpfController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        keyboardType: TextInputType.number,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
        ],
        maxLength: 11,
        decoration: InputDecoration(
          labelText: "CPF",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.badge, color: AppColors.mainGreen),
          hintText: "000.000.000-00",
          hintStyle: TextStyle(color: AppColors.mediumGrey.withOpacity(0.7)),
          counterText: '',
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
        validator: _validateCpf,
        onChanged: (value) {
          setState(() {
            cpf = value;
          });
        },
      ),
    );
  }

  Widget _buildNationalityField() {
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
        controller: _nationalityController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: "Nacionalidade",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.flag, color: AppColors.mainGreen),
          hintText: "Ex: Brasileira",
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
            return "Informe sua nacionalidade";
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            nationality = _formatName(value);
          });
        },
      ),
    );
  }

  Widget _buildNaturalityField() {
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
        controller: _naturalityController,
        style: TextStyle(fontSize: 16, color: AppColors.blackColor),
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: "Naturalidade",
          labelStyle: TextStyle(color: AppColors.mediumGrey),
          prefixIcon: Icon(Icons.location_city, color: AppColors.mainGreen),
          hintText: "Ex: São Paulo - SP",
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
            return "Informe sua naturalidade";
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            naturality = _formatName(value);
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
        ctrl.updatePersonalInfo2(
            formatDate(dateOfBirth!), rg, cpf, nationality, naturality);
        Navigator.pushNamed(context, 'registerAddress');
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
