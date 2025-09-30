import 'package:con_cidadania/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterAddressInfoView extends StatefulWidget {
  const RegisterAddressInfoView({super.key});

  @override
  State<RegisterAddressInfoView> createState() => _RegisterAddressInfoViewState();
}

class _RegisterAddressInfoViewState extends State<RegisterAddressInfoView> {
  final ctrl = GetIt.I.get<UserController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color primaryColor = Color(0xFF00796B);
  final Color accentColor = Color(0xFFB2DFDB);
  String street = "";
  String number = "";
  String? complement;
  String neighborhood = "";
  String city = "";
  String state = "";
  String country = "";
  String postalCode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Informações de Endereço", style: TextStyle(color: accentColor)),
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
                 * Street Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Logradouro",
                    hintText: "Rua, Avenida, etc.",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe o Logradouro";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      street = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Number Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Número",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe o Número";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      number = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Complement Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Complemento (opcional)",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      complement = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Neighborhood Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Bairro",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe o Bairro";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      neighborhood = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * City Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Cidade",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe a Cidade";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      city = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * State Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "Estado",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe o Estado";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      state = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Country Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  decoration: InputDecoration(
                    labelText: "País",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe o País";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      country = value;
                    });
                  },
                ),
                SizedBox(height: 20.0),
                /*
                 * Postal Code Input Field
                 */
                TextFormField(
                  style: TextStyle(fontSize: 20),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "CEP",
                    hintText: "XXXXX-XXX",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Informe o CEP";
                    }
                    // TODO: Add more specific postal code validation if needed
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      postalCode = value;
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
            ctrl.updateAddressInfo(street, number, complement, neighborhood, city, state, country, postalCode);
            Navigator.pushNamed(context, 'registerPersonal2');
          }
        },
        backgroundColor: primaryColor,
        child: Icon(Icons.arrow_forward, color: accentColor),
      ),
    );
  }
}