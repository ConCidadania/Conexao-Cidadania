import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../controller/service_controller.dart';
// Importar ServiceModel

class ConsultaServicosView extends StatefulWidget {
  const ConsultaServicosView({super.key});

  @override
  State<ConsultaServicosView> createState() => _ConsultaServicosViewState();
}

class _ConsultaServicosViewState extends State<ConsultaServicosView> {
  final ctrl = GetIt.I.get<ServiceController>();
  final Color primaryColor = const Color(0xFF00796B); // Verde profissional
  final Color accentColor = const Color(0xFFB2DFDB);

  @override
  void initState() {
    super.initState();
    ctrl.addListener(() => setState(() {}));
    ctrl.fetchServices(); // Carregar serviços ao iniciar a tela
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visualizar Serviços Jurídicos",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 30),
        child: Column(
          children: [
            const Text("Serviços Disponíveis:", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: ctrl.services.length,
                itemBuilder: (context, index) {
                  final service = ctrl.services[index];
                  return SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.work),
                        title: Text(service.name),
                        subtitle: Text(service.category),
                        onTap: () {
                          // Passar o objeto Service diretamente para a próxima tela
                          Navigator.pushNamed(context, 'serviceDetails',
                              arguments: service);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
