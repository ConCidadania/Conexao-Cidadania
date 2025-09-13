import 'package:con_cidadania/controller/user_controller.dart';
import 'package:con_cidadania/utils/time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class RegisterPersonalInfo2View extends StatefulWidget {
  const RegisterPersonalInfo2View({super.key});

  @override
  State<RegisterPersonalInfo2View> createState() =>
      _RegisterPersonalInfo2ViewState();
}

class _RegisterPersonalInfo2ViewState extends State<RegisterPersonalInfo2View> {
  final ctrl = GetIt.I.get<UserController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color primaryColor = Color(0xFF00796B);
  final Color accentColor = Color(0xFFB2DFDB);
  DateTime? dateOfBirth;
  String rg = "";
  String cpf = "";
  String nationality = "";
  String naturality = "";

  final TextEditingController _dateOfBirthController = TextEditingController();

  @override
  void dispose() {
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: primaryColor,
            colorScheme: ColorScheme.light(primary: primaryColor),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != dateOfBirth) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dados Pessoais", style: TextStyle(color: accentColor)),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(30, 50, 30, 30),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 30.0),
                /*
                 * Date of Birth Input Field
                 */
                TextFormField(
                  controller: _dateOfBirthController,
                  readOnly: true,
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Data de Nascimento",
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe sua Data de Nascimento";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * RG Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: "RG",
                    counterText: '',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
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
                SizedBox(height: 20.0),
                /*
                 * CPF Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    // TODO: Add a custom formatter for CPF mask
                  ],
                  maxLength: 11,
                  decoration: InputDecoration(
                    labelText: "CPF",
                    counterText: '',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: _validateCpf,
                  onChanged: (value) {
                    setState(() {
                      cpf = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Nationality Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Nacionalidade",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe sua Nacionalidade";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      nationality = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Naturality Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Naturalidade",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe sua Naturalidade";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      naturality = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            ctrl.updatePersonalInfo2(formatDate(dateOfBirth!), rg, cpf, nationality, naturality);
            Navigator.pushNamed(context, 'registerAuth');
          }
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.arrow_forward, color: accentColor),
      ),
    );
  }
}