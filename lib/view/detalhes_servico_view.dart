import 'package:app_mobile2/controller/service_controller.dart';
import 'package:app_mobile2/model/service_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DetalhesServicoView extends StatelessWidget {
  const DetalhesServicoView({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceController = GetIt.I.get<ServiceController>();
    final Color primaryColor = const Color(0xFF00796B);

    // Receber o serviço passado como argumento
    final Service? service =
        ModalRoute.of(context)?.settings.arguments as Service?;

    if (service == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Detalhes do Serviço",
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            "Serviço não encontrado.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes do Serviço",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Serviço: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(service.name, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20.0),
            const Text("Categoria: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(service.category, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20.0),
            const Text("Preço: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("R\$ ${service.price.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 20, color: Colors.green)),
            const SizedBox(height: 20.0),
            const Text("Descrição: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(service.description, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Definir o serviço selecionado no controller
                  serviceController.setSelectedService(service);

                  // Navegar para a tela de agendamento
                  Navigator.pushNamed(context, 'agendamento');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Agendar / Solicitar Serviço"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
