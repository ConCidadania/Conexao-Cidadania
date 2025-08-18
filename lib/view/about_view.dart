import 'package:flutter/material.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF00796B);
    final String appDescription =
        "O CONEXÃO CIDADANIA é um aplicativo jurídico desenvolvido para facilitar o acesso à justiça "
        "por cidadãos em situação de vulnerabilidade social. Nossa plataforma oferece um ambiente "
        "intuitivo e eficiente para a interposição de ações judiciais relacionadas a Direitos Sociais, "
        "simplificando processos e democratizando o acesso à assistência jurídica.";

    return Scaffold(
      appBar: AppBar(
        title: Text("Sobre o Aplicativo",
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w500)),
        centerTitle: true,
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text("CONEXÃO CIDADANIA",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontFamily: 'Roboto')),
            ),
            SizedBox(height: 30),
            Text(appDescription,
                style:
                    TextStyle(fontSize: 16, height: 1.5, fontFamily: 'Roboto'),
                textAlign: TextAlign.justify),
            SizedBox(height: 40),
            _buildSectionTitle("Créditos Acadêmicos"),
            SizedBox(height: 15),
            _buildInfoItem("Disciplina:", "Programação Mobile II"),
            _buildInfoItem("Curso:", "Engenharia de Software"),
            _buildInfoItem("Instituição:", "UNAERP"),
            _buildDeveloperInfo("Orientador:", "Prof. Rodrigo Plotze"),
            SizedBox(height: 30),
            _buildSectionTitle("Equipe de Desenvolvimento"),
            SizedBox(height: 15),
            _buildDeveloperInfo(
                "Desenvolvedor:", "João Vitor Vercezi Chivite - 768343"),
            _buildDeveloperInfo(
                "Desenvolvedor:", "Luís Henrique V. dos Reis - 768277"),
            SizedBox(height: 40),
            Center(
              child: Text("Versão 1.0.0 • 2025",
                  style:
                      TextStyle(color: Colors.grey[600], fontFamily: 'Roboto')),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00796B),
            fontFamily: 'Roboto'));
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16, color: Colors.black87),
          children: [
            TextSpan(
                text: "$label ", style: TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(text: value)
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperInfo(String role, String name) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 15, color: Colors.grey[800]),
          children: [
            TextSpan(
                text: "$role ", style: TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(text: name)
          ],
        ),
      ),
    );
  }
}
