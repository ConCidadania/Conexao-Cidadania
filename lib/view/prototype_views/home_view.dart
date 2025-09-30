//import 'package:con_cidadania/utils/time.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:con_cidadania/controller/user_controller.dart';
import 'package:con_cidadania/controller/lawsuit_controller.dart';
import 'package:con_cidadania/model/lawsuit_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final userCtrl = GetIt.I.get<UserController>();
  final lawsuitCtrl = GetIt.I.get<LawsuitController>();
  final Color primaryColor = Color(0xFF00796B);
  final Color accentColor = Color(0xFFB2DFDB);
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<LawsuitType, Map<String, dynamic>> lawsuitOptions = {
    LawsuitType.REMEDIO_ALTO_CUSTO: {
      'name': 'Remédio de Alto Custo',
      'icon': Icons.medical_services,
    },
    LawsuitType.VAGA_CRECHE_PUBLICA: {
      'name': 'Vaga em Creche Pública',
      'icon': Icons.child_friendly,
    },
    LawsuitType.CIRURGIA_EMERGENCIAL: {
      'name': 'Cirurgia de Emergência',
      'icon': Icons.local_hospital,
    },
    LawsuitType.ALTERACAO_NOME_SOCIAL: {
      'name': 'Alteração de Nome Social',
      'icon': Icons.drive_file_rename_outline,
    },
    LawsuitType.INTERNACAO_ILP: {
      'name': 'Internação em Instituto de Longa Permanência',
      'icon': Icons.elderly,
    },
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: userCtrl.getCurrentUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Carregando...",
                  style: TextStyle(color: Colors.white));
            } else if (snapshot.hasError) {
              return Text("Bem Vindo!", style: TextStyle(color: Colors.white));
            } else {
              return Text(
                "Bem Vindo ${snapshot.data.toString()}!",
                style: TextStyle(color: Colors.white),
              );
            }
          },
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              userCtrl.logout();
              Navigator.pushReplacementNamed(context, 'login');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              controller: _searchController,
              leading: const Icon(Icons.search),
              hintText: "Pesquisar por tipo de ação",
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: 16.0),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<String>(
              future: userCtrl.getCurrentUserType(),
              builder: (context, typeSnapshot) {
                if (typeSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(color: primaryColor));
                }

                String userType = typeSnapshot.data ?? "USER";
                Stream<QuerySnapshot> lawsuitStream;

                if (userType == "USER") {
                  lawsuitStream = lawsuitCtrl.fetchUserLawsuits("owner");
                } else {
                  lawsuitStream = lawsuitCtrl.fetchAllLawsuits("owner");
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: lawsuitStream,
                  builder: (context, streamSnapshot) {
                    if (streamSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                          child:
                              CircularProgressIndicator(color: primaryColor));
                    }
                    if (streamSnapshot.hasError) {
                      return Center(
                          child:
                              Text("Ocorreu um erro: ${streamSnapshot.error}"));
                    }
                    if (!streamSnapshot.hasData ||
                        streamSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text("Nenhuma ação encontrada."));
                    }

                    final lawsuits = streamSnapshot.data!.docs
                        .map((doc) => Lawsuit.fromFirestore(doc))
                        .toList();
                    final filteredLawsuits = lawsuits.where((lawsuit) {
                      return lawsuit.name.toLowerCase().contains(_searchQuery);
                    }).toList();

                    if (filteredLawsuits.isEmpty) {
                      return Center(child: Text("Nenhuma ação encontrada."));
                    }

                    return ListView.builder(
                      itemCount: filteredLawsuits.length,
                      itemBuilder: (context, index) {
                        final lawsuit = filteredLawsuits[index];
                        return ListTile(
                          leading: Icon(Icons.assignment, color: primaryColor),
                          title: Text(lawsuit.name),
                          subtitle: Text("Aberto em: ${lawsuit.createdAt}"),
                          onTap: () {
                            // NOTE: "streamsnapshot.data.docs[index] não corresponde com a lista de busca"
                            // TODO: Fazer funcionar mesmo com a lista filtrada de busca 
                            lawsuitCtrl.setCurrentLawsuitId(streamSnapshot.data!.docs[index].id);
                            Navigator.pushNamed(context, 'manageLawsuit');
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FutureBuilder<String>(
      future: userCtrl.getCurrentUserType(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return FloatingActionButton(
            onPressed: () {},
            backgroundColor: primaryColor,
            child: CircularProgressIndicator(color: Colors.white),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return FloatingActionButton(
            onPressed: () => _showLawsuitTypeDialog(context),
            backgroundColor: primaryColor,
            child: Icon(Icons.list_alt_outlined, color: accentColor),
          );
        } else {
          String userType = snapshot.data!;
          IconData icon;
          Function() onPressed;

          if (userType == "ADMIN") {
            icon = Icons.account_box_rounded;
            onPressed = () => Navigator.pushNamed(context, 'manageUsers');
          } else {
            icon = Icons.list_alt_outlined;
            onPressed = () => _showLawsuitTypeDialog(context);
          }

          return FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: primaryColor,
            child: Icon(icon, color: accentColor),
          );
        }
      },
    );
  }

  void _showLawsuitTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Selecione o tipo de Ação Judicial",
              textAlign: TextAlign.center),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: lawsuitOptions.length,
              itemBuilder: (context, index) {
                final lawsuitType = lawsuitOptions.keys.elementAt(index);
                final data = lawsuitOptions[lawsuitType]!;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () async {
                      Navigator.of(context).pop();

                     // final userUid = userCtrl.getCurrentUserId();
                     // final newLawsuit = Lawsuit(
                     //   owner: userUid,
                     //   name: data['name'],
                     //   type: lawsuitType.name,
                     //   createdAt: formatDate(DateTime.now()),
                     // );
                     // lawsuitCtrl.addLawsuit(context, newLawsuit);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(data['icon'], size: 40, color: primaryColor),
                          SizedBox(height: 10),
                          Text(
                            data['name'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Fechar", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
