import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../controller/user_controller.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final userCtrl = GetIt.I.get<UserController>();
  final Color primaryColor = Color(0xFF00796B); // Verde profissional
  final Color accentColor = Color(0xFFB2DFDB); // Verde claro

  final List<Map<String, dynamic>> services = [
    {
      'title': 'Consulta de Serviços',
      'icon': Icons.gavel,
      'route': 'consultaServicos'
    },
    {
      'title': 'Agendamento',
      'icon': Icons.calendar_today,
      'route': 'agendamento'
    },
    {
      'title': 'Acompanhamento Processos',
      'icon': Icons.assignment,
      'route': 'acompanhamentoProcessos'
    },
    {'title': 'Busca Advogados', 'icon': Icons.search, 'route': 'buscaAdv'},
    {'title': 'JustiBot', 'icon': Icons.chat, 'route': 'chat'},
  ];

  @override
  void initState() {
    super.initState();
    userCtrl.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bem Vindo ${userCtrl.currentUser?.name ?? 'Usuário'}!",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, 'profile');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: services.map((service) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: () => Navigator.pushNamed(context, service['route']),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(service['icon'], size: 40, color: primaryColor),
                    const SizedBox(height: 10),
                    Text(service['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800])),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await userCtrl.logout();
          Navigator.pushReplacementNamed(context, 'login');
        },
        backgroundColor: Colors.white,
        child: Icon(Icons.logout, color: primaryColor, size: 30),
      ),
    );
  }
}
