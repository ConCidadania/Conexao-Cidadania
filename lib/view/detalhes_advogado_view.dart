import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../controller/professional_controller.dart';
import '../model/professional_model.dart';

class DetalhesAdvogadoView extends StatelessWidget {
  const DetalhesAdvogadoView({super.key});

  @override
  Widget build(BuildContext context) {
    final professionalController = GetIt.I.get<ProfessionalController>();
    final Color primaryColor = const Color(0xFF00796B);

    // Receber o profissional passado como argumento
    final Professional? professional =
        professionalController.getSelectedProfessional();

    if (professional == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Detalhes do Profissional",
              style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            "Profissional não encontrado.",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detalhes do Profissional",
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
            // Foto do profissional
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: professional.profileImageUrl != null
                    ? NetworkImage(professional.profileImageUrl!)
                    : null,
                child: professional.profileImageUrl == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),
            const SizedBox(height: 30.0),

            // Nome
            const Text("Nome: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(professional.name, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20.0),

            // Especialidade
            const Text("Especialidade: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(professional.specialty, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20.0),

            // Email
            const Text("Email: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(professional.email, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20.0),

            // Telefone
            const Text("Telefone: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(professional.phone, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20.0),

            // Avaliação
            const Text("Avaliação: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < professional.rating.round()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 24,
                  );
                }),
                const SizedBox(width: 8),
                Text("${professional.rating.toStringAsFixed(1)}/5.0",
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
            const SizedBox(height: 20.0),

            // Descrição
            const Text("Descrição: ",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: SingleChildScrollView(
                child: Text(professional.description,
                    style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30.0),

            // Botão para selecionar profissional
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Definir o profissional selecionado no controller
                  professionalController.setSelectedProfessional(professional);

                  // Voltar para a tela anterior ou navegar para agendamento
                  Navigator.pop(context);

                  // Mostrar confirmação
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${professional.name} selecionado!"),
                      backgroundColor: primaryColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Selecionar Profissional"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
