import 'package:con_cidadania/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPersonalInfo1View extends StatefulWidget {
  const RegisterPersonalInfo1View({super.key});

  @override
  State<RegisterPersonalInfo1View> createState() =>
      _RegisterPersonalInfo1ViewState();
}

class _RegisterPersonalInfo1ViewState extends State<RegisterPersonalInfo1View> {
  final ctrl = GetIt.I.get<UserController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color primaryColor = Color(0xFF00796B);
  final Color accentColor = Color(0xFFB2DFDB);
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informações Pessoais", style: TextStyle(color: accentColor)),
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
                 * First Name Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Nome",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe seu Nome";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      firstName = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Last Name Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Sobrenome",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe seu Sobrenome";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      lastName = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Profession Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Profissão",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe sua Profissão";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      profession = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Gender Dropdown Field
                 */
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Gênero",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  value: gender,
                  items: genders
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      gender = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Selecione seu Gênero";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Civil Status Dropdown Field
                 */
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Estado Civil",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  value: civilStatus,
                  items: civilStatuses
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      civilStatus = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Selecione seu Estado Civil";
                    }
                    return null;
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
            ctrl.updatePersonalInfo1(firstName, lastName, profession, gender, civilStatus);
            Navigator.pushNamed(context, 'registerAddress');
          }
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.arrow_forward, color: accentColor),
      ),
    );
  }
}